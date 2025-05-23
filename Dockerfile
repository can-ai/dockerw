# Base image with CUDA 12.1
FROM nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04

# Set environment
ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1

# Install system packages
RUN apt-get update && apt-get install -y \
    python3 python3-pip git git-lfs wget ffmpeg libgl1 \
    && rm -rf /var/lib/apt/lists/*

# Symlink python3 -> python
RUN ln -s /usr/bin/python3 /usr/bin/python

# Upgrade pip and install Python dependencies
COPY requirements.txt /tmp/requirements.txt
RUN pip install --upgrade pip && pip install -r /tmp/requirements.txt

# Enable Git LFS
RUN git lfs install

# Set work directory
WORKDIR /app

# Clone ComfyUI
RUN git clone https://github.com/comfyanonymous/ComfyUI.git

# Clone Wan2.1 model repo
RUN git clone https://huggingface.co/Wan-AI/Wan2.1-T2V-14B /app/Wan2.1-T2V-14B

# Pull LFS model files
WORKDIR /app/Wan2.1-T2V-14B
RUN git lfs pull

# Move model files to ComfyUI model paths (optional but recommended)
WORKDIR /app
RUN mkdir -p ComfyUI/models/diffusion \
    && mkdir -p ComfyUI/models/vae \
    && mkdir -p ComfyUI/models/clip

# These `mv` commands assume you know the file structure inside the repo
# Update as needed based on actual contents
RUN mv Wan2.1-T2V-14B/*.safetensors ComfyUI/models/diffusion/ || true
RUN mv Wan2.1-T2V-14B/vae/* ComfyUI/models/vae/ || true
RUN mv Wan2.1-T2V-14B/clip/* ComfyUI/models/clip/ || true

# Copy and enable start script
COPY start.sh /start.sh
RUN chmod +x /start.sh

# Default command
CMD ["/start.sh"]
