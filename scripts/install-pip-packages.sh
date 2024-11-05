#!/bin/bash
# Required User: NB_USER

echo "Running install-pip-packages.sh"

# Check that a file name is provided
if [ -z "$1" ]; then
    echo "Error: No file provided. Usage: RUN /pyrocket_scripts/install-pip-packages.sh <requirements.txt>"
    exit 1
fi

# Set variable for the provided file
requirements_file="$1"
echo "Using packages file: ${requirements_file}"

# Check if the specified file exists
if [ ! -f "${requirements_file}" ]; then
    echo "Error: File '${requirements_file}' not found. Ensure the file exists and try again."
    exit 1
fi

# Check if the script is run as the expected user
if [[ $(id -u) -ne $(id -u "${NB_USER}") ]]; then
    echo "Error: This script must be run as ${NB_USER}. Please use USER ${NB_USER} in your Dockerfile before running this script."
    exit 1
fi

echo "  Installing pip packages from ${requirements_file} as ${NB_USER}..."

# Install pip packages and handle errors
if ! ${NB_PYTHON_PREFIX}/bin/pip install --no-cache -r "${requirements_file}"; then
    echo "Error: Installation of packages from '${requirements_file}' failed. Please check the package names and try again."
    exit 1
fi

echo "  Pip packages installed successfully."

