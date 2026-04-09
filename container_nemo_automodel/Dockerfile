FROM nvcr.io/nvidia/nemo-automodel:26.02.nemotron_3_super

# Start in a safe directory
WORKDIR /workspace

# Install Automodel (relying on pre-installed kernels in the NGC image)


# Ensure Automodel is installed in the active virtual environment
# and visible via PYTHONPATH
ENV PYTHONPATH=/opt/Automodel
RUN rm -rf /opt/Automodel && \
    git clone https://github.com/NVIDIA-NeMo/Automodel.git /opt/Automodel && \
    /opt/venv/bin/python -m pip install -e /opt/Automodel

# Install Jupyter and register the kernel
RUN pip install --no-cache-dir jupyterlab && \
    /opt/venv/bin/python -m pip install ipykernel && \
    /opt/venv/bin/python -m ipykernel install --name nemo_venv --display-name "NeMo AutoModel (venv)"

# Start Jupyter Lab in the background
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--allow-root", "--no-browser", "--NotebookApp.token=''", "--NotebookApp.password=''"]
