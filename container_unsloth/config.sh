#!/bin/bash

# Shared Configuration
CONTAINER_NAME="unsloth-dgx-spark"
IMAGE_NAME="unsloth-dgx-spark"

# Directory paths
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
WORKSPACE_DIR=$(cd "${SCRIPT_DIR}/.." && pwd)
