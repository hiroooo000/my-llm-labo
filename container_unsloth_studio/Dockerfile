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

# Ensure structlog, unsloth, and unsloth_zoo are updated to the latest release
RUN pip install --no-cache-dir -U unsloth unsloth_zoo structlog

# Set up the Unsloth Studio managed virtual environment with system site packages
# This ensures Blackwell-compatible PyTorch and Triton from unsloth-dgx-spark base image are inherited
RUN python3 -m venv --system-site-packages /root/.unsloth/studio/unsloth_studio && \
    /root/.unsloth/studio/unsloth_studio/bin/pip install --no-cache-dir --no-deps --ignore-installed unsloth unsloth_zoo && \
    /root/.unsloth/studio/unsloth_studio/bin/pip install --no-cache-dir -r /root/.unsloth/studio/unsloth_studio/lib/python3.12/site-packages/studio/backend/requirements/studio.txt

# Ensure compatibility with NVIDIA GB10 / DGX Spark GPU memory detection if present
RUN python3 -c 'import glob; \
paths = glob.glob("/root/.unsloth/studio/unsloth_studio/lib/python3.12/site-packages/studio/backend/core/inference/llama_cpp.py") + glob.glob("/usr/local/lib/python3.12/dist-packages/studio/backend/core/inference/llama_cpp.py"); \
[open(p, "w").write(open(p).read().replace("free_mib = int(parts[1].strip())", "mem_str = parts[1].strip()\n                    free_mib = 131072 if mem_str == \"[N/A]\" else int(mem_str)")) for p in paths if "free_mib = int(parts[1].strip())" in open(p).read()]'

# Pre-install audio runtime (audio.cpp prebuilt)
RUN python3 /root/.unsloth/studio/unsloth_studio/lib/python3.12/site-packages/studio/install_audio_cpp_prebuilt.py || true

# Set environment variables to prioritize unsloth studio and silence transformers strict check
ENV PATH="/root/.unsloth/studio/unsloth_studio/bin:${PATH}" \
    UNSLOTH_SKIP_TRANSFORMERS_DEPENDENCY_CHECK=1

# Patch transformers dependency check to allow huggingface-hub >= 1.0 required by studio
RUN python3 -c 'path = "/usr/local/lib/python3.12/dist-packages/transformers/dependency_versions_table.py"; content = open(path).read().replace("\"huggingface-hub\": \"huggingface-hub>=0.34.0,<1.0\"", "\"huggingface-hub\": \"huggingface-hub>=0.34.0\""); open(path, "w").write(content)'

# Add an in-container update command for convenience
RUN echo '#!/bin/bash' > /usr/local/bin/update-unsloth && \
    echo 'echo "Updating Unsloth and Unsloth Zoo (--no-deps)..."' >> /usr/local/bin/update-unsloth && \
    echo '/root/.unsloth/studio/unsloth_studio/bin/pip install --no-cache-dir -U --no-deps unsloth unsloth_zoo' >> /usr/local/bin/update-unsloth && \
    echo 'echo "Done. Remember to restart container or studio process to reload."' >> /usr/local/bin/update-unsloth && \
    chmod +x /usr/local/bin/update-unsloth

# Backup studio files so that they can be restored if an empty host volume is mounted over it
RUN cp -a /root/.unsloth/studio /opt/studio_backup

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Execute unsloth studio on startup via the entrypoint
ENTRYPOINT ["/entrypoint.sh"]
CMD ["unsloth", "studio", "-H", "0.0.0.0", "-p", "8888"]
