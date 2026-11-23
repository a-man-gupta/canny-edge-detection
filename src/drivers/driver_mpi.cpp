#include "../pipeline/canny_tiled.hpp"
#include "../kernels/hysteresis/hysteresis_kernel.hpp"
#include <mpi.h>
#include <algorithm>
#include <climits>
#include <cstdlib>
#include <cstdio>
#include <fstream>
#include <vector>

int main(int argc,char **argv) {
    int provided,rank,n;
    MPI_Init_thread(&argc,&argv,MPI_THREAD_FUNNELED,&provided);
    MPI_Comm_rank(MPI_COMM_WORLD,&rank);
    MPI_Comm_size(MPI_COMM_WORLD,&n);
    if(argc!=6 || provided<MPI_THREAD_FUNNELED) {
        if(!rank) std::fprintf(stderr,"usage: driver_mpi width height gray8 reference-edges trials\n");
        MPI_Abort(MPI_COMM_WORLD,2);
    }
    int w=std::atoi(argv[1]),h=std::atoi(argv[2]),trials=std::atoi(argv[5]);
    if(w<5 || h/n<5 || int64_t(w)*h>INT_MAX || trials<1) MPI_Abort(MPI_COMM_WORLD,2);
    std::vector<int> counts(n),offset(n);
    for(int r=0;r<n;++r) {
        offset[r]=int(int64_t(r)*h/n)*w;
        counts[r]=int(int64_t(r+1)*h/n)*w-offset[r];
    }
    int rows=counts[rank]/w, top=rank?4:0, bottom=rank+1<n?4:0;
    int prev=rank?rank-1:MPI_PROC_NULL,next=rank+1<n?rank+1:MPI_PROC_NULL;
    std::vector<uint8_t> slab(size_t(rows+top+bottom)*w), local(slab.size());
    uint8_t *owned=slab.data()+size_t(top)*w;
    size_t root_size=rank==0?size_t(w)*h:0;
    std::vector<uint8_t> input(root_size),labels(root_size),edges(root_size),ref(root_size);
    if(rank==0 && (!std::ifstream(argv[3],std::ios::binary).read((char*)input.data(),root_size)
                || !std::ifstream(argv[4],std::ios::binary).read((char*)ref.data(),root_size)))
        MPI_Abort(MPI_COMM_WORLD,2);
    auto q=gaussian_q15(1.f);
    std::vector<double> times;
    for(int i=-1;i<trials;++i) {
        MPI_Barrier(MPI_COMM_WORLD);
        double start=MPI_Wtime();
        MPI_Scatterv(input.data(),counts.data(),offset.data(),MPI_BYTE,owned,counts[rank],MPI_BYTE,0,MPI_COMM_WORLD);
        MPI_Sendrecv(owned,4*w,MPI_BYTE,prev,1,bottom?owned+counts[rank]:owned,4*w,MPI_BYTE,next,1,MPI_COMM_WORLD,MPI_STATUS_IGNORE);
        MPI_Sendrecv(owned+(rows-4)*w,4*w,MPI_BYTE,next,2,slab.data(),4*w,MPI_BYTE,prev,2,MPI_COMM_WORLD,MPI_STATUS_IGNORE);
        canny_slab_labels(slab.data(),local.data(),w,rows+top+bottom,top,rows,q);
        MPI_Gatherv(local.data()+size_t(top)*w,counts[rank],MPI_BYTE,labels.data(),
                    counts.data(),offset.data(),MPI_BYTE,0,MPI_COMM_WORLD);
        if(rank==0) {
            std::vector<size_t> queue;
            hysteresis_mask_kernel(w,h,labels.data(),edges.data(),queue);
        }
        double elapsed=(MPI_Wtime()-start)*1000,slowest;
        MPI_Reduce(&elapsed,&slowest,1,MPI_DOUBLE,MPI_MAX,0,MPI_COMM_WORLD);
        if(rank==0) {
            if(edges!=ref) { std::fprintf(stderr,"edge mismatch\n"); MPI_Abort(MPI_COMM_WORLD,1); }
            if(i>=0) times.push_back(slowest);
        }
    }
    if(rank==0) {
        std::sort(times.begin(),times.end());
        std::printf("%d ranks median %.3f ms; %d timed edge maps exact\n",n,times[times.size()/2],trials);
    }
    MPI_Finalize();
}
