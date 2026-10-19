// Optional library reference. Requires an OpenCV C++ build with CUDA contrib modules.
#include <opencv2/core/cuda.hpp>
#include <opencv2/core/cuda_stream_accessor.hpp>
#include <opencv2/cudafilters.hpp>
#include <opencv2/cudaimgproc.hpp>
#include <opencv2/imgcodecs.hpp>
#include <cuda_runtime_api.h>
#include <chrono>
#include <cmath>
#include <iostream>
#include <map>
#include <stdexcept>
#include <string>
#include <array>
#include <vector>
static void check(cudaError_t e) { if(e!=cudaSuccess) throw std::runtime_error(cudaGetErrorString(e)); }
struct Events {
    std::array<cudaEvent_t,5> e{};
    Events() {for(auto& event:e) check(cudaEventCreate(&event));}
    ~Events() {for(auto event:e) if(event) cudaEventDestroy(event);}
    double elapsed(int a,int b) {float t;check(cudaEventElapsedTime(&t,e[a],e[b]));return t;}
};
int main(int argc,char** argv) try {
    std::map<std::string,std::string> args;
    for(int i=1;i<argc;i+=2) {if(i+1==argc) throw std::runtime_error("Missing value");args[argv[i]]=argv[i+1];}
    int iterations=std::stoi(args.at("--iterations")), warmup=std::stoi(args.at("--warmup"));
    double low=std::stod(args.at("--low")),high=std::stod(args.at("--high")),sigma=std::stod(args.at("--sigma"));
    if(iterations<1 || warmup<0 || !std::isfinite(sigma) || sigma<=0 ||
       !std::isfinite(low) || !std::isfinite(high) || low<0 || high<=low) throw std::runtime_error("Invalid parameters");
    std::cerr << cv::getBuildInformation() << "\nCompiler: " << __VERSION__ << "\n";
    cv::cuda::setDevice(0); // Select physical GPU through CUDA_VISIBLE_DEVICES.
    cv::Mat image=cv::imread(args.at("--input"),cv::IMREAD_GRAYSCALE);
    if(image.empty()) throw std::runtime_error("Cannot read image");
    cv::cuda::HostMem hostIn(image.rows,image.cols,CV_8UC1,cv::cuda::HostMem::PAGE_LOCKED);
    cv::cuda::HostMem hostOut(image.rows,image.cols,CV_8UC1,cv::cuda::HostMem::PAGE_LOCKED);
    cv::Mat input=hostIn.createMatHeader(), output=hostOut.createMatHeader();image.copyTo(input);
    cv::cuda::GpuMat deviceIn(image.size(),CV_8UC1),blurred(image.size(),CV_8UC1),edges(image.size(),CV_8UC1);
    auto blur=cv::cuda::createGaussianFilter(CV_8UC1,CV_8UC1,cv::Size(5,5),sigma,sigma,cv::BORDER_REFLECT_101);
    auto canny=cv::cuda::createCannyEdgeDetector(low,high,3,true);
    cv::cuda::Stream stream; auto raw=cv::cuda::StreamAccessor::getStream(stream); Events events;
    std::vector<std::array<double,6>> rows;
    for(int i=-warmup;i<iterations;++i) {
        auto start=std::chrono::steady_clock::now();
        check(cudaEventRecord(events.e[0],raw));deviceIn.upload(input,stream);
        check(cudaEventRecord(events.e[1],raw));blur->apply(deviceIn,blurred,stream);
        check(cudaEventRecord(events.e[2],raw));canny->detect(blurred,edges,stream);
        check(cudaEventRecord(events.e[3],raw));edges.download(output,stream);
        check(cudaEventRecord(events.e[4],raw));check(cudaEventSynchronize(events.e[4]));
        double wall=std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-start).count();
        if(i>=0) rows.push_back({wall,events.elapsed(1,3),events.elapsed(0,1),events.elapsed(1,2),events.elapsed(2,3),events.elapsed(3,4)});
    }
    if(!cv::imwrite(args.at("--output"),output)) throw std::runtime_error("Cannot write output");
    std::cout<<"{\"timing_method\":\"CUDA events on explicit stream; e2e steady_clock + synchronize; pinned transfers; preallocated outer buffers\",\"samples\":[";
    for(size_t i=0;i<rows.size();++i) {if(i) std::cout<<",";std::cout<<"{";
        const char* keys[]={"e2e_ms","compute_ms","h2d_ms","blur_ms","canny_ms","d2h_ms"};
        for(int j=0;j<6;++j) {if(j) std::cout<<",";std::cout<<"\""<<keys[j]<<"\":"<<rows[i][j];}std::cout<<"}";}
    std::cout<<"]}\n";return 0;
} catch(const std::exception& e) {std::cerr<<e.what()<<"\n";return 1;}
