#!/bin/bash

# Check if running inside a Docker container
if [ ! -f /.dockerenv ]; then
    echo "Error: This script must be run inside the Docker container."
    exit 1
fi

jupyter notebook --ip 0.0.0.0 --port 8888 --allow-root --no-browser --NotebookApp.token='' --NotebookApp.password=''