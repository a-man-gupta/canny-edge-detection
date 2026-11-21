// Sobel kernel (integer) against a scalar loop with OpenCV's formulas, bit for bit:
//   mag_sq = gx*gx + gy*gy and the direction bin from OpenCV's integer test (sobel_bin),
// with the edge repeated outside the image (OpenCV's BORDER_REPLICATE for the Sobel step).
// Every pixel of every image must match; any difference fails the test.
#include "sobel_kernel.hpp"

#include <algorithm>
#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <vector>

// The scalar reference for one whole image.
static void reference(int w, int h, const uint8_t* blur, int32_t* mag_sq, uint8_t* bin) {
    for (int y = 0; y < h; ++y) {
        for (int x = 0; x < w; ++x) {
            auto b = [&](int j, int k) {
                int row = std::clamp(y + j, 0, h - 1);
                int col = std::clamp(x + k, 0, w - 1);
                return int(blur[size_t(row) * w + col]);
            };
            int gx = -b(-1, -1) + b(-1, 1) - 2 * b(0, -1) + 2 * b(0, 1) - b(1, -1) + b(1, 1);
            int gy = -b(-1, -1) - 2 * b(-1, 0) - b(-1, 1) + b(1, -1) + 2 * b(1, 0) + b(1, 1);
            size_t i = size_t(y) * w + x;
            mag_sq[i] = gx * gx + gy * gy;
            bin[i] = sobel_bin(gx, gy);
        }
    }
}

// One image: kernel against reference. Returns the number of differing values.
static long check(int w, int h, int kind) {
    std::vector<uint8_t> blur(size_t(w) * h), bin(blur.size()), bin_ref(blur.size());
    std::vector<int32_t> mag(blur.size()), mag_ref(blur.size());
    for (int y = 0; y < h; ++y)
        for (int x = 0; x < w; ++x) {
            uint8_t v;
            if (kind == 0) v = uint8_t(rand() % 256);                   // noise
            else if (kind == 1) v = (x + y) % 7 < 3 ? 255 : 0;         // diagonal stripes, 0/255 extremes
            else if (kind == 2) v = x < w / 2 ? 0 : 255;                // vertical step
            else v = uint8_t((x * 37 + y * 11) & 255);                  // ramps
            blur[size_t(y) * w + x] = v;
        }
    sobel_kernel(w, h, blur.data(), mag.data(), bin.data());
    reference(w, h, blur.data(), mag_ref.data(), bin_ref.data());
    long bad = 0;
    for (size_t i = 0; i < blur.size(); ++i)
        bad += (mag[i] != mag_ref[i]) + (bin[i] != bin_ref[i]);
    return bad;
}

// Exercise the public int16 row API directly, including empty ranges, tails, and sentinels.
static long check_rows() {
    long bad = 0;
    const int width = 180;
    std::vector<uint8_t> input(3 * width);
    for (auto& v : input) v = uint8_t(rand() % 256);
    std::vector<int16_t> wide(input.begin(), input.end()), bins(width);
    std::vector<int32_t> mag(width), ref_mag(3 * width);
    std::vector<uint8_t> ref_bin(3 * width);
    reference(width, 3, input.data(), ref_mag.data(), ref_bin.data());
    for (int begin = 1; begin <= 8; ++begin) {
        for (int count = 0; count <= 160; ++count) {
            std::fill(mag.begin(), mag.end(), -123456);
            std::fill(bins.begin(), bins.end(), int16_t(-1234));
            sobel_i16_row(wide.data(), wide.data() + width, wide.data() + 2 * width,
                          mag.data(), bins.data(), begin, begin + count);
            for (int x = 0; x < width; ++x) {
                const bool written = x >= begin && x < begin + count;
                bad += mag[x] != (written ? ref_mag[width + x] : -123456);
                bad += bins[x] != (written ? int16_t(ref_bin[width + x]) : int16_t(-1234));
            }
        }
    }
    printf("1288 row range cases, %ld differing values or sentinel writes\n", bad);
    return bad;
}

int main() {
    long images = 0, bad = 0;
    for (int kind = 0; kind < 4; ++kind) {
        for (int h = 1; h <= 9; ++h)
            for (int w = 1; w <= 70; ++w, ++images)
                bad += check(w, h, kind);
        for (int w : {127, 128, 129, 255, 256, 257, 1026, 1920})
            bad += check(w, 5, kind), ++images;
    }
    // Every direction bin from every possible integer gradient, against the test written out.
    long bins = 0, bad_bins = 0;
    for (int gx = -1020; gx <= 1020; ++gx)
        for (int gy = -1020; gy <= 1020; ++gy, ++bins) {
            const int x = std::abs(gx), y = std::abs(gy) << 15, tg22x = x * 13573, tg67x = tg22x + (x << 16);
            const int want = y < tg22x ? 0 : (y > tg67x ? 90 : (((gx ^ gy) < 0) ? 135 : 45));
            bad_bins += (sobel_bin(gx, gy) != want);
        }
    printf("%ld images, %ld differing values; %ld gradient pairs, %ld differing bins\n", images, bad, bins, bad_bins);
    const long bad_rows = check_rows();
    return (bad || bad_bins || bad_rows) ? 1 : 0;
}
