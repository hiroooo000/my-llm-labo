#!/bin/bash

# Configuration
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "${SCRIPT_DIR}/config.sh"

echo "Starting NVIDIA DGX Spark Dev Container..."

# Check for rebuild options
BUILD_ARGS=""
if [ "$1" == "--no-cache" ] || [ "$1" == "--rebuild" ]; then
    echo "Rebuilding image from scratch (--no-cache) to fetch latest releases..."
    BUILD_ARGS="--no-cache"
fi

# Build image from local Dockerfile
echo "Building Docker image ${IMAGE_NAME}..."
docker build ${BUILD_ARGS} -f "${SCRIPT_DIR}/Dockerfile" -t ${IMAGE_NAME} "${SCRIPT_DIR}"

# Remove existing container if it exists to apply changes
if [ "$(docker ps -aq -f name=${CONTAINER_NAME})" ]; then
    echo "Removing existing container ${CONTAINER_NAME} to apply new changes..."
    docker rm -f ${CONTAINER_NAME}
fi

# Run new container
# Ensure directories exist on host
mkdir -p ${HOME}/.cache/huggingface
mkdir -p ${HOME}/.unsloth/studio
mkdir -p ${HOME}/.unsloth/audio.cpp

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
    -v $HOME/.unsloth/audio.cpp:/root/.unsloth/audio.cpp \
    -w $(pwd) \
    ${IMAGE_NAME}

echo "Container ${CONTAINER_NAME} started successfully in background."
echo "Unsloth & Audio runtime are automatically verified/updated on startup."
echo "Waiting for Unsloth Studio to become ready..."

RETRY_COUNT=0
MAX_RETRIES=30
READY=false
while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    if curl -s http://127.0.0.1:8888/api/health > /dev/null 2>&1; then
        READY=true
        break
    fi
    sleep 1
    RETRY_COUNT=$((RETRY_COUNT+1))
done

if [ "$READY" = true ]; then
    echo "✓ Unsloth Studio is ready! Open http://localhost:8888 (or http://<IP>:8888)"
else
    echo "Note: Server is still starting up. Check 'docker logs -f ${CONTAINER_NAME}' for progress."
fi
echo "Use ./connect_container.sh to enter the container."
