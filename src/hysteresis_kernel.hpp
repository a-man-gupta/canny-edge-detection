#pragma once
#include <cstddef>
#include <cstdint>
#include <vector>

// Hysteresis on double-threshold labels (0 rejected, 1 weak, 2 strong). Writes edges (0 or 255)
// with the same result as hysteresis() in hysteresis.hpp: strong pixels, plus weak pixels joined
// to a strong pixel through 8-connected weak pixels. queue is caller-owned scratch (reserve w*h
// to keep allocation out of timing). Arrays have w*h elements and do not overlap.
//
// Two passes. The vector pass writes 255 for strong and 0 for everything else, and finds the
// seeds: weak pixels with a strong 8-neighbor. The queue pass grows from the seeds through weak
// pixels, like the scalar loop, but starts only from seeds instead of from every strong pixel.
void hysteresis_kernel(int w, int h, const uint8_t *labels, uint8_t *edges,
                       std::vector<size_t> &queue);

// Hot loop of the vector pass (256-bit AVX2 vectors, AVX-512VL vpternlogd for 3-input logic):
// a block of 4 rows, 32 columns per iteration. labels and edges point at the first of the 4 rows;
// rows -1 and 4 are read too. Columns [begin, begin+n) are done; n is a multiple of 32,
// begin >= 1 and begin+n < width. For every 4x32 block holding at least one seed, the column
// of its first pixel is written to hits; the return value is the number of hits. Labels
// above 2 are not allowed. Repetition is inside the function so timing has no per-call overhead.
extern "C" long hysteresis_rows4_repeat(const uint8_t *labels, uint8_t *edges, long stride,
                                        long begin, long n, uint32_t *hits, long reps);
// The same for one row (rows left over after the blocks of 4).
extern "C" long hysteresis_rows1_repeat(const uint8_t *labels, uint8_t *edges, long stride,
                                        long begin, long n, uint32_t *hits, long reps);
