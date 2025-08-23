# Build stage 
FROM rocm/dev-ubuntu-22.04:latest AS build

# Define build arguments
ARG GPU_TARGET=gfx1030
ARG SD_CPP_BRANCH=master

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    cmake \
    ninja-build \
    git \
    hipblas-dev \
    rocblas-dev

# Set a working directory and clone the source code
WORKDIR /app
RUN git clone --recursive --depth 1 --branch ${SD_CPP_BRANCH} https://github.com/leejet/stable-diffusion.cpp.git .

# Build the project
RUN rm -rf build && mkdir build && cd build && \
    cmake .. -G Ninja \
             -DCMAKE_BUILD_TYPE=Release \
             -DSD_HIPBLAS=ON \
             -DAMDGPU_TARGETS=${GPU_TARGET} \
             -DCMAKE_POSITION_INDEPENDENT_CODE=ON && \
    ninja

# Runtime stage
FROM ubuntu:22.04 AS runtime

ENV ROCM_PATH=/opt/rocm
ENV LD_LIBRARY_PATH=${ROCM_PATH}/lib

COPY --from=build /opt/rocm-*/lib /opt/rocm/lib

RUN apt-get update && apt-get install -y --no-install-recommends \
        libnuma1 ca-certificates python3 python3-pip libgomp1 libfmt-dev libelf1 libdrm2 libdrm-amdgpu1 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

COPY --from=build /app/build/bin/sd /usr/local/bin/sd
RUN chmod +x /usr/local/bin/sd

ENTRYPOINT ["/usr/local/bin/sd"]