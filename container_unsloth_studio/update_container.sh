#!/bin/bash
set -e

# Configuration
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
source "${SCRIPT_DIR}/config.sh"

echo "=========================================="
echo " Unsloth Studio Container Updater"
echo " Target Container: ${CONTAINER_NAME}"
echo "=========================================="

# Check if container exists and is running
if [ ! "$(docker ps -q -f name=${CONTAINER_NAME})" ]; then
    if [ "$(docker ps -aq -f name=${CONTAINER_NAME})" ]; then
        echo "Container ${CONTAINER_NAME} is stopped. Starting it..."
        docker start ${CONTAINER_NAME}
        sleep 3
    else
        echo "Error: Container ${CONTAINER_NAME} does not exist."
        echo "Please run ./start_container.sh first to build and start the container."
        exit 1
    fi
fi

# Parse command line options
INSTALL_TARGET="unsloth unsloth_zoo"
if [ "$1" == "--git" ] || [ "$1" == "--nightly" ]; then
    echo "Installing bleeding-edge version from GitHub repository..."
    INSTALL_TARGET="git+https://github.com/unslothai/unsloth.git"
elif [ "$1" == "--version" ] && [ -n "$2" ]; then
    echo "Installing specific version: $2..."
    INSTALL_TARGET="unsloth==$2 unsloth_zoo==$2"
elif [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  (no args)          Update unsloth and unsloth_zoo to the latest PyPI release"
    echo "  --git, --nightly   Install latest unsloth from GitHub main branch"
    echo "  --version <ver>    Install a specific version (e.g. --version 2026.10.6)"
    echo "  -h, --help         Show this help message"
    exit 0
fi

echo "Current installed versions in container:"
docker exec ${CONTAINER_NAME} pip list | grep -E "unsloth" || true

echo ""
echo "Updating Unsloth dependencies safely (--no-deps to preserve Blackwell PyTorch/Triton)..."
docker exec ${CONTAINER_NAME} pip install --no-cache-dir -U --no-deps ${INSTALL_TARGET}

echo "Ensuring transformers compatibility..."
docker exec ${CONTAINER_NAME} python3 -c '
path = "/usr/local/lib/python3.12/dist-packages/transformers/dependency_versions_table.py"
try:
    content = open(path).read()
    if "\"huggingface-hub\": \"huggingface-hub>=0.34.0,<1.0\"" in content:
        open(path, "w").write(content.replace("\"huggingface-hub\": \"huggingface-hub>=0.34.0,<1.0\"", "\"huggingface-hub\": \"huggingface-hub>=0.34.0\""))
        print("Patched transformers dependency check.")
except Exception as e:
    print(f"Note: {e}")
'

echo "Updating audio runtime (audio.cpp prebuilt)..."
docker exec ${CONTAINER_NAME} python3 /root/.unsloth/studio/unsloth_studio/lib/python3.12/site-packages/studio/install_audio_cpp_prebuilt.py || true

echo "Restarting container ${CONTAINER_NAME} to apply changes..."
docker restart ${CONTAINER_NAME}

echo "Waiting for Unsloth Studio server to become ready..."
RETRY_COUNT=0
MAX_RETRIES=20
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
    echo "Unsloth Studio is healthy and running!"
else
    echo "Warning: Health check timed out. Please check 'docker logs ${CONTAINER_NAME}' for details."
fi

echo ""
echo "Updated versions in container:"
docker exec ${CONTAINER_NAME} pip list | grep -E "unsloth" || true
echo "=========================================="
echo "Update complete! You can refresh your browser at http://localhost:8888"
echo "=========================================="
