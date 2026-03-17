#!/bin/bash

# Shared Configuration
CONTAINER_NAME="dgx-spark-dev"
IMAGE_NAME="dgx-spark-custom"

# Directory paths
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
WORKSPACE_DIR=$(cd "${SCRIPT_DIR}/.." && pwd)
