#!/bin/bash

# Configuration
CONTAINER_NAME="dgx-spark-dev"

echo "Stopping container ${CONTAINER_NAME}..."

# Check if container exists and is running
if [ "$(docker ps -q -f name=${CONTAINER_NAME})" ]; then
    docker stop ${CONTAINER_NAME}
    echo "Container ${CONTAINER_NAME} stopped."
elif [ "$(docker ps -aq -f name=${CONTAINER_NAME})" ]; then
    echo "Container ${CONTAINER_NAME} is already stopped."
else
    echo "Container ${CONTAINER_NAME} does not exist."
fi
