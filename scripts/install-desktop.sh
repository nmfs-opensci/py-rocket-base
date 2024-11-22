#!/bin/bash
# Required User: root
# Usage: RUN /pyrocket_scripts/install-desktop.sh <directory path>"

echo "Running install-desktop.sh"

# Check if the script is run as root
if [[ $(id -u) -ne 0 ]]; then
    echo "  Error: This install-desktop.sh must be run as root. Please use 'USER root' in your Dockerfile before running this script."
    echo "  Remember to switch back to the non-root user with 'USER ${NB_USER}' after running this script."
    exit 1
fi

# Check if a directory argument is provided
if [ -z "$1" ]; then
    echo "  Error: No directory provided. Please provide a directory path where the script can find .desktop, .png, and .xml files."
    echo "  Usage: RUN /pyrocket_scripts/install-desktop.sh <directory path>"
    exit 1
fi

# Set TARGET_DIR to the user-provided argument
TARGET_DIR="$1"

# Verify that TARGET_DIR exists and is a directory
if [ ! -d "${TARGET_DIR}" ]; then
    echo "  Error: Provided directory '${TARGET_DIR}' does not exist."
    echo "  Did you run COPY first to copy the directory into the Docker build context?"
    exit 1
fi

# Proceed to copy .desktop, .png, and .xml files from the specified directory
echo "  Looking for Desktop-related files in '${TARGET_DIR}'..."

mkdir -p "${REPO_DIR}/Desktop"

# Find and copy .desktop, .png, and .xml files from TARGET_DIR to ${REPO_DIR}/Desktop
find "${TARGET_DIR}" -type f \( -name "*.desktop" -o -name "*.png" -o -name "*.xml" \) -exec cp {} "${REPO_DIR}/Desktop/" \;

# Check if any files were copied and provide feedback
if [ "$(ls -A "${REPO_DIR}/Desktop" 2>/dev/null)" ]; then
    echo "  Successfully copied Desktop-related files to '${REPO_DIR}/Desktop'."
else
    echo "  Warning: No .desktop, .png, or .xml files found in '${TARGET_DIR}'. Skipping installation."
    exit 0  # Exit without error if no files were found
fi

# Check if desktop.sh exists before executing
if [ -f "${REPO_DIR}/scripts/setup-desktop.sh" ]; then
    echo "  Running ${REPO_DIR}/scripts/setup-desktop.sh to move Desktop files to appropriate directories and register as applications."
    chmod +x "${REPO_DIR}/scripts/setup-desktop.sh"
    "${REPO_DIR}/scripts/setup-desktop.sh"
    echo "  Success! install-desktop.sh Desktop files installed."
else
    echo "  Error: ${REPO_DIR}/scripts/setup-desktop.sh not found. This script is required for Desktop application installation."
    exit 1
fi
