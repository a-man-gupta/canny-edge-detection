# Gaussian blur

A 5×5 filter with σ = 1 smooths grayscale pixels before Sobel. Each pass computes a weighted center plus two symmetric pairs. The Q15 weights from left to right are 1785, 8002, 13193, 8002, 1785. The implementation widens bytes, uses VPADDW and VPMULHRSW for rounded fixed-point arithmetic, filters five rows horizontally, and combines them vertically. A rolling five-row buffer replaces a full horizontal intermediate image. The tile wrapper reflects input borders and passes blurred bytes directly to Sobel preparation.

**Row-driver model.** The five-row-pointer schedule budgets 86.25 cycles for 160 pixels, or 0.539 cycles/pixel. Its ceiling is 160 / 86.25 = **1.86 pixels/cycle**. With width 1920 and hot buffers on ECE024 core 10, the complete row step measured **0.6426 cycles/pixel = 1.56 pixels/cycle**, about 84% of that model. At width 3840 it measured 0.7598 cycles/pixel. These are standalone row measurements.

Run `make gaussian_driver.x && taskset -c 10 ./gaussian_driver.x rows`. [Source](gaussian_kernel.cpp) · [Assembly](../../../assembly/gaussian.asm) · [Resource model](../../../scripts/gaussian_peak_model.py).
