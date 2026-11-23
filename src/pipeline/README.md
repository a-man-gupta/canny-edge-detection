# Tiled OpenMP pipeline

1. **Distribute tiles.** A static OpenMP loop gives workers disjoint output rectangles, up to 64 rows × 320 columns. Each worker owns scratch storage. Pixels within a row are contiguous, so adjacent SIMD lanes read adjacent columns.
2. **Keep intermediates local.** Five horizontal Gaussian rows rotate in a ring. Twelve blurred rows supply ten Sobel rows. Eight interior rows feed NMS, with one gradient halo above and below. Four blurred rows carry over to the next block. Fused NMS and threshold write only byte labels to the full image.
3. **Track edges in parallel.** Once labels and their zero border are complete, each worker owns a contiguous horizontal slab and a private work queue. A barrier makes every local edge map available before workers inspect neighboring slabs.
4. **Reconnect edges.** Workers append seam candidates to a shared frontier in a critical section. After the parallel region, one queue completes paths that cross one or more slab boundaries.

At 320 columns the tall variant uses about 42,048 bytes of principal scratch per worker. Each physical core has 32 KiB L1D and 1 MiB L2. The width sweep favored 320 for filter time among the tested choices; the working set spans cache levels. The integrated pipeline has no single ALU peak because the number of queue visits depends on the input.

| Physical cores | Native 4K Apollo latency (ms) |
|---:|---:|
| 1 | 24.629 |
| 2 | 13.532 |
| 4 | 7.791 |
| 8 | 4.579 |
| 16 | 2.735 |

The driver times the whole pipeline, including scratch allocation and seam propagation. Sixteen cores span two sockets.

[Source](canny_tiled.cpp) · [Worker assembly](../../assembly/tiled.asm) · [Latency graph](../../benchmarks/fusion/audit/Canny-latency-by-size-bars.png) · [Scaling plots and worked examples](../../benchmarks/fusion/audit/Canny-performance.pdf).
