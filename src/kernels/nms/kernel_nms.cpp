#include "kernel_nms.hpp"
#include "detail/nms_impl.hpp"

void nms_kernel(const int16_t *top, std::ptrdiff_t ms, const int16_t *gx, const int16_t *gy,
                std::ptrdiff_t gs, int16_t *out, std::ptrdiff_t os, int width) {
    nms_impl<false>(top, ms, gx, gy, gs, out, os, width, 0, 0);
}

void nms_labels(const int16_t *top, std::ptrdiff_t ms, const int16_t *gx, const int16_t *gy,
                std::ptrdiff_t gs, uint8_t *out, std::ptrdiff_t os, int width, int low, int high) {
    nms_labels_rows<2>(top, ms, gx, gy, gs, out, os, width, low, high);
}

void nms_labels_ten_rows(const int16_t *top, std::ptrdiff_t ms, const int16_t *gx, const int16_t *gy,
                std::ptrdiff_t gs, uint8_t *out, std::ptrdiff_t os, int width, int low, int high) {
    nms_labels_rows<10>(top, ms, gx, gy, gs, out, os, width, low, high);
}
