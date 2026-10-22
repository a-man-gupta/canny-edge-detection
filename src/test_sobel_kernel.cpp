// Sobel kernel against the scalar atan2 reference in canny_scalar.cpp.
// All test images hold whole numbers, like the pipeline's blur (rounded to 0..255):
// the kernel's magnitude is only promised to be bit-exact for those.
// Magnitude must match. Direction uses the OpenCV sector test, so category,
// NMS, and edge differences near the 22.5 and 67.5 degree boundaries are counted
// and printed. They are not a failed build.
#include "hysteresis.hpp"
#include "sobel_kernel.hpp"

#include <algorithm>
#include <cmath>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <iostream>
#include <string>
#include <vector>

static float reference_angle(float gy, float gx) {
    float degrees = std::atan2(gy, gx) * 180.0f / 3.14159265358979323846f;
    return degrees < 0 ? degrees + 180 : degrees;
}

static int category(float d) {
    if (d < 22.5f || d >= 157.5f)
        return 0;
    if (d < 67.5f)
        return 1;
    if (d < 112.5f)
        return 2;
    return 3;
}

static void reference_gradients(int w, int h, const float* blur, float* mag, float* angle) {
    for (int y = 0; y < h; ++y) {
        for (int x = 0; x < w; ++x) {
            auto b = [&](int j, int k) {
                int sample_row = std::clamp(y + j, 0, h - 1);
                int sample_col = std::clamp(x + k, 0, w - 1);
                return blur[size_t(sample_row) * w + sample_col];
            };
            float gx = -b(-1, -1) + b(-1, 1)
                     - 2 * b(0, -1) + 2 * b(0, 1)
                     - b(1, -1) + b(1, 1);
            float gy = -b(-1, -1) - 2 * b(-1, 0) - b(-1, 1)
                     + b(1, -1) + 2 * b(1, 0) + b(1, 1);
            size_t i = size_t(y) * w + x;
            mag[i] = std::sqrt(gx * gx + gy * gy);
            angle[i] = reference_angle(gy, gx);
        }
    }
}

static void suppress(int w, int h, const float* mag, const float* angle, float* out) {
    std::fill(out, out + size_t(w) * h, 0.f);
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
                out[i] = mag[i];
        }
    }
}

static void edge_map(int w, int h, const float* suppressed, float low, float high, std::vector<uint8_t>& edges) {
    size_t n = size_t(w) * h;
    std::vector<uint8_t> labels(n);
    for (size_t i = 0; i < n; ++i)
        labels[i] = suppressed[i] > high ? 2 : (suppressed[i] > low ? 1 : 0);
    std::vector<size_t> queue;
    queue.reserve(n);
    hysteresis(labels, w, h, edges, queue);
}

static int g_failures = 0;
static unsigned long long g_category_diffs = 0;
static unsigned long long g_nms_diffs = 0;
static unsigned long long g_edge_diffs = 0;
static unsigned long long g_pixels = 0;

static void fail(const std::string& message) {
    std::cerr << message << "\n";
    ++g_failures;
}

static bool check_image(int w, int h, const std::vector<float>& blur, const char* name) {
    size_t n = size_t(w) * h;
    std::vector<float> mag(n), angle(n), mag_ref(n), angle_ref(n);
    std::vector<float> nms(n), nms_ref(n);
    sobel_kernel(w, h, blur.data(), mag.data(), angle.data());
    reference_gradients(w, h, blur.data(), mag_ref.data(), angle_ref.data());
    g_pixels += n;
    for (size_t i = 0; i < n; ++i) {
        if (std::memcmp(&mag[i], &mag_ref[i], sizeof(float)) != 0) {
            std::cerr << name << " magnitude mismatch at " << i
                      << " got " << mag[i] << " ref " << mag_ref[i] << "\n";
            fail(std::string(name) + " magnitude");
            return false;
        }
        float allowed[] = {0.f, 45.f, 90.f, 135.f};
        bool known = false;
        for (float value : allowed) {
            if (std::memcmp(&angle[i], &value, sizeof(float)) == 0)
                known = true;
        }
        if (!known) {
            std::cerr << name << " angle is not 0, 45, 90, or 135 at " << i
                      << " value " << angle[i] << "\n";
            fail(std::string(name) + " angle");
            return false;
        }
        if (category(angle[i]) != category(angle_ref[i]))
            ++g_category_diffs;
    }
    suppress(w, h, mag.data(), angle.data(), nms.data());
    suppress(w, h, mag_ref.data(), angle_ref.data(), nms_ref.data());
    for (size_t i = 0; i < n; ++i) {
        if (std::memcmp(&nms[i], &nms_ref[i], sizeof(float)) != 0)
            ++g_nms_diffs;
    }
    for (float low : {50.f, 1.f}) {
        float high = low == 50.f ? 100.f : 2.f;
        std::vector<uint8_t> edges(n), edges_ref(n);
        edge_map(w, h, nms.data(), low, high, edges);
        edge_map(w, h, nms_ref.data(), low, high, edges_ref);
        for (size_t i = 0; i < n; ++i) {
            if (edges[i] != edges_ref[i])
                ++g_edge_diffs;
        }
    }
    return true;
}


static void fill_pattern(std::vector<float>& blur, int w, int h, int pattern) {
    for (int y = 0; y < h; ++y) {
        for (int x = 0; x < w; ++x) {
            float value = 0.f;
            if (pattern == 1)
                value = x >= w / 2 ? 255.f : 0.f;
            else if (pattern == 2)
                value = y >= h / 2 ? 255.f : 0.f;
            else if (pattern == 3)
                value = (x + y >= (w + h) / 2) ? 255.f : 0.f;
            else if (pattern == 4)
                value = (x >= y) ? 255.f : 0.f;
            else if (pattern != 0)
                value = float((y * 17 + x * 13 + pattern * 3) & 255);
            blur[size_t(y) * w + x] = value;
        }
    }
}

static int g_classify_checked = 0;
static int g_classify_diffs = 0;

static void check_classifier_value(float gx, float gy) {
    float got = sobel_classify_angle(gx, gy);
    float allowed[] = {0.f, 45.f, 90.f, 135.f};
    bool known = false;
    for (float value : allowed) {
        if (std::memcmp(&got, &value, sizeof(float)) == 0)
            known = true;
    }
    if (!known) {
        std::cerr << "classifier returned " << got << " for gx " << gx << " gy " << gy << "\n";
        ++g_failures;
    }
    ++g_classify_checked;
    if (category(got) != category(reference_angle(gy, gx)))
        ++g_classify_diffs;
}

int main() {
    const int widths[] = {5, 6, 7, 8, 15, 16, 17, 18, 19, 31, 32, 33, 34, 47, 64};
    const int heights[] = {5, 6, 7, 8, 15, 18};
    const int patterns[] = {0, 1, 2, 3, 4, 5, 6};
    for (int w : widths) {
        for (int h : heights) {
            for (int pattern : patterns) {
                std::vector<float> blur(size_t(w) * h);
                fill_pattern(blur, w, h, pattern);
                char name[64];
                std::snprintf(name, sizeof(name), "%dx%d pattern %d", w, h, pattern);
                check_image(w, h, blur, name);
            }
        }
    }
    // Wider images so the kernel runs its 32-pixel loop, not only the 8-pixel tail.
    for (int w : {65, 100, 131, 258}) {
        for (int pattern : patterns) {
            std::vector<float> blur(size_t(w) * 9);
            fill_pattern(blur, w, 9, pattern);
            char name[64];
            std::snprintf(name, sizeof(name), "%dx9 pattern %d", w, pattern);
            check_image(w, 9, blur, name);
        }
    }

    // Deterministic random images, including a width that is not a multiple of 16.
    uint32_t state = 18645u;
    for (int trial = 0; trial < 8; ++trial) {
        int w = 17 + int(trial * 3);
        int h = 5 + trial;
        std::vector<float> blur(size_t(w) * h);
        for (float& value : blur) {
            state = state * 1664525u + 1013904223u;
            int bits = int(state >> 8) & 511;
            value = float(bits - 40);
        }
        char name[64];
        std::snprintf(name, sizeof(name), "random %dx%d", w, h);
        check_image(w, h, blur, name);
    }

    for (float fill : {0.f, -0.f}) {
        std::vector<float> blur(34 * 8, fill);
        check_image(34, 8, blur, fill == 0.f ? "flat +0" : "flat -0");
    }

    float pz = 0.f;
    float nz = -0.f;
    check_classifier_value(pz, pz);
    check_classifier_value(nz, pz);
    check_classifier_value(pz, nz);
    check_classifier_value(nz, nz);
    check_classifier_value(1.f, pz);
    check_classifier_value(1.f, nz);
    check_classifier_value(-1.f, pz);
    check_classifier_value(-1.f, nz);
    check_classifier_value(pz, 1.f);
    check_classifier_value(nz, 1.f);
    check_classifier_value(pz, -1.f);
    check_classifier_value(nz, -1.f);

    const float pi = 3.14159265358979323846f;
    for (float deg : {0.f, 45.f, 90.f, 135.f, 10.f, 30.f, 80.f, 100.f, 150.f, 170.f}) {
        float rad = deg * pi / 180.f;
        check_classifier_value(100.f * std::cos(rad), 100.f * std::sin(rad));
        check_classifier_value(100.f * std::cos(-rad), 100.f * std::sin(-rad));
    }
    const float bounds[] = {22.5f, 67.5f, 112.5f, 157.5f};
    for (float bound : bounds) {
        for (float delta : {0.f, -1e-4f, 1e-4f, -1e-3f, 1e-3f, -0.02f, 0.02f}) {
            for (float mag : {1e-6f, 1.f, 255.f, 2000.f}) {
                for (float sign : {1.f, -1.f}) {
                    float deg = sign * (bound + delta);
                    float rad = deg * pi / 180.f;
                    float gx = mag * std::cos(rad);
                    float gy = mag * std::sin(rad);
                    check_classifier_value(gx, gy);
                    check_classifier_value(std::nextafter(gx, 0.f), gy);
                    check_classifier_value(gx, std::nextafter(gy, 0.f));
                }
            }
        }
    }
    {
        const int w = 34;
        const int h = 8;
        float rad = 22.5f * pi / 180.f;
        float ax = std::cos(rad);
        float ay = std::sin(rad);
        std::vector<float> blur(size_t(w) * h);
        for (int y = 0; y < h; ++y)
            for (int x = 0; x < w; ++x)
                blur[size_t(y) * w + x] = std::round(10.f * (ax * float(x) + ay * float(y)));
        check_image(w, h, blur, "ramp 22.5");
    }

    std::cout << "pixels " << g_pixels << "\n";
    std::cout << "category_diffs_vs_atan2 " << g_category_diffs << "\n";
    std::cout << "nms_diffs_vs_atan2 " << g_nms_diffs << "\n";
    std::cout << "edge_diffs_vs_atan2 " << g_edge_diffs << "\n";
    std::cout << "classifier_checked " << g_classify_checked << "\n";
    std::cout << "classifier_diffs_vs_atan2 " << g_classify_diffs << "\n";
    if (g_failures) {
        std::cerr << g_failures << " failure groups\n";
        return 1;
    }
    std::cout << "ok\n";
    return 0;
}
