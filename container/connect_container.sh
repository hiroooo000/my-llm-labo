#!/bin/bash

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "${SCRIPT_DIR}/config.sh"

# Check if container is running
if [ ! "$(docker ps -q -f name=${CONTAINER_NAME})" ]; then
    echo "Container ${CONTAINER_NAME} is not running. Please run ./start_container.sh first."
    exit 1
fi

echo "Connecting to ${CONTAINER_NAME}..."
docker exec -it ${CONTAINER_NAME} /bin/bash
