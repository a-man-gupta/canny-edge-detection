// Part 3 kernel against the scalar NMS loop from canny_scalar.cpp, bit for bit.
// Magnitudes are random whole numbers 0..15, so ties (the > / >= cases) are common.
// Angles: Part 2's bins (0/45/90/135), the only values the kernel accepts (see nms_kernel.hpp):
// random bins, and images where every pixel has the same bin.
#include "nms_kernel.hpp"

#include <cstdint>
#include <cstdio>
#include <cstring>
#include <vector>

// Part 3 from canny_scalar.cpp (lines 134-170), unchanged except for the function wrapper.
static void reference_nms(int w, int h, const float* mag, const float* angle, float* suppressed) {
    for (size_t i = 0; i < size_t(w) * h; ++i)
        suppressed[i] = 0;
    for (int y = 1; y < h - 1; ++y) {
        for (int x = 1; x < w - 1; ++x) {
            size_t i = size_t(y) * w + x;
            float d = angle[i];
            size_t a, b;
            if (d < 22.5f || d >= 157.5f) {
                a = i - 1;
                b = i + 1;
            } else if (d < 67.5f) {
                a = i - w - 1;
                b = i + w + 1;
            } else if (d < 112.5f) {
                a = i - w;
                b = i + w;
            } else {
                a = i - w + 1;
                b = i + w - 1;
            }
            if (mag[i] > mag[a] && mag[i] >= mag[b])
                suppressed[i] = mag[i];
        }
    }
}

static uint32_t state = 18645u;
static uint32_t next() { state = state * 1664525u + 1013904223u; return state >> 8; }

int main() {
    const float bins[] = {0.f, 45.f, 90.f, 135.f};
    int checked = 0, failures = 0;
    for (int kind = 0; kind < 5; ++kind) {   // 0: random bins, 1..4: every pixel 0 / 45 / 90 / 135
        for (int w = 3; w <= 300; w += (w < 40 ? 1 : 17)) {
            for (int h : {3, 4, 6, 7, 10}) {   // interior rows 1, 2, 4, 5, 8: blocks of 4 and leftovers
                std::vector<float> mag(size_t(w) * h), angle(size_t(w) * h), got(size_t(w) * h), ref(size_t(w) * h);
                for (size_t i = 0; i < mag.size(); ++i) {
                    mag[i] = float(next() % 16);
                    angle[i] = (kind == 0) ? bins[next() % 4] : bins[kind - 1];
                }
                nms_kernel(w, h, mag.data(), angle.data(), got.data());
                reference_nms(w, h, mag.data(), angle.data(), ref.data());
                ++checked;
                if (std::memcmp(got.data(), ref.data(), got.size() * sizeof(float)) != 0) {
                    for (size_t i = 0; i < got.size(); ++i)
                        if (std::memcmp(&got[i], &ref[i], sizeof(float)) != 0) {
                            std::printf("mismatch: kind %d, %dx%d, pixel %zu: got %g, want %g\n", kind, w, h, i, got[i], ref[i]);
                            break;
                        }
                    ++failures;
                }
            }
        }
    }
    std::printf("images checked %d, mismatches %d\n", checked, failures);
    if (failures) return 1;
    std::printf("ok\n");
    return 0;
}
