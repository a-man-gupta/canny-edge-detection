#pragma once

#include <cstddef>
#include <cstdint>

// Part 1 kernel (gaussian_kernel.cpp): 5x5 Gaussian blur, AVX2 integer, uint8 in and uint8 out.
//
// Numeric contract (NOT the float blur of canny_scalar.cpp; see gaussian_ref_q):
//   X = pixel << 6                          (Q6, 0..16320)
//   M(a, c) = (a * c + 16384) >> 15         (vpmulhrsw), c is a Q15 weight
//   H = M(X0,c0) + M(X-1 + X+1, c1) + M(X-2 + X+2, c2)      horizontal, Q6, int16
//   Y = M(H0,c0) + M(H-1 + H+1, c1) + M(H-2 + H+2, c2)      vertical,   Q6, int16
//   out = clamp((Y + 32) >> 6, 0, 255)
// c0 + 2*c1 + 2*c2 = 32767, so a flat image is preserved and every pair sum stays below 32768.
// Borders reflect without repeating the edge sample (the scalar code's reflect()).
struct GaussQ15 {
  int16_t c0, c1, c2;
};

// Q15 weights of the 1-D Gaussian with the given sigma (taps -2..2), summing to exactly 32767.
GaussQ15 gaussian_q15(float sigma);

// Reusable buffers for one image width. Not thread-safe: one workspace per thread.
struct GaussianWork;
GaussianWork* gaussian_work_create(int w);
void gaussian_work_destroy(GaussianWork* work);

// Whole image, w >= 5 and h >= 5. in and out must not overlap.
void gaussian_u8(int w, int h, const uint8_t* in, uint8_t* out, const GaussQ15& q, GaussianWork* work);

// Same result through column strips (work created with gaussian_work_create(strip)); every strip but the
// last is `strip` wide, the last at least 4 wide. For images much wider than L1/L2 holds five rows of.
void gaussian_u8_strips(int w, int h, const uint8_t* in, uint8_t* out, const GaussQ15& q, GaussianWork* work,
                        int strip, int prefetch_rows);

// The three per-row phases, exposed so gaussian_driver can time them one by one.
// expand: uint8 row -> Q6 int16 row with the reflected 2-sample borders; scratch is
//         scratch_base(work) and receives samples -2..w+1 around sample 0.
// horiz:  Q6 int16 row (with borders) -> horizontal filter result, nv = ceil(w/16) vectors.
// vert:   five horizontal rows (rows y-2..y+2) -> w uint8 output pixels.
int16_t* gaussian_scratch(GaussianWork* work);     // points at sample 0 (32-byte aligned)
int16_t* gaussian_ring_row(GaussianWork* work, int slot);
void gaussian_expand_row(const uint8_t* in, int16_t* scratch, int w);
void gaussian_horiz_row(const int16_t* scratch, int16_t* hrow, int w, const GaussQ15& q);
void gaussian_vert_row(const int16_t* const rows[5], uint8_t* out, int w, const GaussQ15& q);

// Plain scalar reference of the contract above (exact, any size >= 5x5).
void gaussian_ref_q(int w, int h, const uint8_t* in, uint8_t* out, const GaussQ15& q);
