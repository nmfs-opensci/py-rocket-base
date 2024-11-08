#!/bin/bash
# Required User: NB_USER

echo "user is root"
echo "NB_PYTHON_PREFIX: $NB_PYTHON_PREFIX"
echo "CONDA_ENV: $CONDA_ENV"
echo "CONDA_DIR: $CONDA_DIR"

# Check if running as root and switch to NB_USER if needed
if [[ $(id -u) -eq 0 ]]; then
    echo "Switching to ${NB_USER} to run install-conda-packages.sh"
    exec su "${NB_USER}" -c "/bin/bash $0 $1"  # Pass along the filename argument
fi

echo "user is jovyan"
echo "NB_PYTHON_PREFIX: $NB_PYTHON_PREFIX"
echo "CONDA_ENV: $CONDA_ENV"
echo "CONDA_DIR: $CONDA_DIR"
