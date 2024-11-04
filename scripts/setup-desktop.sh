#!/bin/bash
# Required User: root

# Check if the script is run as root
if [[ $(id -u) -ne 0 ]]; then
    echo "Error: This script must be run as root." >&2  # Output error message to standard error
    exit 1  # Exit with a non-zero status to indicate failure
fi

# The rest of the script continues here, running as root
echo "Running setup-desktop.sh as root. Proceeding with installation..."

# Ensure files are copied before proceeding
/scripts/copy-files.sh

echo "Checking for Desktop directory..."
cd "${REPO_DIR}/childimage/" || exit 1
if test -d Desktop; then
    mkdir -p "${REPO_DIR}/Desktop"
    cp -r Desktop/* "${REPO_DIR}/Desktop/" 2>/dev/null
    chmod +x "${REPO_DIR}/desktop.sh"
    "${REPO_DIR}/desktop.sh"
fi
