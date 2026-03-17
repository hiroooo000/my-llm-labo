#!/bin/bash

# Configuration
CONTAINER_NAME="dgx-spark-dev"
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
IMAGE_NAME="dgx-spark-custom"
WORKSPACE_DIR=$(cd "${SCRIPT_DIR}/.." && pwd)

echo "Starting NVIDIA DGX Spark Dev Container..."

# Build image from local Dockerfile
echo "Building Docker image ${IMAGE_NAME}..."
docker build -t ${IMAGE_NAME} "${SCRIPT_DIR}"

# Remove existing container if it exists to apply changes
if [ "$(docker ps -aq -f name=${CONTAINER_NAME})" ]; then
    echo "Removing existing container ${CONTAINER_NAME} to apply new changes..."
    docker rm -f ${CONTAINER_NAME}
fi

# Run new container
# Ensure HF cache directory exists on host
mkdir -p ${HOME}/.cache/huggingface

docker run -d \
    --name ${CONTAINER_NAME} \
    --gpus all \
    --shm-size 64gb \
    -p 8888:8888 \
    -v ${WORKSPACE_DIR}:/workspace \
    -v ${HOME}/.cache/huggingface:/root/.cache/huggingface \
    -w /workspace \
    ${IMAGE_NAME} \
    sleep infinity

echo "Container ${CONTAINER_NAME} started successfully in background."
echo "Use ./connect_container.sh to enter the container."
