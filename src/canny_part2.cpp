// Part 2 driver. Same pipeline as canny_scalar.cpp, except Sobel calls sobel_kernel.
// canny_scalar.cpp stays the inline scalar reference. Parts 1, 3, 4, and 5 are unchanged.
#include "hysteresis.hpp"
#include "sobel_kernel.hpp"
#include "stages_dump.hpp"

#include <algorithm>
#include <array>
#include <chrono>
#include <cmath>
#include <cstdint>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>

using Clock = std::chrono::steady_clock;

// Same RDTSC read as the 18-645 benchmarking lab and the kernel-design driver:
//   private/18645/benchmarking_starter/latency/latency_simd_fma.c
//   private/18645/KernelDesignTemplate/kernel_driver.c
// TSC ticks are scaled by MAX_FREQ/BASE_FREQ, the constants those files use.
static constexpr double MAX_FREQ = 3.4;
static constexpr double BASE_FREQ = 2.4;
// Peak of that kernel-design measurement. kernel_driver.c prints flops/cycle for
// a 6x8 double FMA kernel; 2 FMA ports * 4 doubles * 2 flops = 16. The same two
// ports issue 2 * 8 single-precision adds per cycle, which is also 16 flops/cycle.
static constexpr double PEAK_FLOPS_PER_CYCLE = 16.0;
// Floating-point ops in sobel_kernel per pixel, counted the way kernel_driver.c
// counts 2*m*n*k (one flop per add, subtract, or multiply; an FMA would be two).
// gx is 8, gy is 8, magnitude is 2 multiplies + 1 add + 1 sqrt, angle is atan2 +
// 1 multiply + 1 divide. The conditional +180 is not counted.
static constexpr double SOBEL_FLOPS_PER_PIXEL = 23.0;
static constexpr double THRESHOLD_FLOPS_PER_CYCLE = PEAK_FLOPS_PER_CYCLE;
static constexpr double THRESHOLD_CYCLES_PER_PIXEL = SOBEL_FLOPS_PER_PIXEL / PEAK_FLOPS_PER_CYCLE;

static inline unsigned long long rdtsc(void) {
    unsigned hi, lo;
    __asm__ __volatile__("rdtsc" : "=a"(lo), "=d"(hi));
    return (static_cast<unsigned long long>(lo)) | (static_cast<unsigned long long>(hi) << 32);
}

// Elapsed time in milliseconds between two clock readings.
static double ms(Clock::time_point a, Clock::time_point b) {
    return std::chrono::duration<double, std::milli>(b-a).count();
}

// Next PGM header token. A '#' starts a comment that runs to the end of the line.
static std::string token(std::istream& in) {
    std::string s;
    while(in >> s) { if(s[0]!='#') return s; std::getline(in,s); }
    throw std::runtime_error("Invalid PGM header");
}

int main(int argc, char** argv) try {
    std::string input, output, stages_dump;
    int iterations=100, warmup=10; float low=50, high=100, sigma=1.4f;

    // Read options: input, output, how many runs to time, and Canny parameters.
    for(int a=1;a<argc;a+=2) {
        if(a+1==argc) throw std::runtime_error("Missing option value");
        std::string k=argv[a], v=argv[a+1];
        if(k=="--input") input=v; else if(k=="--output") output=v;
        else if(k=="--stages-dump") stages_dump=v;
        else if(k=="--iterations") iterations=std::stoi(v);
        else if(k=="--warmup") warmup=std::stoi(v);
        else if(k=="--low") low=std::stof(v); else if(k=="--high") high=std::stof(v);
        else if(k=="--sigma") sigma=std::stof(v); else throw std::runtime_error("Unknown option "+k);
    }
    if(iterations<1 || warmup<0 || !std::isfinite(sigma) || sigma<=0 ||
       !std::isfinite(low) || !std::isfinite(high) || low<0 || high<=low)
        throw std::runtime_error("Invalid iteration count or parameters");

    // Read image: binary P5 grayscale PGM, at least 5x5, into one uint8 buffer.
    std::ifstream in(input,std::ios::binary);
    if(token(in)!="P5") throw std::runtime_error("Expected binary PGM");
    int w=std::stoi(token(in)), h=std::stoi(token(in));
    if(token(in)!="255" || w<5 || h<5) throw std::runtime_error("Expected >=5x5 uint8 PGM");
    char separator; in.get(separator);
    if(separator=='\r' && in.peek()=='\n') in.get();
    size_t n=size_t(w)*h;
    std::vector<uint8_t> image(n), edges(n), labels(n);
    in.read(reinterpret_cast<char*>(image.data()),std::streamsize(n));
    if(size_t(in.gcount())!=n) throw std::runtime_error("Truncated image");

    // Buffers reused across iterations. Allocated here so the timed loop does not allocate.
    std::vector<float> blur(n), mag(n), angle(n), suppressed(n);
    std::vector<size_t> queue; queue.reserve(n);

    // Gaussian kernel: 5x5 weights from sigma, then divided so they sum to 1.
    float weights[5][5], sum=0;
    for(int y=-2;y<=2;++y) for(int x=-2;x<=2;++x) {
        weights[y+2][x+2]=std::exp(-(x*x+y*y)/(2*sigma*sigma)); sum+=weights[y+2][x+2];
    }
    for(auto& row:weights) for(float& x:row) x/=sum;
    auto reflect = [](int p, int length) {
        while (p < 0 || p >= length)
            p = p < 0 ? -p : 2 * length - 2 - p;
        return p;
    };

    // Timed loop. Negative iterations are warmup and are not recorded.
    // ms[] is the steady_clock stage split. The four Sobel fields are the lab clock.
    struct Sample {
        std::array<double, 6> ms;
        double rdtsc_cycles;
        double turbo_cycles;
        double cycles_per_pixel;
        double flops_per_cycle;
    };
    std::vector<Sample> samples;
    const double pixels = double(w) * double(h);
    for(int it=-warmup;it<iterations;++it) {
        std::array<Clock::time_point,6> t; t[0]=Clock::now();

        // Gaussian blur: smooth the image to reduce noise.
        // Out-of-range samples are reflected. Each result is quantized to uint8.
        for(int y=0;y<h;++y) for(int x=0;x<w;++x) {
            float value=0;
            for(int j=-2;j<=2;++j) for(int k=-2;k<=2;++k)
                value+=weights[j+2][k+2]*image[size_t(reflect(y+j,h))*w+reflect(x+k,w)];
            // Quantize blurred image to uint8, as in the OpenCV baseline.
            blur[size_t(y)*w+x]=std::clamp(std::floor(value+0.5f),0.0f,255.0f);
        }
        t[1]=Clock::now();

        // Part 2 kernel start. Reads blur. Writes mag and angle.
        // RDTSC wraps only this call. Milliseconds below still use steady_clock.
        unsigned long long c0 = rdtsc();
        sobel_kernel(w, h, blur.data(), mag.data(), angle.data());
        unsigned long long c1 = rdtsc();
        // Part 2 kernel end.
        t[2]=Clock::now();
        // latency_simd_fma.c: cycles = MAX_FREQ/BASE_FREQ * rdtsc / outputs.
        // kernel_driver.c:    flops/cycle = flops / (rdtsc * MAX_FREQ/BASE_FREQ).
        const double rdtsc_cycles = double(c1 - c0);
        const double turbo_cycles = rdtsc_cycles * MAX_FREQ / BASE_FREQ;
        const double cycles_per_pixel = turbo_cycles / pixels;
        const double flops_per_cycle = (SOBEL_FLOPS_PER_PIXEL * pixels) / turbo_cycles;

        // Part 3. Suppress gradient pixels that are not a ridge along their direction.
        // Clear every output first. A pixel left at 0 was rejected. The border stays 0.
        std::fill(suppressed.begin(), suppressed.end(), 0);

        // Interior rows only. The first and last rows have no full neighbor pair.
        for (int y = 1; y < h - 1; ++y) {
            // Interior columns only. The first and last columns stay at the 0 written above.
            for (int x = 1; x < w - 1; ++x) {
                // Row-major index of this interior pixel.
                size_t i = size_t(y) * w + x;
                // Direction, in degrees, that part 2 wrote into angle for this pixel.
                float d = angle[i];
                // One neighbor along the gradient. The branch below chooses which pixel.
                size_t a;
                // The neighbor on the opposite side of the gradient.
                size_t b;

                // Direction near 0 or 180 degrees. The gradient is horizontal, so read left and right.
                if (d < 22.5f || d >= 157.5f) {
                    a = i - 1; // pixel to the left
                    b = i + 1; // pixel to the right
                // Direction near 45 degrees. Read the up-left and down-right neighbors.
                } else if (d < 67.5f) {
                    a = i - w - 1; // one row up, one column left
                    b = i + w + 1; // one row down, one column right
                // Direction near 90 degrees. The gradient is vertical, so read above and below.
                } else if (d < 112.5f) {
                    a = i - w; // pixel one row above
                    b = i + w; // pixel one row below
                // Direction near 135 degrees. Read the up-right and down-left neighbors.
                } else {
                    a = i - w + 1; // one row up, one column right
                    b = i + w - 1; // one row down, one column left
                }

                // Read the three magnitudes. Keep this one only when it is strictly above a
                // and at least b. That writes suppressed[i]. Otherwise the 0 from the fill remains.
                if (mag[i] > mag[a] && mag[i] >= mag[b])
                    suppressed[i] = mag[i];
            }
        }
        t[3]=Clock::now();

        // Double threshold: 2 = strong, 1 = weak, 0 = rejected.
        for(size_t i=0;i<n;++i) labels[i]=suppressed[i]>high?2:(suppressed[i]>low?1:0);
        t[4]=Clock::now();

        // Hysteresis: keep weak pixels that connect, through other weak pixels, to a strong edge.
        hysteresis(labels,w,h,edges,queue);
        t[5]=Clock::now();

        // Timing: one pipeline total plus the five stage times, for recorded iterations only.
        if(it>=0) {
            Sample row;
            row.ms[0]=ms(t[0],t[5]);
            for(int s=0;s<5;++s)
                row.ms[s+1]=ms(t[s],t[s+1]);
            row.rdtsc_cycles = rdtsc_cycles;
            row.turbo_cycles = turbo_cycles;
            row.cycles_per_pixel = cycles_per_pixel;
            row.flops_per_cycle = flops_per_cycle;
            samples.push_back(row);
        }
    }

    // Optional mag/angle/NMS dump. After the timed loop, so it is not a sample.
    if (!stages_dump.empty())
        write_stages_dump(stages_dump, w, h, mag, angle, suppressed);

    // Write output: binary PGM edge map. Kept pixels are 255, the rest are 0.
    std::ofstream out(output,std::ios::binary); out<<"P5\n"<<w<<" "<<h<<"\n255\n";
    out.write(reinterpret_cast<char*>(edges.data()),std::streamsize(n));
    if(!out) throw std::runtime_error("Could not write output");

    // Timing report: one JSON object on stdout. File I/O above is not included in the samples.
    // Millisecond fields stay. Sobel also reports the lab RDTSC measurement.
    auto json_num = [](double value) {
        std::cout << std::setprecision(17) << value;
    };
    std::cout<<"{\"timing_method\":\"steady_clock instrumented pipeline; allocations and I/O excluded; sobel also rdtsc * MAX_FREQ/BASE_FREQ\",\"samples\":[";
    for(size_t i=0;i<samples.size();++i) {
        if(i) std::cout<<",";
        std::cout<<"{\"compute_ms\":"<<samples[i].ms[0]<<",\"e2e_ms\":"<<samples[i].ms[0];
        const char* names[]={"blur_ms","sobel_ms","nms_ms","threshold_ms","hysteresis_ms"};
        for(int s=0;s<5;++s) std::cout<<",\""<<names[s]<<"\":"<<samples[i].ms[s+1];
        std::cout<<",\"sobel_rdtsc_cycles\":"; json_num(samples[i].rdtsc_cycles);
        std::cout<<",\"sobel_turbo_cycles\":"; json_num(samples[i].turbo_cycles);
        std::cout<<",\"sobel_cycles_per_pixel\":"; json_num(samples[i].cycles_per_pixel);
        std::cout<<",\"sobel_flops_per_cycle\":"; json_num(samples[i].flops_per_cycle);
        std::cout<<",\"sobel_threshold_cycles_per_pixel\":"; json_num(THRESHOLD_CYCLES_PER_PIXEL);
        std::cout<<",\"sobel_threshold_flops_per_cycle\":"; json_num(THRESHOLD_FLOPS_PER_CYCLE);
        std::cout<<"}";
    }
    std::cout<<"]}\n";
    // Fallback count is not part of the JSON timing object.
    std::cerr << "sobel_fallback_lanes " << sobel_fallback_lanes() << "\n";
    return 0;
} catch(const std::exception& e) {std::cerr<<e.what()<<"\n";return 1;}
