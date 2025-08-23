# stable-diffusion.cpp-rocm-docker

*Minimal Dockerfile for running [stable-diffusion.cpp](https://github.com/leejet/stable-diffusion.cpp) on AMD GPUs with ROCm.*

*Find your GPU target with `rocminfo | grep gfx` (e.g., `gfx1030`, `gfx1100`) or check out [table of targets](compatibility.md)*

# Build
You only need the `Dockerfile` to build the image from the source.

Replace 'gfx1030' with your AMD GPU target
```
docker build --build-arg GPU_TARGET=gfx1030 -t sd-runtime:latest .
```

# Template
```
docker run --rm -it \
  --device=/dev/kfd --device=/dev/dri \
  -v /path/to/models:/workspace/models:ro \
  -v /path/to/outputs:/workspace/outputs \
  sd-runtime:latest [arguments...]
```

# Example
```
docker run --rm -it \
  --device=/dev/kfd --device=/dev/dri \
  -v ~/sd_models:/workspace/models:ro \
  -v ~/sd_outputs:/workspace/outputs \
  sd-runtime:latest \
    --diffusion-model /workspace/models/chroma-unlocked-v50-Q8_0.gguf \
    --vae /workspace/models/ae.sft \
    --t5xxl /workspace/models/t5xxl_fp16.safetensors \
    -p "a lovely cat" \
    -o /workspace/outputs/my_cat.png
```