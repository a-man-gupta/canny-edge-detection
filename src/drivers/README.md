# Drivers

Start with `driver_tiled.cpp` for the final OpenMP pipeline and scalar validation. `driver_mpi.cpp` is the MPI experiment. The other drivers measure individual stages. From the repository root run `make fusion FUSION_IMAGE=noise` for the full pipeline, or `make check` for the standalone Sobel and NMS checks.
