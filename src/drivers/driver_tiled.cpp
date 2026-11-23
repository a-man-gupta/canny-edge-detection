#include "../pipeline/canny_tiled.hpp"
#include "../reference/hysteresis.hpp"
#include <omp.h>
#include <algorithm>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <cstdio>
#include <random>
#include <string>
#include <vector>

using Bytes = std::vector<uint8_t>;

static void reference(const Bytes &src, Bytes &labels, Bytes &edges, int w, int h,
                      GaussQ15 q, int low, int high) {
    Bytes blur(src.size());
    gaussian_ref_q(w,h,src.data(),blur.data(),q);
    std::vector<int16_t> mag(src.size()), gx(src.size()), gy(src.size());
    for (int y=0;y<h;++y) for (int x=0;x<w;++x) {
        auto pixel=[&](int dy,int dx) {
            return int(blur[size_t(std::clamp(y+dy,0,h-1))*w+std::clamp(x+dx,0,w-1)]);
        };
        size_t p=size_t(y)*w+x;
        gx[p]=pixel(-1,1)-pixel(-1,-1)+2*(pixel(0,1)-pixel(0,-1))+pixel(1,1)-pixel(1,-1);
        gy[p]=pixel(1,-1)+2*pixel(1,0)+pixel(1,1)-pixel(-1,-1)-2*pixel(-1,0)-pixel(-1,1);
        mag[p]=std::abs(gx[p])+std::abs(gy[p]);
    }
    std::fill(labels.begin(),labels.end(),0);
    for (int y=1;y<h-1;++y) for (int x=1;x<w-1;++x) {
        size_t p=size_t(y)*w+x;
        int ax=std::abs(gx[p]), ay=std::abs(gy[p]), t=ax*27146/65536;
        int first=-1,second=1;
        if (ay>t+2*ax) { first=-w; second=w; }
        else if (ay>t) { first=-w+((gx[p]<0)!=(gy[p]<0) ? 1 : -1); second=-first; }
        if (mag[p]>mag[p+first] && mag[p]>=mag[p+second])
            labels[p]=(mag[p]>low)+(mag[p]>high);
    }
    std::vector<size_t> queue;
    hysteresis(labels,w,h,edges,queue);
}

int main(int argc,char **argv) {
    if (argc<7 || argc>9) { std::fprintf(stderr,"usage: driver width height threads strip trials noise|ramp|flat|gray8-file [row|morton|staged] [edge-file]\n"); return 2; }
    int w=std::atoi(argv[1]),h=std::atoi(argv[2]),threads=std::atoi(argv[3]);
    int strip=std::atoi(argv[4]),trials=std::atoi(argv[5]);
    if (w<5 || h<5 || threads<1 || trials<1) return 2;
    omp_set_dynamic(0); omp_set_num_threads(threads);
    Bytes src(size_t(w)*h), expected(src.size()), labels(src.size()), edges(src.size()), truth(src.size());
    std::mt19937 rng(18645);
    bool noise=std::strcmp(argv[6],"noise")==0, flat=std::strcmp(argv[6],"flat")==0;
    if (noise || flat || std::strcmp(argv[6],"ramp")==0) {
        for(int y=0;y<h;++y) for(int x=0;x<w;++x)
            src[size_t(y)*w+x]=noise ? rng()%256 : flat ? 87 : (x/23+y/17)%2*160+(x+y)%64;
    } else {
        std::ifstream file(argv[6],std::ios::binary);
        if (!file.read(reinterpret_cast<char*>(src.data()),src.size()) || file.peek()!=EOF) {
            std::fprintf(stderr,"expected exactly width x height grayscale bytes in %s\n",argv[6]);
            return 2;
        }
    }
    const char *name=argc>=8 ? argv[7] : "row";
    FusionMode mode=FusionMode::row;
    if(std::strcmp(name,"staged")==0) mode=FusionMode::staged;
    else if(std::strcmp(name,"morton")==0) mode=FusionMode::morton;
    else if(std::strcmp(name,"row")!=0) return 2;
    GaussQ15 q=gaussian_q15(1.0f);
    std::vector<double> scalar;
    for (int i=-1;i<std::min(3,trials);++i) {
        auto start=omp_get_wtime();
        reference(src,expected,truth,w,h,q,60,120);
        if(i>=0) scalar.push_back((omp_get_wtime()-start)*1000);
    }
    std::sort(scalar.begin(),scalar.end());
    double ref=scalar[scalar.size()/2];
    struct Sample { double total,filter,track; };
    std::vector<Sample> samples;
    for (int i=-1;i<trials;++i) {
        double f,t;
        canny_tiled(src.data(),labels.data(),edges.data(),w,h,q,60,120,strip,f,t,mode,std::getenv("CANNY_MASK_SEEDS")!=nullptr);
        if (labels!=expected || edges!=truth) {
            auto &obs=labels!=expected ? labels : edges;
            auto &exp=labels!=expected ? expected : truth;
            size_t p=std::mismatch(obs.begin(),obs.end(),exp.begin()).first-obs.begin();
            std::fprintf(stderr,"FAIL %s (%zu,%zu) got %u expected %u\n",&obs==&labels?"labels":"edges",p%w,p/w,obs[p],exp[p]);return 1;
        }
        if(i>=0) samples.push_back({f+t,f,t});
    }
    std::sort(samples.begin(),samples.end(),[](auto a,auto b){return a.total<b.total;});
    // Optional perf stat control: count only 32 warmed end-to-end calls.
    if (const char *control=std::getenv("CANNY_PERF_CTL")) {
        const char *ack_path=std::getenv("CANNY_PERF_ACK");
        if(!ack_path) return 2;
        std::ofstream ctl(control);
        std::ifstream ack(ack_path);
        auto command=[&](const char *cmd) {
            std::string reply;
            ctl << cmd << std::endl;
            if (!ctl || !std::getline(ack,reply)) return false;
            // Some perf versions append a NUL after the newline of the prior reply.
            auto start=reply.find_first_not_of(char(0));
            return start!=std::string::npos && reply.substr(start)=="ack";
        };
        if(!command("enable")) return 2;
        for(int i=0;i<32;++i) {
            double f,t;
            canny_tiled(src.data(),labels.data(),edges.data(),w,h,q,60,120,strip,f,t,mode,
                        std::getenv("CANNY_MASK_SEEDS")!=nullptr);
        }
        if(!command("disable")) { std::fprintf(stderr,"perf disable acknowledgement failed\n"); return 2; }
        if(labels!=expected || edges!=truth) { std::fprintf(stderr,"profile output mismatch\n"); return 1; }
    }
    if(argc==9) {
        std::ofstream out(argv[8],std::ios::binary);
        if (!out.write(reinterpret_cast<const char*>(edges.data()),edges.size())) return 1;
    }
    for(auto s:samples) std::printf("trial %.6f %.6f %.6f\n",s.total,s.filter,s.track);
    auto m=samples[samples.size()/2];
    std::printf("%dx%d %s threads=%d strip=%d scalar_ms=%.3f filter_ms=%.3f track_ms=%.3f total_ms=%.3f MPix/s=%.1f exact\n",
                w,h,argv[6],threads,strip,ref,m.filter,m.track,m.total,w*double(h)/1000/m.total);
}
