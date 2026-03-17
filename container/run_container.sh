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

# Check if container is already running
if [ "$(docker ps -q -f name=${CONTAINER_NAME})" ]; then
    echo "Container ${CONTAINER_NAME} is already running."
    exit 0
fi

# Check if container exists but is stopped
if [ "$(docker ps -aq -f status=exited -f name=${CONTAINER_NAME})" ]; then
    echo "Restarting existing container ${CONTAINER_NAME}..."
    docker start ${CONTAINER_NAME}
    exit 0
fi

# Run new container
docker run -d \
    --name ${CONTAINER_NAME} \
    --gpus all \
    --shm-size 64gb \
    -p 8888:8888 \
    -v ${WORKSPACE_DIR}:/workspace \
    -w /workspace \
    ${IMAGE_NAME} \
    sleep infinity

echo "Container ${CONTAINER_NAME} started successfully in background."
echo "Use ./connect_container.sh to enter the container."
