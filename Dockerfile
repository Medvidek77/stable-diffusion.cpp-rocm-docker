# ---------- Build stage ----------
FROM rocm/dev-ubuntu-22.04:latest AS build

# Define a build argument for the GPU target with a default value
ARG GPU_TARGET=gfx1030

RUN apt-get update && apt-get install -y --no-install-recommends \
    cmake \
    ninja-build \
    git \
    hipblas-dev \
    rocblas-dev

WORKDIR /sd.cpp
COPY . .
RUN rm -rf build && mkdir build && cd build && \
    cmake .. -G Ninja \
             -DCMAKE_BUILD_TYPE=Release \
             -DSD_HIPBLAS=ON \
             -DAMDGPU_TARGETS=${GPU_TARGET} \
             -DCMAKE_POSITION_INDEPENDENT_CODE=ON && \
    ninja

# ---------- Runtime stage ----------
FROM ubuntu:22.04 AS runtime

ENV ROCM_PATH=/opt/rocm
ENV LD_LIBRARY_PATH=${ROCM_PATH}/lib

COPY --from=build /opt/rocm-*/lib /opt/rocm/lib

RUN apt-get update && apt-get install -y --no-install-recommends \
        libnuma1 ca-certificates python3 python3-pip libgomp1 libfmt-dev libelf1 libdrm2 libdrm-amdgpu1 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

COPY --from=build /sd.cpp/build/bin/sd /usr/local/bin/sd
RUN chmod +x /usr/local/bin/sd

ENTRYPOINT ["/usr/local/bin/sd"]