#pragma once

#include <cstdint>
#include <fstream>
#include <stdexcept>
#include <string>
#include <vector>

// Optional dump used by the stage comparison. Not part of the timed loop.
// Layout, little-endian: magic "C2D1", int32 width, int32 height,
// then mag, angle, and NMS as float32, each width*height values.
inline void write_stages_dump(const std::string& path, int w, int h,
                              const std::vector<float>& mag,
                              const std::vector<float>& angle,
                              const std::vector<float>& suppressed) {
    std::ofstream out(path, std::ios::binary);
    const uint32_t magic = 0x31443243u;
    const int32_t iw = w;
    const int32_t ih = h;
    out.write(reinterpret_cast<const char*>(&magic), 4);
    out.write(reinterpret_cast<const char*>(&iw), 4);
    out.write(reinterpret_cast<const char*>(&ih), 4);
    out.write(reinterpret_cast<const char*>(mag.data()), std::streamsize(mag.size() * sizeof(float)));
    out.write(reinterpret_cast<const char*>(angle.data()), std::streamsize(angle.size() * sizeof(float)));
    out.write(reinterpret_cast<const char*>(suppressed.data()), std::streamsize(suppressed.size() * sizeof(float)));
    if (!out)
        throw std::runtime_error("Could not write stages dump");
}
