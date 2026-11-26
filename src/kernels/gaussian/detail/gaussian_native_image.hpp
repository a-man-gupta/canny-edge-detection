#pragma once
#include "gaussian_native.hpp"

namespace gaussian_native {
__attribute__((target("avx512bw")))
static inline void fill(const uint8_t* src, int16_t* scratch, int16_t* dst, int w, const GaussQ15& q) {
    expand(src, scratch, w);
    scratch[-2] = scratch[2]; scratch[-1] = scratch[1];
    scratch[w] = scratch[w-2]; scratch[w+1] = scratch[w-3];
    horizontal(scratch, dst, w, q);
}

__attribute__((target("avx512bw")))
static inline __m256i vertical_result(__m512i a,__m512i b,__m512i c,__m512i d,__m512i e,
                                      __m512i c0,__m512i c1,__m512i c2,__m512i round) {
    auto center = _mm512_mulhrs_epi16(c,c0);
    auto inner = _mm512_mulhrs_epi16(_mm512_add_epi16(b,d),c1);
    auto outer = _mm512_mulhrs_epi16(_mm512_add_epi16(a,e),c2);
    auto sum = _mm512_add_epi16(center,_mm512_add_epi16(inner,outer));
    return _mm512_cvtusepi16_epi8(_mm512_mulhrs_epi16(sum,round));
}

__attribute__((target("avx512bw")))
static void group_rows(int16_t* const rows[8], uint8_t* out,int w,const GaussQ15& q) {
    const auto c0=_mm512_set1_epi16(q.c0),c1=_mm512_set1_epi16(q.c1),c2=_mm512_set1_epi16(q.c2);
    const auto round=_mm512_set1_epi16(512);
    const int16_t* r[8];
    for(int i=0;i<8;++i) r[i]=rows[i];
#pragma GCC unroll 2
    for(int x=0;x<w;x+=32) {
        __m512i h[8];
        for(int i=0;i<8;++i) h[i]=_mm512_loadu_si512(r[i]+x);
#pragma GCC unroll 4
        for(int i=0;i<4;++i)
            _mm256_storeu_si256((__m256i*)(out+(size_t)i*w+x),vertical_result(h[i],h[i+1],h[i+2],h[i+3],h[i+4],c0,c1,c2,round));
    }
}

// Compute one horizontal vector from the five neighboring columns.
__attribute__((target("avx512bw")))
static inline __m512i horizontal_one(const int16_t* row, __m512i c0, __m512i c1, __m512i c2) {
    auto inner = _mm512_add_epi16(_mm512_loadu_si512(row-1), _mm512_loadu_si512(row+1));
    auto outer = _mm512_add_epi16(_mm512_loadu_si512(row-2), _mm512_loadu_si512(row+2));
    auto center = _mm512_mulhrs_epi16(_mm512_loadu_si512(row), c0);
    return _mm512_add_epi16(center, _mm512_add_epi16(_mm512_mulhrs_epi16(inner,c1),
                                                     _mm512_mulhrs_epi16(outer,c2)));
}

// Hold all ten horizontal results in registers for each group of 32 columns.
__attribute__((target("avx512bw")))
static void image_ten_rows(const uint8_t* src, uint8_t* dst, const GaussQ15& q) {
    constexpr int width = 256, height = 10;
    alignas(64) int16_t expanded[height][320];
    for (int y = 0; y < height; ++y) {
        const auto* in = src + y * width;
        auto* row = expanded[y] + 32;
        expand(in, row, width);
        row[-2] = in[2] << 6;
        row[-1] = in[1] << 6;
        row[width] = in[width - 2] << 6;
        row[width + 1] = in[width - 3] << 6;
    }

    const auto c0 = _mm512_set1_epi16(q.c0), c1 = _mm512_set1_epi16(q.c1);
    const auto c2 = _mm512_set1_epi16(q.c2), round = _mm512_set1_epi16(512);
    auto reflect = [](int y) { return y < 0 ? -y : (y >= height ? 2 * height - 2 - y : y); };
    for (int x = 0; x < width; x += 32) {
        __m512i horizontal[height];
#pragma GCC unroll 10
        for (int y = 0; y < height; ++y)
            horizontal[y] = horizontal_one(expanded[y] + 32 + x, c0, c1, c2);
#pragma GCC unroll 10
        for (int y = 0; y < height; ++y) {
            auto pixels = vertical_result(horizontal[reflect(y-2)], horizontal[reflect(y-1)],
                                          horizontal[y], horizontal[reflect(y+1)], horizontal[reflect(y+2)],
                                          c0, c1, c2, round);
            _mm256_storeu_si256((__m256i*)(dst + y * width + x), pixels);
        }
    }
}

__attribute__((target("avx512bw")))
static void column_image(int height, const uint8_t* src, uint8_t* dst, const GaussQ15& q) {
    constexpr int w=256, band=24;
    alignas(64) int16_t expanded[band+4][320];
    const auto c0=_mm512_set1_epi16(q.c0), c1=_mm512_set1_epi16(q.c1), c2=_mm512_set1_epi16(q.c2);
    const auto round=_mm512_set1_epi16(512);
    for (int y=0; y<height; y+=band) {
        const int n = height-y < band ? height-y : band;
        // A short final band still needs four real rows for the rolling window.
        const int first=y<2 ? 0 : (y-2<height-4 ? y-2 : height-4);
        const int end=y+n+2<height ? y+n+2 : height;
        for (int r=first; r<end; ++r) {
            const auto* p=src+(size_t)r*w;
            auto* row=expanded[r-first]+32;
            expand(p,row,w);
            row[-2]=p[2]<<6; row[-1]=p[1]<<6; row[w]=p[w-2]<<6; row[w+1]=p[w-3]<<6;
        }
        for (int x=0;x<w;x+=64) {
            auto h0a=horizontal_one(expanded[0]+32+x,c0,c1,c2);
            auto h0b=horizontal_one(expanded[0]+32+(x+32),c0,c1,c2);
            auto h1a=horizontal_one(expanded[1]+32+x,c0,c1,c2);
            auto h1b=horizontal_one(expanded[1]+32+(x+32),c0,c1,c2);
            auto h2a=horizontal_one(expanded[2]+32+x,c0,c1,c2);
            auto h2b=horizontal_one(expanded[2]+32+(x+32),c0,c1,c2);
            auto h3a=horizontal_one(expanded[3]+32+x,c0,c1,c2);
            auto h3b=horizontal_one(expanded[3]+32+(x+32),c0,c1,c2);
            if (first==0) {
                _mm256_storeu_si256((__m256i*)(dst+x),vertical_result(h2a,h1a,h0a,h1a,h2a,c0,c1,c2,round));
                _mm256_storeu_si256((__m256i*)(dst+(x+32)),vertical_result(h2b,h1b,h0b,h1b,h2b,c0,c1,c2,round));
                _mm256_storeu_si256((__m256i*)(dst+w+x),vertical_result(h1a,h0a,h1a,h2a,h3a,c0,c1,c2,round));
                _mm256_storeu_si256((__m256i*)(dst+w+(x+32)),vertical_result(h1b,h0b,h1b,h2b,h3b,c0,c1,c2,round));
            }
            int r=first+4;
            __m512i h4a;
            __m512i h4b;
            for (;r+4<end;r+=5) {
                h4a=horizontal_one(expanded[r-first+0]+32+x,c0,c1,c2);
                h4b=horizontal_one(expanded[r-first+0]+32+(x+32),c0,c1,c2);
                _mm256_storeu_si256((__m256i*)(dst+(size_t)(r-2+0)*w+x),vertical_result(h0a,h1a,h2a,h3a,h4a,c0,c1,c2,round));
                _mm256_storeu_si256((__m256i*)(dst+(size_t)(r-2+0)*w+(x+32)),vertical_result(h0b,h1b,h2b,h3b,h4b,c0,c1,c2,round));
                h0a=horizontal_one(expanded[r-first+1]+32+x,c0,c1,c2);
                h0b=horizontal_one(expanded[r-first+1]+32+(x+32),c0,c1,c2);
                _mm256_storeu_si256((__m256i*)(dst+(size_t)(r-2+1)*w+x),vertical_result(h1a,h2a,h3a,h4a,h0a,c0,c1,c2,round));
                _mm256_storeu_si256((__m256i*)(dst+(size_t)(r-2+1)*w+(x+32)),vertical_result(h1b,h2b,h3b,h4b,h0b,c0,c1,c2,round));
                h1a=horizontal_one(expanded[r-first+2]+32+x,c0,c1,c2);
                h1b=horizontal_one(expanded[r-first+2]+32+(x+32),c0,c1,c2);
                _mm256_storeu_si256((__m256i*)(dst+(size_t)(r-2+2)*w+x),vertical_result(h2a,h3a,h4a,h0a,h1a,c0,c1,c2,round));
                _mm256_storeu_si256((__m256i*)(dst+(size_t)(r-2+2)*w+(x+32)),vertical_result(h2b,h3b,h4b,h0b,h1b,c0,c1,c2,round));
                h2a=horizontal_one(expanded[r-first+3]+32+x,c0,c1,c2);
                h2b=horizontal_one(expanded[r-first+3]+32+(x+32),c0,c1,c2);
                _mm256_storeu_si256((__m256i*)(dst+(size_t)(r-2+3)*w+x),vertical_result(h3a,h4a,h0a,h1a,h2a,c0,c1,c2,round));
                _mm256_storeu_si256((__m256i*)(dst+(size_t)(r-2+3)*w+(x+32)),vertical_result(h3b,h4b,h0b,h1b,h2b,c0,c1,c2,round));
                h3a=horizontal_one(expanded[r-first+4]+32+x,c0,c1,c2);
                h3b=horizontal_one(expanded[r-first+4]+32+(x+32),c0,c1,c2);
                _mm256_storeu_si256((__m256i*)(dst+(size_t)(r-2+4)*w+x),vertical_result(h4a,h0a,h1a,h2a,h3a,c0,c1,c2,round));
                _mm256_storeu_si256((__m256i*)(dst+(size_t)(r-2+4)*w+(x+32)),vertical_result(h4b,h0b,h1b,h2b,h3b,c0,c1,c2,round));
            }
            for (;r<end;++r) {
                auto h4a=horizontal_one(expanded[r-first]+32+x,c0,c1,c2);
                auto h4b=horizontal_one(expanded[r-first]+32+(x+32),c0,c1,c2);
                auto va=vertical_result(h0a,h1a,h2a,h3a,h4a,c0,c1,c2,round);
                auto vb=vertical_result(h0b,h1b,h2b,h3b,h4b,c0,c1,c2,round);
                _mm256_storeu_si256((__m256i*)(dst+(size_t)(r-2)*w+x),va);
                _mm256_storeu_si256((__m256i*)(dst+(size_t)(r-2)*w+x+32),vb);
                h0a=h1a; h1a=h2a; h2a=h3a; h3a=h4a;
                h0b=h1b; h1b=h2b; h2b=h3b; h3b=h4b;
            }
            if (y+n==height) {
                _mm256_storeu_si256((__m256i*)(dst+(size_t)(height-2)*w+x),vertical_result(h0a,h1a,h2a,h3a,h2a,c0,c1,c2,round));
                _mm256_storeu_si256((__m256i*)(dst+(size_t)(height-2)*w+(x+32)),vertical_result(h0b,h1b,h2b,h3b,h2b,c0,c1,c2,round));
                _mm256_storeu_si256((__m256i*)(dst+(size_t)(height-1)*w+x),vertical_result(h1a,h2a,h3a,h2a,h1a,c0,c1,c2,round));
                _mm256_storeu_si256((__m256i*)(dst+(size_t)(height-1)*w+(x+32)),vertical_result(h1b,h2b,h3b,h2b,h1b,c0,c1,c2,round));
            }
        }
    }
}
// Four neighboring outputs share eight horizontal rows. Each real input is filtered once.
__attribute__((target("avx512bw")))
static void image(int w,int h,const uint8_t* src,uint8_t* dst,const GaussQ15& q,GaussianWork* work) {
    if (w == 256 && h == 10) { image_ten_rows(src, dst, q); return; }
    if (w==256) { column_image(h,src,dst,q); return; }
    auto scratch=gaussian_scratch(work);
    int16_t* rows[8];
    for(int i=0;i<8;++i) {
        rows[i]=gaussian_ring_row(work,i);
    }
    for (int i=0; i<8; ++i) fill(src+(size_t)i*w,scratch,rows[i],w,q);
    const int16_t* first[5]={rows[2],rows[1],rows[0],rows[1],rows[2]};
    const int16_t* second[5]={rows[1],rows[0],rows[1],rows[2],rows[3]};
    vertical(first,dst,w,q); vertical(second,dst+w,w,q);
    constexpr int nrows=4, slots=nrows+4;
    int y=2,top=0;
    for(;y+nrows+1<h;y+=nrows) {
        group_rows(rows,dst+(size_t)y*w,w,q);
        const int remaining=h-(top+slots);
        const int step=remaining<nrows?remaining:nrows;
        if(step>0) {
            int16_t* spare[nrows];
            for(int i=0;i<step;++i) spare[i]=rows[i];
            for(int i=0;i<slots-step;++i) rows[i]=rows[i+step];
            for(int i=0;i<step;++i) {
                rows[slots-step+i]=spare[i];
            }
            for (int i=0; i<step; ++i)
                fill(src+(size_t)(top+slots+i)*w,scratch,spare[i],w,q);
            top+=step;
        }
    }
    for(;y<h;++y) {
        const int16_t* edge[5];
        for(int j=0;j<5;++j) {
            int r=y+j-2;
            edge[j]=rows[(r<h?r:2*h-2-r)-top];
        }
        vertical(edge,dst+(size_t)y*w,w,q);
    }
}
}
