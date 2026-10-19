#include <cuda_runtime.h>
#include <cstdio>
#include <cstdlib>
static void check(cudaError_t e) {if(e!=cudaSuccess){std::fprintf(stderr,"CUDA: %s\n",cudaGetErrorString(e));std::exit(1);}}
int main() {
    int count=0;check(cudaGetDeviceCount(&count));
    if(!count){std::puts("No CUDA devices visible");return 1;}
    int driver,runtime;check(cudaDriverGetVersion(&driver));check(cudaRuntimeGetVersion(&runtime));
    std::printf("CUDA driver API version: %d; runtime: %d\n",driver,runtime);
    for(int i=0;i<count;++i) {
        cudaDeviceProp p;check(cudaGetDeviceProperties(&p,i));int memClock=0,optin=0;
        check(cudaDeviceGetAttribute(&memClock,cudaDevAttrMemoryClockRate,i));
        check(cudaDeviceGetAttribute(&optin,cudaDevAttrMaxSharedMemoryPerBlockOptin,i));
        std::printf("\nDevice %d: %s; CC %d.%d; SMs %d\n",i,p.name,p.major,p.minor,p.multiProcessorCount);
        char bus[32];check(cudaDeviceGetPCIBusId(bus,sizeof(bus),i));std::printf("PCI bus ID: %s\n",bus);
        std::printf("Warp size: %d; threads/SM: %d; threads/block: %d\n",p.warpSize,p.maxThreadsPerMultiProcessor,p.maxThreadsPerBlock);
        std::printf("Block dimensions: %d %d %d; grid dimensions: %d %d %d\n",p.maxThreadsDim[0],p.maxThreadsDim[1],p.maxThreadsDim[2],p.maxGridSize[0],p.maxGridSize[1],p.maxGridSize[2]);
        std::printf("32-bit registers/block: %d; registers/SM: %d\n",p.regsPerBlock,p.regsPerMultiprocessor);
        std::printf("Registers/thread are kernel/compiler-dependent; inspect ptxas -v and occupancy.\n");
        std::printf("Shared bytes/block: %zu; opt-in bytes/block: %d; bytes/SM: %zu\n",p.sharedMemPerBlock,optin,p.sharedMemPerMultiprocessor);
        std::printf("Constant bytes: %zu; L2 bytes: %d; VRAM bytes: %zu\n",p.totalConstMem,p.l2CacheSize,p.totalGlobalMem);
        std::printf("Memory clock kHz (reported): %d; bus width bits: %d\n",memClock,p.memoryBusWidth);
        std::printf("DDR-style nominal bandwidth estimate GB/s: %.3f (not a measurement; validate memory technology/clock convention)\n",2.0*memClock*1000*(p.memoryBusWidth/8.0)/1e9);
    }
}
