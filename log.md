# Canny edge detection project log

This is a decision and evidence log for the team's work, not an automatic transcript of private chats. Append dated entries when decisions change or work is completed. Preserve older entries.

## 2026-10-19 — Initial project context captured from the current chat

### Repository state
- Team repository identified: https://github.com/a-man-gupta/canny-edge-detection
- At inspection, `main` contained only `README.md` and `.gitattributes`; no Canny implementation, benchmark, tests, or build files were present. No code has been built or timed.
- This entry records the conversation's findings. It does not claim the team has implemented or measured a kernel.

### Course requirements found in the supplied overview slides
- 18-645, How to Write Fast Code; team of three; Canny Edge Detection appears on the pre-approved project list.
- The slides recommend a fast OpenCV implementation, allow existing code and helpers as starting points, and focus on computation rather than file I/O.
- Mid-project presentation is marked October 19-21. The nearby phases call for code analysis, kernel design/implementation, comparing performance against expectations, and designing memory movement. Later work includes memory movement, cross-kernel optimization, initial parallelization, and final six-page paper/video.
- The slides do not require OpenCL/GPU and do not specify a separate written mid-project report format. Earlier chat assumed OpenCL; that assumption was corrected after reading the slides.

### Decisions and provisional plan
- Use OpenCV as a correctness baseline and image I/O helper. Implement the team's own computation kernels and optimize them after obtaining a working baseline.
- Mid-project priority: fixed reference settings and images, at least one team-owned implemented kernel, correctness checks, initial timing, analysis of work/memory traffic, and the next memory optimization plan. Full optimized Canny is not stated as a mid-project requirement in the overview.
- Provisional effort-balanced division: Person 1 owns Gaussian plus double threshold and benchmarking; Person 2 owns gradients plus suppression; Person 3 owns hysteresis. Names and interfaces are still to be agreed.
- Agree on image and intermediate data types, border policy, Gaussian parameters, gradient norm, thresholds, and stage interfaces before integration.
- The slide's stage 3 wording differs from standard Canny's non-maximum suppression; confirm with course staff which operation is expected.
- Keep performance results tied to actual hardware, compiler settings, images, timing method, and commit. Distinguish stage time from end-to-end time and exclude file I/O when measuring computation.

### References found
- OpenCV Canny guide: https://docs.opencv.org/4.x/da/d22/tutorial_py_canny.html
- OpenCV Canny implementation: https://github.com/opencv/opencv/blob/4.x/modules/imgproc/src/canny.cpp
- Third-party OpenCL example with benchmark suite: https://github.com/smskelley/canny-opencl ; useful for ideas but old and not a required target.
- Berkeley BSDS500: https://www2.eecs.berkeley.edu/Research/Projects/CS/vision/grouping/resources.html ; potential edge-quality benchmark, separate from runtime timing.
- Course overview: user-provided `18645-Project Overview-slides (2).pdf` (not committed to this repository).

### Open questions / next action
1. Confirm teammates' names and stage ownership.
2. Confirm stage 3 interpretation, target hardware/language, and any newer mid-project rubric with course staff.
3. Add runnable reference, shared stage interface, fixed test images, and a benchmark harness.
4. Implement and measure the first kernel; then update this log with commands and actual results.

## Log entry template
### YYYY-MM-DD — Short title
- Owner:
- Source/commit:
- Decision or change:
- Files:
- Verification and measured result:
- Remaining risk:
- Next action:
