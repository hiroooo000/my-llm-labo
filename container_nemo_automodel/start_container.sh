#!/bin/bash

# Configuration
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "${SCRIPT_DIR}/config.sh"

echo "Starting NeMo AutoModel Container..."

# Build image from local Dockerfile
echo "Building Docker image ${IMAGE_NAME}..."
docker build -f "${SCRIPT_DIR}/Dockerfile" -t ${IMAGE_NAME} "${SCRIPT_DIR}"

# Remove existing container if it exists to apply changes
if [ "$(docker ps -aq -f name=${CONTAINER_NAME})" ]; then
    echo "Removing existing container ${CONTAINER_NAME}..."
    docker rm -f ${CONTAINER_NAME}
fi

# Ensure Automodel repository exists on host for mounting
if [ ! -d "${SCRIPT_DIR}/Automodel" ]; then
    echo "Cloning Automodel repository to ${SCRIPT_DIR}/Automodel..."
    git clone https://github.com/NVIDIA-NeMo/Automodel.git "${SCRIPT_DIR}/Automodel"
fi

# Ensure HF cache directory exists on host
mkdir -p ${HOME}/.cache/huggingface

# Run container in background (-d)
docker run -d \
    --name ${CONTAINER_NAME} \
    --gpus all \
    --ipc=host \
    --ulimit memlock=-1 \
    --ulimit stack=67108864 \
    --shm-size 64gb \
    -p 8888:8888 \
    -v ${WORKSPACE_DIR}:/workspace \
    -v ${SCRIPT_DIR}/Automodel:/workspace/Automodel \
    -v ${SCRIPT_DIR}/Automodel:/opt/Automodel \
    -v ${HOME}/.cache/huggingface:/root/.cache/huggingface \
    -w /workspace \
    ${IMAGE_NAME}

echo "Container ${CONTAINER_NAME} started successfully."
echo "Jupyter Lab is running on http://localhost:8888"
echo "Use ./connect_container.sh to enter the container."
