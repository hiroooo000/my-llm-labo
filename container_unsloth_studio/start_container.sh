#!/bin/bash

# Configuration
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "${SCRIPT_DIR}/config.sh"

echo "Starting NVIDIA DGX Spark Dev Container..."

# Build image from local Dockerfile
echo "Building Docker image ${IMAGE_NAME}..."
docker build -f "${SCRIPT_DIR}/Dockerfile" -t ${IMAGE_NAME} "${SCRIPT_DIR}"

# Remove existing container if it exists to apply changes
if [ "$(docker ps -aq -f name=${CONTAINER_NAME})" ]; then
    echo "Removing existing container ${CONTAINER_NAME} to apply new changes..."
    docker rm -f ${CONTAINER_NAME}
fi

# Run new container
# Ensure HF cache directory exists on host
mkdir -p ${HOME}/.cache/huggingface
mkdir -p ${HOME}/.unsloth/studio

#docker run -d \
#    --name ${CONTAINER_NAME} \
#    --gpus all \
#    --ipc=host \
#    --ulimit memlock=-1 \
#    --ulimit stack=67108864 \
#    --shm-size 64gb \
#    --network host \
#    --add-host=host.docker.internal:host-gateway \
#    -v ${WORKSPACE_DIR}:/workspace \
#    -v ${HOME}/.cache/huggingface:/root/.cache/huggingface \
#    -w /workspace \
#    ${IMAGE_NAME} \
#    sleep infinity

docker run -d \
    --name ${CONTAINER_NAME} \
    --gpus=all \
    --net=host \
    --ipc=host \
    --ulimit memlock=-1 \
    --ulimit stack=67108864 \
    -v $(pwd):$(pwd) \
    -v $HOME/.cache/huggingface:/root/.cache/huggingface \
    -v $HOME/.unsloth/studio:/root/.unsloth/studio \
    -w $(pwd) \
    ${IMAGE_NAME}

echo "Container ${CONTAINER_NAME} started successfully in background."
echo "Use ./connect_container.sh to enter the container."
