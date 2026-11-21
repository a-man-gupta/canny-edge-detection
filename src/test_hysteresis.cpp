#include "hysteresis.hpp"
#include <iostream>
#include <stdexcept>

static void require(bool value,const char* msg){if(!value) throw std::runtime_error(msg);}

int main() try {
    const int w=1024,h=5;
    std::vector<uint8_t> labels(w*h,0), edges(w*h,255);std::vector<size_t> queue;queue.reserve(w*h);

    // A strong pixel at the left, then a weak chain across the whole row.
    labels[0]=2;
    for(int x=1;x<w;++x) labels[x]=1;
    labels[2*w-1]=1; // weak pixel touching that chain at the right border
    labels[4*w]=1; // isolated weak pixel, not connected to anything strong

    hysteresis(labels,w,h,edges,queue);

    // The chain and the border neighbor are kept. The isolated pixel is not.
    // The right border must not wrap into the next row.
    for(int x=0;x<w;++x) require(edges[x]==255,"Lost long connected chain");
    require(edges[2*w-1]==255,"Lost border-connected weak candidate");
    require(edges[4*w]==0,"Kept disconnected weak candidate");
    require(edges[2*w]==0,"Wrapped right border into next row");

    // Weak pixels with no strong seed produce an empty edge map.
    std::fill(labels.begin(),labels.end(),1);hysteresis(labels,w,h,edges,queue);
    require(std::all_of(edges.begin(),edges.end(),[](auto x){return x==0;}),"Weak-only map produced edges");

    // Every strong pixel is enqueued once.
    std::fill(labels.begin(),labels.end(),2);hysteresis(labels,w,h,edges,queue);
    require(queue.size()==labels.size(),"Duplicate or missing strong candidates");

    // A later call starts from an empty queue.
    std::fill(labels.begin(),labels.end(),0);hysteresis(labels,w,h,edges,queue);
    require(queue.empty(),"Queue persisted between runs");

    std::cout<<"Hysteresis connectivity, border, empty and state-reuse checks passed\n";return 0;
} catch(const std::exception& e){std::cerr<<e.what()<<"\n";return 1;}
