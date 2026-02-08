#!/bin/bash
# Required User: root
set -euo pipefail

echo "Running fix-home-permissions.sh"

# Check if the script is run as root
if [[ $(id -u) -ne 0 ]]; then
    echo "Error: fix-home-permissions.sh must be run as root. Please use 'USER root' in your Dockerfile before running this script."
    echo "Remember to switch back to the non-root user with 'USER ${NB_USER}' after running this script."
    exit 1
fi

echo "Running fix-home-permissions.sh as $(whoami)..."

# Define the target directory
TARGET_DIR="/home/${NB_USER}"

# Change ownership only for items not owned by ${NB_USER}
sudo find "${TARGET_DIR}" ! -user "${NB_USER}" -exec chown "${NB_USER}:${NB_USER}" {} \;

# Set permissions on all directories: read, write, and execute for ${NB_USER}
sudo find "${TARGET_DIR}" -type d -exec chmod 755 {} \;

# Set permissions on all files: read and write for ${NB_USER}
sudo find "${TARGET_DIR}" -type f -exec chmod 644 {} \;
