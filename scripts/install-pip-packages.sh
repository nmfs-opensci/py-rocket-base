#!/bin/bash
# Required User: NB_USER

# Check if a filename argument is provided
if [ -z "$1" ]; then
    echo "Error: install-pip-packages.sh requires an input file of package names (typically called requirements.txt)." >&2
    echo "Usage: RUN /pyrocket_scripts/install-pip-packages.sh <filename>" >&2
    exit 1
fi

# Check if running as root and switch to NB_USER if needed
if [[ $(id -u) -eq 0 ]]; then
    echo "Switching to ${NB_USER} to run install-pip-packages.sh"
    exec su "${NB_USER}" -c "/bin/bash $0 $1"  # Pass along the filename argument
fi

# Main script execution as NB_USER
echo "Running install-pip-packages.sh as ${NB_USER}"
echo "NB_PYTHON_PREFIX: $NB_PYTHON_PREFIX, CONDA_ENV: $CONDA_ENV, CONDA_DIR: $CONDA_DIR"

# Set variable for the provided file
requirements_file="$1"
echo "  Using packages file: ${requirements_file}"

# Check if the specified file exists
if [ ! -f "${requirements_file}" ]; then
    echo "  Error: File '${requirements_file}' not found. Ensure the file exists and try again."
    exit 1
fi

echo "  Installing pip packages from ${requirements_file} as ${NB_USER}..."

# Install pip packages and handle errors
if ! ${NB_PYTHON_PREFIX}/bin/pip install --no-cache -r "${requirements_file}"; then
    echo "  Error: Installation of packages from '${requirements_file}' failed. Please check the package names and try again."
    exit 1
fi

echo "  Success! install-pip-packages.sh"

