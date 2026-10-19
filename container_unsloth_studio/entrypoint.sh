#!/bin/bash
set -e

# Restore studio system files if host volume mount is empty
if [ ! -d "/root/.unsloth/studio/unsloth_studio" ]; then
    echo "Restoring studio system files to empty volume mount..."
    cp -a /opt/studio_backup/. /root/.unsloth/studio/
fi

# Automatically update Unsloth and Audio runtime on every startup (unless SKIP_AUTO_UPDATE=1)
if [ "${SKIP_AUTO_UPDATE}" != "1" ]; then
    echo "=================================================="
    echo " Checking and updating Unsloth & Audio runtime... "
    echo "=================================================="
    /root/.unsloth/studio/unsloth_studio/bin/pip install --no-cache-dir -U --no-deps unsloth unsloth_zoo || true
    python3 /root/.unsloth/studio/unsloth_studio/lib/python3.12/site-packages/studio/install_audio_cpp_prebuilt.py || true
fi

# Ensure transformers compatibility patch for huggingface-hub >= 1.0
python3 -c '
path = "/usr/local/lib/python3.12/dist-packages/transformers/dependency_versions_table.py"
try:
    content = open(path).read()
    if "\"huggingface-hub\": \"huggingface-hub>=0.34.0,<1.0\"" in content:
        open(path, "w").write(content.replace("\"huggingface-hub\": \"huggingface-hub>=0.34.0,<1.0\"", "\"huggingface-hub\": \"huggingface-hub>=0.34.0\""))
except Exception:
    pass
' 2>/dev/null || true

echo "Starting Unsloth Studio..."
exec "$@"
