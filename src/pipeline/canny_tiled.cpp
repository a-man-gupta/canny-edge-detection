#include "canny_tiled.hpp"
#include "../kernels/sobel/kernel_sobel.hpp"
#include "../kernels/nms/kernel_nms.hpp"
#include "../kernels/hysteresis/hysteresis_kernel.hpp"
#include <algorithm>
#include <cstring>
#include <immintrin.h>
#include <omp.h>
#include <vector>
#include <memory>
#include <stdexcept>

namespace {
constexpr int band = 64;
constexpr int output_rows = SOBEL_ROWS - 2;
static_assert(output_rows > 0 && output_rows % 2 == 0);
struct Scratch {
    std::unique_ptr<GaussianWork, decltype(&gaussian_work_destroy)> gaussian;
    alignas(64) uint16_t input[(SOBEL_ROWS + 2) * SOBEL_IN_STRIDE]{};
    alignas(64) int16_t gradient[3 * SOBEL_PLANE]{};
    uint8_t blur[SOBEL_IN_STRIDE]{}, labels[2 * SOBEL_MAX_WIDTH]{};
    explicit Scratch(int width): gaussian(gaussian_work_create(width + 64), gaussian_work_destroy) {}
};

int reflect(int y, int h) {
    int period = 2 * (h - 1);
    int t = y % period;
    if (t < 0) t += period;
    return std::min(t, period - t);
}

unsigned long long morton_key(unsigned x, unsigned y) {
    unsigned long long key = 0;
    for (int i=0; x || y; ++i, x>>=1, y>>=1)
        key |= (static_cast<unsigned long long>((x&1) | ((y&1)<<1)) << (2*i));
    return key;
}

template<bool materialized>
void tile(const uint8_t *image, uint8_t *out, int w, int h, int x, int y,
          int width, int height, GaussQ15 q, int low, int high, Scratch &s) {
    // Round NMS to its 64-column block, then include both Sobel halo columns.
    int nw = (width + 63) / 64 * 64, sw = (nw + 2 + 31) / 32 * 32;
    int left = std::max(0, x - 4), right = std::min(w, x + sw + 2);
    int gw = right - left;
    auto *work = s.gaussian.get();
    int latest = -1;
    int first = std::clamp(y - 2, 0, h - 1) - 2;
    auto prepare = [&](int row, uint16_t *dst) {
        int center = std::clamp(row, 0, h - 1), last = center + 2 - first;
        const uint8_t *blur = image + size_t(center)*w + left;
        if constexpr (!materialized) {
            // Advance the horizontal ring just far enough for this vertical output.
            while (latest < last) {
                ++latest;
                auto *scratch = gaussian_scratch(work);
                gaussian_expand_row(image + size_t(reflect(first + latest, h)) * w + left, scratch, gw);
                gaussian_horiz_row(scratch, gaussian_ring_row(work, latest % 5), gw, q);
            }
            const int16_t *rows[5];
            for (int i = 0; i < 5; ++i) rows[i] = gaussian_ring_row(work, (last - 4 + i) % 5);
            gaussian_vert_row(rows, s.blur, gw, q);
            blur = s.blur;
        }
        int offset = x - 2 - left, count = sw + 2;
        int begin = std::max(0, -offset), end = std::min(count, gw - offset);
        std::fill_n(dst, begin, blur[0]);
        int i = begin;
        for (; i + 16 <= end; i += 16)
            _mm256_storeu_si256((__m256i*)(dst + i), _mm256_cvtepu8_epi16(
                _mm_loadu_si128((const __m128i*)(blur + offset + i))));
        for (; i < end; ++i) dst[i] = blur[offset+i];
        std::fill(dst + end, dst + count, blur[gw - 1]);
    };
    for (int j = 0; j < 4; ++j) prepare(y - 2 + j, s.input + j * SOBEL_IN_STRIDE);
    for (int r = 0; r < height; r += output_rows) {
        for (int j = 4; j < SOBEL_ROWS+2; ++j)
            prepare(y + r - 2 + j, s.input + j * SOBEL_IN_STRIDE);
#ifdef CANNY_REUSE_HALO
        if (r != 0)
            sobel_new_rows(s.input + 2*SOBEL_IN_STRIDE, s.gradient + 2*SOBEL_OUT_STRIDE, sw);
        else
#endif
            sobel_kernel(s.input, s.gradient, sw);
        for (int j = 0; j < output_rows && r+j < height; j += 2) {
            auto *top = s.gradient + 1 + j * SOBEL_OUT_STRIDE;
            auto *gx = top + SOBEL_OUT_STRIDE + SOBEL_PLANE;
            nms_labels(top, SOBEL_OUT_STRIDE, gx, gx + SOBEL_PLANE, SOBEL_OUT_STRIDE,
                       s.labels, nw, nw, low, high);
            for (int k = 0; k < 2 && r+j+k < height; ++k)
                std::memcpy(out + size_t(y+r+j+k)*w+x, s.labels + k*nw, width);
        }
        if (r + output_rows < height) {
            int first_blur = 0;
#ifdef CANNY_REUSE_HALO
            // NMS reads both magnitude halos but only the second row's direction.
            for (int j=0; j<2; ++j)
                std::memcpy(s.gradient+j*SOBEL_OUT_STRIDE,
                            s.gradient+(j+output_rows)*SOBEL_OUT_STRIDE,sw*sizeof(int16_t));
            for (int plane=1; plane<=2; ++plane) {
                auto *dst=s.gradient+plane*SOBEL_PLANE+SOBEL_OUT_STRIDE;
                std::memcpy(dst,dst+output_rows*SOBEL_OUT_STRIDE,sw*sizeof(int16_t));
            }
            first_blur = 2;
#endif
            // Four blurred rows overlap the next output block.
            for (int j = first_blur; j < 4; ++j)
                std::memcpy(s.input + j*SOBEL_IN_STRIDE, s.input + (j+output_rows)*SOBEL_IN_STRIDE,
                            (sw+2)*sizeof(uint16_t));
        }
    }
}
}

// Caller supplies disjoint buffers and dimensions >= 5. Outer NMS border is zero.
void canny_tiled(const uint8_t *image, uint8_t *labels, uint8_t *edges, int w, int h,
                 GaussQ15 q, int low, int high, int strip, double &filter_ms, double &track_ms, FusionMode mode, bool mask_seeds) {
    if (w < 5 || h < 5 || strip < 64 || strip > 320 || strip % 64 ||
        low < 0 || high <= low || high > 32767) throw std::invalid_argument("Canny dimensions or thresholds");
    double begin = omp_get_wtime();
    int workers = std::min(h, omp_get_max_threads());
    std::vector<size_t> frontier;
    const int nx=(w-3)/strip+1, ny=(h-3)/band+1;
    struct Tile { unsigned long long key; int x,y; };
    std::vector<Tile> order;
    if (mode==FusionMode::morton) {
        for(int y=0;y<ny;++y) for(int x=0;x<nx;++x)
            order.push_back({morton_key(x,y),x,y});
        std::sort(order.begin(),order.end(),[](auto a,auto b){ return a.key<b.key; });
    }
    const int pitch=(w+31)/32*32;
    std::vector<uint8_t> full_blur;
    std::vector<int16_t> horizontal;
    int16_t *aligned=nullptr;
    if (mode==FusionMode::staged) {
        full_blur.resize(size_t(w)*h);
        horizontal.resize(size_t(pitch)*h+16);
        aligned=horizontal.data()+((32-reinterpret_cast<uintptr_t>(horizontal.data())%32)%32)/2;
    }
#pragma omp parallel num_threads(workers)
    {
        Scratch scratch(mode==FusionMode::staged ? w : strip);
        if (mode==FusionMode::staged) {
            auto *row=gaussian_scratch(scratch.gaussian.get());
#pragma omp for schedule(static)
            for(int y=0;y<h;++y) {
                gaussian_expand_row(image+size_t(y)*w,row,w);
                gaussian_horiz_row(row,aligned+size_t(y)*pitch,w,q);
            }
#pragma omp for schedule(static)
            for(int y=0;y<h;++y) {
                const int16_t *rows[5];
                for(int j=0;j<5;++j) rows[j]=aligned+size_t(reflect(y+j-2,h))*pitch;
                gaussian_vert_row(rows,full_blur.data()+size_t(y)*w,w,q);
            }
        }
#pragma omp for schedule(static)
        for (int i=0;i<nx*ny;++i) {
            int x=1+(order.empty()? i%nx : order[i].x)*strip;
            int y=1+(order.empty()? i/nx : order[i].y)*band;
            int width=std::min(strip,w-1-x), height=std::min(band,h-1-y);
            if(mode==FusionMode::staged)
                tile<true>(full_blur.data(),labels,w,h,x,y,width,height,q,low,high,scratch);
            else
                tile<false>(image,labels,w,h,x,y,width,height,q,low,high,scratch);
        }
#pragma omp master
        {
            std::fill_n(labels,w,0);
            std::fill_n(labels+size_t(h-1)*w,w,0);
            for (int y=1; y<h-1; ++y) labels[size_t(y)*w]=labels[size_t(y+1)*w-1]=0;
            filter_ms=(omp_get_wtime()-begin)*1000;
        }
#pragma omp barrier
        // Each worker owns its edge rows until all local queues finish.
        const int id = omp_get_thread_num();
        const int n = omp_get_num_threads();
        const int first = int(int64_t(id) * h / n);
        const int end = int(int64_t(id + 1) * h / n);
        std::vector<size_t> queue;
        auto track = mask_seeds ? hysteresis_slab : hysteresis_kernel;
        track(w,end-first,labels+size_t(first)*w,edges+size_t(first)*w,queue);
#pragma omp barrier
        // Collect seam candidates while all slab edge maps are read-only.
        queue.clear();
        for (int side=0; side<2; ++side) {
            int row=side ? end-1 : first, other=row+(side ? 1 : -1);
            if (other<0 || other>=h) continue;
            for (int x=1; x<w-1; ++x) {
                size_t p=size_t(row)*w+x, neighbor=size_t(other)*w+x;
                if (labels[p]==1 && !edges[p] &&
                    (edges[neighbor-1] || edges[neighbor] || edges[neighbor+1])) queue.push_back(p);
            }
        }
#pragma omp critical(canny_seams)
        frontier.insert(frontier.end(),queue.begin(),queue.end());
    }
    for (size_t p:frontier) edges[p]=255;
    // Every candidate is interior because the NMS border is zero.
    for (size_t i=0; i<frontier.size(); ++i)
        for (int dy=-1; dy<=1; ++dy)
            for (int dx=-1; dx<=1; ++dx) {
                size_t p=frontier[i]+dy*std::ptrdiff_t(w)+dx;
                if (labels[p]==1 && !edges[p]) { edges[p]=255; frontier.push_back(p); }
            }
    track_ms=(omp_get_wtime()-begin)*1000-filter_ms;
}

void canny_slab_labels(const uint8_t *input, uint8_t *labels, int w, int padded_height,
                       int first_owned, int owned_rows, GaussQ15 q) {
    constexpr int strip = 320;
    const int begin = std::max(first_owned,1);
    const int end = std::min(first_owned+owned_rows,padded_height-1);
    std::fill_n(labels,size_t(w)*padded_height,0);
#pragma omp parallel
    {
        Scratch scratch(strip);
#pragma omp for collapse(2) schedule(static)
        for (int y=begin; y<end; y+=band)
            for (int x=1; x<w-1; x+=strip)
                tile<false>(input,labels,w,padded_height,x,y,std::min(strip,w-1-x),
                            std::min(band,end-y),q,60,120,scratch);
    }
}
