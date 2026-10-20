#pragma once
#include <algorithm>
#include <cstddef>
#include <cstdint>
#include <vector>

// Hysteresis. labels: 0 rejected, 1 weak, 2 strong.
// edges and queue are caller-owned and already sized. Output pixels are 0 or 255.
inline void hysteresis(const std::vector<uint8_t>& labels, int w, int h,
                       std::vector<uint8_t>& edges, std::vector<size_t>& queue) {
    // Start from a cleared edge map and an empty queue.
    queue.clear();
    std::fill(edges.begin(),edges.end(),0);

    // Seed: every strong pixel is an edge and a place to grow from.
    for(size_t i=0;i<labels.size();++i) if(labels[i]==2) {edges[i]=255;queue.push_back(i);}

    // Track: a weak neighbor of a kept edge is kept too, including long chains.
    for(size_t head=0;head<queue.size();++head) {
        size_t i=queue[head]; int y=int(i/w),x=int(i%w);
        for(int j=-1;j<=1;++j) for(int k=-1;k<=1;++k) {
            if(y+j<0 || y+j>=h || x+k<0 || x+k>=w) continue;
            size_t neighbor=size_t(y+j)*w+x+k;
            if(labels[neighbor]==1 && !edges[neighbor]) {edges[neighbor]=255;queue.push_back(neighbor);}
        }
    }
}
