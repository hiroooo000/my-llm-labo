FROM nvcr.io/nvidia/pytorch:26.02-py3

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="/usr/local/cuda/bin:${PATH}"

# Update and install basic tools
RUN apt-get update && apt-get install -y \
    git \
    curl \
    vim \
    gh && rm -rf /var/lib/apt/lists/*

# Install common ML libraries for fine-tuning and inference
RUN pip install --no-cache-dir \
    transformers \
    accelerate \
    peft \
    bitsandbytes \
    datasets \
    scipy \
    sentencepiece \
    jupyter \
    huggingface_hub

RUN mkdir -p /root/.cache/huggingface

# Set the working directory
WORKDIR /workspace
