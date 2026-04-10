FROM unsloth-dgx-spark:latest

# Install system dependencies including Node.js and build tools
RUN apt-get update && apt-get install -y \
    curl \
    git \
    cmake \
    build-essential \
    libcurl4-openssl-dev \
    nodejs \
    npm \
    && rm -rf /var/lib/apt/lists/*

# Ensure structlog and required Python dependencies for the studio are installed in the system environment
RUN pip install structlog

# Run unsloth studio setup in the system environment to build the frontend and finalize installation
# We avoid using install.sh because it creates an isolated venv that drops the customized Blackwell-compatible
# PyTorch and Triton dependencies provided by the unsloth-dgx-spark base image.
RUN unsloth studio setup

# Patch unsloth studio to correctly detect NVIDIA GB10 GPU memory which shows [N/A] in nvidia-smi
RUN python3 -c 'path = "/usr/local/lib/python3.12/dist-packages/studio/backend/core/inference/llama_cpp.py"; content = open(path).read().replace("free_mib = int(parts[1].strip())", "mem_str = parts[1].strip()\n                    free_mib = 131072 if mem_str == \"[N/A]\" else int(mem_str)"); open(path, "w").write(content)'

# Backup studio files so that they can be restored if an empty host volume is mounted over it
RUN cp -a /root/.unsloth/studio /opt/studio_backup

# Create an entrypoint script to restore files at runtime if necessary
RUN echo '#!/bin/bash' > /entrypoint.sh && \
    echo 'if [ ! -d "/root/.unsloth/studio/.venv" ]; then' >> /entrypoint.sh && \
    echo '    echo "Restoring studio system files to empty volume mount..."' >> /entrypoint.sh && \
    echo '    cp -a /opt/studio_backup/. /root/.unsloth/studio/' >> /entrypoint.sh && \
    echo 'fi' >> /entrypoint.sh && \
    echo 'exec "$@"' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

# Execute unsloth studio on startup via the entrypoint
ENTRYPOINT ["/entrypoint.sh"]
CMD ["unsloth", "studio", "-H", "0.0.0.0", "-p", "8888"]
