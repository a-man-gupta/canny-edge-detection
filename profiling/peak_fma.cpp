// Measures latency and throughput of the instructions the blur kernel uses.
// Run each mode under perf stat; instructions per cycle gives throughput, one chain gives latency.
//   ./peak_fma <mode>   mode: fma_ymm_tp fma_ymm_lat fma_zmm_tp fma_zmm_lat add_ymm_tp mul_ymm_tp
//                             load_ymm_tp load_split_ymm_tp bcast_ymm_tp
#include <cstdio>
#include <cstring>

constexpr long ITERS = 200000000;  // 10 measured instructions per iteration

#define REP10(op) op op op op op op op op op op

int main(int argc, char** argv) {
    if (argc != 2) { std::fprintf(stderr, "usage: %s <mode>\n", argv[0]); return 1; }
    const char* m = argv[1];
    alignas(64) static float buf[64] = {};  // 256 bytes: loads below stay inside it
    if (!std::strcmp(m, "fma_ymm_tp")) {
        asm volatile("vxorps %%ymm0,%%ymm0,%%ymm0\n vxorps %%ymm1,%%ymm1,%%ymm1" ::: "xmm0", "xmm1");
        for (long i = 0; i < ITERS; ++i)
            asm volatile(
                "vfmadd231ps %%ymm0,%%ymm1,%%ymm2\n vfmadd231ps %%ymm0,%%ymm1,%%ymm3\n"
                "vfmadd231ps %%ymm0,%%ymm1,%%ymm4\n vfmadd231ps %%ymm0,%%ymm1,%%ymm5\n"
                "vfmadd231ps %%ymm0,%%ymm1,%%ymm6\n vfmadd231ps %%ymm0,%%ymm1,%%ymm7\n"
                "vfmadd231ps %%ymm0,%%ymm1,%%ymm8\n vfmadd231ps %%ymm0,%%ymm1,%%ymm9\n"
                "vfmadd231ps %%ymm0,%%ymm1,%%ymm10\n vfmadd231ps %%ymm0,%%ymm1,%%ymm11\n"
                ::: "xmm2","xmm3","xmm4","xmm5","xmm6","xmm7","xmm8","xmm9","xmm10","xmm11");
    } else if (!std::strcmp(m, "fma_ymm_lat")) {
        asm volatile("vxorps %%ymm0,%%ymm0,%%ymm0\n vxorps %%ymm2,%%ymm2,%%ymm2" ::: "xmm0", "xmm2");
        for (long i = 0; i < ITERS; ++i)
            asm volatile(REP10("vfmadd231ps %%ymm0,%%ymm0,%%ymm2\n") ::: "xmm2");
    } else if (!std::strcmp(m, "fma_zmm_tp")) {
        asm volatile("vpxord %%zmm0,%%zmm0,%%zmm0\n vpxord %%zmm1,%%zmm1,%%zmm1" ::: "xmm0", "xmm1");
        for (long i = 0; i < ITERS; ++i)
            asm volatile(
                "vfmadd231ps %%zmm0,%%zmm1,%%zmm2\n vfmadd231ps %%zmm0,%%zmm1,%%zmm3\n"
                "vfmadd231ps %%zmm0,%%zmm1,%%zmm4\n vfmadd231ps %%zmm0,%%zmm1,%%zmm5\n"
                "vfmadd231ps %%zmm0,%%zmm1,%%zmm6\n vfmadd231ps %%zmm0,%%zmm1,%%zmm7\n"
                "vfmadd231ps %%zmm0,%%zmm1,%%zmm8\n vfmadd231ps %%zmm0,%%zmm1,%%zmm9\n"
                "vfmadd231ps %%zmm0,%%zmm1,%%zmm10\n vfmadd231ps %%zmm0,%%zmm1,%%zmm11\n"
                ::: "xmm2","xmm3","xmm4","xmm5","xmm6","xmm7","xmm8","xmm9","xmm10","xmm11");
    } else if (!std::strcmp(m, "fma_zmm_lat")) {
        asm volatile("vpxord %%zmm0,%%zmm0,%%zmm0\n vpxord %%zmm2,%%zmm2,%%zmm2" ::: "xmm0", "xmm2");
        for (long i = 0; i < ITERS; ++i)
            asm volatile(REP10("vfmadd231ps %%zmm0,%%zmm0,%%zmm2\n") ::: "xmm2");
    } else if (!std::strcmp(m, "add_ymm_tp") || !std::strcmp(m, "mul_ymm_tp")) {
        asm volatile("vxorps %%ymm0,%%ymm0,%%ymm0" ::: "xmm0");
        if (m[0] == 'a')
            for (long i = 0; i < ITERS; ++i)
                asm volatile(
                    "vaddps %%ymm0,%%ymm2,%%ymm2\n vaddps %%ymm0,%%ymm3,%%ymm3\n"
                    "vaddps %%ymm0,%%ymm4,%%ymm4\n vaddps %%ymm0,%%ymm5,%%ymm5\n"
                    "vaddps %%ymm0,%%ymm6,%%ymm6\n vaddps %%ymm0,%%ymm7,%%ymm7\n"
                    "vaddps %%ymm0,%%ymm8,%%ymm8\n vaddps %%ymm0,%%ymm9,%%ymm9\n"
                    "vaddps %%ymm0,%%ymm10,%%ymm10\n vaddps %%ymm0,%%ymm11,%%ymm11\n"
                    ::: "xmm2","xmm3","xmm4","xmm5","xmm6","xmm7","xmm8","xmm9","xmm10","xmm11");
        else
            for (long i = 0; i < ITERS; ++i)
                asm volatile(
                    "vmulps %%ymm0,%%ymm2,%%ymm2\n vmulps %%ymm0,%%ymm3,%%ymm3\n"
                    "vmulps %%ymm0,%%ymm4,%%ymm4\n vmulps %%ymm0,%%ymm5,%%ymm5\n"
                    "vmulps %%ymm0,%%ymm6,%%ymm6\n vmulps %%ymm0,%%ymm7,%%ymm7\n"
                    "vmulps %%ymm0,%%ymm8,%%ymm8\n vmulps %%ymm0,%%ymm9,%%ymm9\n"
                    "vmulps %%ymm0,%%ymm10,%%ymm10\n vmulps %%ymm0,%%ymm11,%%ymm11\n"
                    ::: "xmm2","xmm3","xmm4","xmm5","xmm6","xmm7","xmm8","xmm9","xmm10","xmm11");
    } else if (!std::strcmp(m, "load_ymm_tp")) {
        // Unaligned offsets that stay inside one 64-byte cache line.
        for (long i = 0; i < ITERS; ++i)
            asm volatile(
                "vmovups (%0),%%ymm2\n vmovups 4(%0),%%ymm3\n vmovups 8(%0),%%ymm4\n"
                "vmovups 12(%0),%%ymm5\n vmovups 16(%0),%%ymm6\n vmovups 20(%0),%%ymm7\n"
                "vmovups 24(%0),%%ymm8\n vmovups 28(%0),%%ymm9\n vmovups 32(%0),%%ymm10\n"
                "vmovups 64(%0),%%ymm11\n"
                :: "r"(buf) : "xmm2","xmm3","xmm4","xmm5","xmm6","xmm7","xmm8","xmm9","xmm10","xmm11");
    } else if (!std::strcmp(m, "load_split_ymm_tp")) {
        // Every load crosses a 64-byte cache-line boundary.
        for (long i = 0; i < ITERS; ++i)
            asm volatile(
                "vmovups 36(%0),%%ymm2\n vmovups 40(%0),%%ymm3\n vmovups 44(%0),%%ymm4\n"
                "vmovups 48(%0),%%ymm5\n vmovups 52(%0),%%ymm6\n vmovups 56(%0),%%ymm7\n"
                "vmovups 60(%0),%%ymm8\n vmovups 100(%0),%%ymm9\n vmovups 104(%0),%%ymm10\n"
                "vmovups 108(%0),%%ymm11\n"
                :: "r"(buf) : "xmm2","xmm3","xmm4","xmm5","xmm6","xmm7","xmm8","xmm9","xmm10","xmm11");
    } else if (!std::strcmp(m, "bcast_ymm_tp")) {
        for (long i = 0; i < ITERS; ++i)
            asm volatile(
                "vbroadcastss (%0),%%ymm2\n vbroadcastss 4(%0),%%ymm3\n vbroadcastss 8(%0),%%ymm4\n"
                "vbroadcastss 12(%0),%%ymm5\n vbroadcastss 16(%0),%%ymm6\n vbroadcastss 20(%0),%%ymm7\n"
                "vbroadcastss 24(%0),%%ymm8\n vbroadcastss 28(%0),%%ymm9\n vbroadcastss 32(%0),%%ymm10\n"
                "vbroadcastss 36(%0),%%ymm11\n"
                :: "r"(buf) : "xmm2","xmm3","xmm4","xmm5","xmm6","xmm7","xmm8","xmm9","xmm10","xmm11");
    } else { std::fprintf(stderr, "unknown mode\n"); return 1; }
    return 0;
}
