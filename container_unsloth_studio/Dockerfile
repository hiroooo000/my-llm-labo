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

# Install Unsloth via official script
RUN curl -fsSL https://unsloth.ai/install.sh | sh

# Set environment variables to include the virtual environment created by install.sh
ENV VENV_PATH="/root/.unsloth/studio/unsloth_studio"
ENV PATH="${VENV_PATH}/bin:${PATH}"

# Run unsloth studio setup to build the frontend and finalize installation during build time
RUN unsloth studio setup

# Execute unsloth studio on startup
CMD ["unsloth", "studio", "-H", "0.0.0.0", "-p", "8888"]
