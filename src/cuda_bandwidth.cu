// Large working-set logical triad throughput + pinned PCIe copy throughput.
// Logical bytes are not hardware-counter DRAM traffic.
#include <cuda_runtime.h>
#include <algorithm>
#include <chrono>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <vector>
static void check(cudaError_t e) {if(e!=cudaSuccess){std::fprintf(stderr,"CUDA: %s\n",cudaGetErrorString(e));std::exit(1);}}
__global__ void triad(float* c,const float* a,const float* b,size_t n) {
    for(size_t i=blockIdx.x*size_t(blockDim.x)+threadIdx.x;i<n;i+=size_t(blockDim.x)*gridDim.x) c[i]=a[i]+2.0f*b[i];
}
static double percentile(std::vector<double> v,double p) {
    std::sort(v.begin(),v.end());double x=p*(v.size()-1);size_t lo=size_t(x),hi=std::min(lo+1,v.size()-1);
    return v[lo]+(x-lo)*(v[hi]-v[lo]);
}
int main(int argc,char** argv) {
    // Positional args: MiB per array, iterations. Three arrays allocated on device.
    size_t mib=argc>1?std::strtoull(argv[1],nullptr,10):256;
    int iterations=argc>2?std::atoi(argv[2]):100;
    if(mib<1 || mib>65536 || iterations<1){std::fprintf(stderr,"Usage: cuda_bandwidth [MiB-per-array 1..65536] [iterations > 0]\n");return 2;}
    check(cudaSetDevice(0));cudaDeviceProp p;check(cudaGetDeviceProperties(&p,0));
    size_t bytes=mib*1024*1024,n=bytes/sizeof(float),freeBytes,totalBytes;
    check(cudaMemGetInfo(&freeBytes,&totalBytes));
    if(bytes>freeBytes/4){std::fprintf(stderr,"Insufficient VRAM: need 3 arrays and safety headroom\n");return 1;}
    if(3*bytes<=size_t(p.l2CacheSize)*4){std::fprintf(stderr,"Increase array size: require working set > 4x L2\n");return 1;}
    float *a,*b,*c,*host;check(cudaMalloc(&a,bytes));check(cudaMalloc(&b,bytes));check(cudaMalloc(&c,bytes));
    check(cudaMallocHost(&host,bytes));std::fill(host,host+n,1.0f);
    check(cudaMemcpy(a,host,bytes,cudaMemcpyHostToDevice));check(cudaMemcpy(b,host,bytes,cudaMemcpyHostToDevice));
    cudaStream_t stream;check(cudaStreamCreate(&stream));cudaEvent_t start,stop;check(cudaEventCreate(&start));check(cudaEventCreate(&stop));
    auto measure=[&](const char* mode) {
        std::vector<double> device,wall;
        for(int i=-10;i<iterations;++i){
            auto t=std::chrono::steady_clock::now();check(cudaEventRecord(start,stream));
            if(mode[0]=='t') {triad<<<p.multiProcessorCount*32,256,0,stream>>>(c,a,b,n);check(cudaGetLastError());}
            else if(mode[0]=='h') check(cudaMemcpyAsync(a,host,bytes,cudaMemcpyHostToDevice,stream));
            else check(cudaMemcpyAsync(host,c,bytes,cudaMemcpyDeviceToHost,stream));
            check(cudaEventRecord(stop,stream));check(cudaEventSynchronize(stop));float elapsed;check(cudaEventElapsedTime(&elapsed,start,stop));
            double wallms=std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-t).count();
            if(i>=0){device.push_back(elapsed);wall.push_back(wallms);}
        }
        double traffic=mode[0]=='t'?3.0*bytes:double(bytes);
        for(size_t i=0;i<device.size();++i)std::printf("sample,%s,%zu,%.8f,%.8f\n",mode,i,device[i],wall[i]);
        std::fprintf(stderr,"%s: median CUDA-event ms %.6f; p95 ms %.6f; effective logical GB/s %.3f\n",mode,percentile(device,.5),percentile(device,.95),traffic/percentile(device,.5)/1e6);
    };
    std::fprintf(stderr,"Device %s; array bytes %zu; L2 bytes %d; logical triad footprint %zu; iterations %d\n",p.name,bytes,p.l2CacheSize,3*bytes,iterations);
    std::printf("record,mode,iteration,cuda_event_ms,host_wall_ms\n");
    measure("triad");measure("h2d");measure("d2h");
    // Verify output, outside timing. a,b were initialized to one.
    if(!std::all_of(host,host+n,[](float x){return x==3.0f;})){std::fprintf(stderr,"Validation failed\n");return 1;}
    check(cudaEventDestroy(start));check(cudaEventDestroy(stop));check(cudaStreamDestroy(stream));
    check(cudaFree(a));check(cudaFree(b));check(cudaFree(c));check(cudaFreeHost(host));return 0;
}
