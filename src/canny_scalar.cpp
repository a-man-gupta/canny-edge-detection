// Team-owned scalar reference. See benchmarks/README.md for the algorithm contract.
#include "hysteresis.hpp"
#include <algorithm>
#include <array>
#include <chrono>
#include <cmath>
#include <cstdint>
#include <fstream>
#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>
using Clock = std::chrono::steady_clock;
static double ms(Clock::time_point a, Clock::time_point b) {
    return std::chrono::duration<double, std::milli>(b-a).count();
}
static std::string token(std::istream& in) {
    std::string s;
    while(in >> s) { if(s[0]!='#') return s; std::getline(in,s); }
    throw std::runtime_error("Invalid PGM header");
}
int main(int argc, char** argv) try {
    std::string input, output;
    int iterations=100, warmup=10; float low=50, high=100, sigma=1.4f;
    for(int a=1;a<argc;a+=2) {
        if(a+1==argc) throw std::runtime_error("Missing option value");
        std::string k=argv[a], v=argv[a+1];
        if(k=="--input") input=v; else if(k=="--output") output=v;
        else if(k=="--iterations") iterations=std::stoi(v);
        else if(k=="--warmup") warmup=std::stoi(v);
        else if(k=="--low") low=std::stof(v); else if(k=="--high") high=std::stof(v);
        else if(k=="--sigma") sigma=std::stof(v); else throw std::runtime_error("Unknown option "+k);
    }
    if(iterations<1 || warmup<0 || !std::isfinite(sigma) || sigma<=0 ||
       !std::isfinite(low) || !std::isfinite(high) || low<0 || high<=low)
        throw std::runtime_error("Invalid iteration count or parameters");
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
    std::vector<float> blur(n), mag(n), angle(n), suppressed(n);
    std::vector<size_t> queue; queue.reserve(n);
    float weights[5][5], sum=0;
    for(int y=-2;y<=2;++y) for(int x=-2;x<=2;++x) {
        weights[y+2][x+2]=std::exp(-(x*x+y*y)/(2*sigma*sigma)); sum+=weights[y+2][x+2];
    }
    for(auto& row:weights) for(float& x:row) x/=sum;
    auto reflect=[](int p,int length) { while(p<0 || p>=length) p=p<0?-p:2*length-2-p; return p; };
    std::vector<std::array<double,6>> samples;
    for(int it=-warmup;it<iterations;++it) {
        std::array<Clock::time_point,6> t; t[0]=Clock::now();
        for(int y=0;y<h;++y) for(int x=0;x<w;++x) {
            float value=0;
            for(int j=-2;j<=2;++j) for(int k=-2;k<=2;++k)
                value+=weights[j+2][k+2]*image[size_t(reflect(y+j,h))*w+reflect(x+k,w)];
            // Quantize blurred image to uint8, as in the OpenCV baseline.
            blur[size_t(y)*w+x]=std::clamp(std::floor(value+0.5f),0.0f,255.0f);
        }
        t[1]=Clock::now();
        for(int y=0;y<h;++y) for(int x=0;x<w;++x) {
            auto b=[&](int j,int k) {return blur[size_t(std::clamp(y+j,0,h-1))*w+std::clamp(x+k,0,w-1)];};
            float gx=-b(-1,-1)+b(-1,1)-2*b(0,-1)+2*b(0,1)-b(1,-1)+b(1,1);
            float gy=-b(-1,-1)-2*b(-1,0)-b(-1,1)+b(1,-1)+2*b(1,0)+b(1,1);
            size_t i=size_t(y)*w+x; mag[i]=std::sqrt(gx*gx+gy*gy);
            float degrees=std::atan2(gy,gx)*180.0f/3.14159265358979323846f;
            angle[i]=degrees<0?degrees+180:degrees;
        }
        t[2]=Clock::now(); std::fill(suppressed.begin(),suppressed.end(),0);
        for(int y=1;y<h-1;++y) for(int x=1;x<w-1;++x) {
            size_t i=size_t(y)*w+x; float d=angle[i]; size_t a,b;
            if(d<22.5f || d>=157.5f) { a=i-1;b=i+1; }
            else if(d<67.5f) { a=i-w-1;b=i+w+1; }
            else if(d<112.5f) { a=i-w;b=i+w; }
            else { a=i-w+1;b=i+w-1; }
            if(mag[i]>mag[a] && mag[i]>=mag[b]) suppressed[i]=mag[i];
        }
        t[3]=Clock::now();
        for(size_t i=0;i<n;++i) labels[i]=suppressed[i]>high?2:(suppressed[i]>low?1:0);
        t[4]=Clock::now(); hysteresis(labels,w,h,edges,queue);
        t[5]=Clock::now();
        if(it>=0) { std::array<double,6> row; row[0]=ms(t[0],t[5]);
            for(int s=0;s<5;++s) row[s+1]=ms(t[s],t[s+1]); samples.push_back(row); }
    }
    std::ofstream out(output,std::ios::binary); out<<"P5\n"<<w<<" "<<h<<"\n255\n";
    out.write(reinterpret_cast<char*>(edges.data()),std::streamsize(n));
    if(!out) throw std::runtime_error("Could not write output");
    std::cout<<"{\"timing_method\":\"steady_clock instrumented pipeline; allocations and I/O excluded\",\"samples\":[";
    for(size_t i=0;i<samples.size();++i) {
        if(i) std::cout<<",";
        std::cout<<"{\"compute_ms\":"<<samples[i][0]<<",\"e2e_ms\":"<<samples[i][0];
        const char* names[]={"blur_ms","sobel_ms","nms_ms","threshold_ms","hysteresis_ms"};
        for(int s=0;s<5;++s) std::cout<<",\""<<names[s]<<"\":"<<samples[i][s+1];
        std::cout<<"}";
    }
    std::cout<<"]}\n";
    return 0;
} catch(const std::exception& e) {std::cerr<<e.what()<<"\n";return 1;}
