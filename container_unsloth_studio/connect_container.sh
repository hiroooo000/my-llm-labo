#!/bin/bash

# Configuration
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "${SCRIPT_DIR}/config.sh"

echo "Connecting to ${CONTAINER_NAME}..."

# Check if container is running
if [ ! "$(docker ps -q -f name=${CONTAINER_NAME})" ]; then
    echo "Error: Container ${CONTAINER_NAME} is not running."
    exit 1
fi

docker exec -it ${CONTAINER_NAME} /bin/bash
