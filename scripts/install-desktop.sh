#!/bin/bash
# Required User: root

echo "Running setup-desktop.sh"

# Check if the script is run as root
if [[ $(id -u) -ne 0 ]]; then
    echo "  Error: This script must be run as root. Please use 'USER root' in your Dockerfile before running this script."
    echo "  Remember to switch back to the non-root user with 'USER ${NB_USER}' after running this script."
    exit 1
fi

# Check if a filename argument is provided
if [ -n "$1" ]; then
    echo "  Warning: Passed-in file '$1' is ignored. Looking for Desktop files in the 'Desktop' directory in your repository." >&2
fi

echo "  Checking for ${REPO_DIR}/childimage/..."
if [ -d "${REPO_DIR}/childimage/" ]; then
    cd "${REPO_DIR}/childimage/" || exit 1

    echo "  Checking for Desktop directory..."
    if test -d "${REPO_DIR}/childimage/Desktop"; then

        echo "  ${REPO_DIR}/childimage/Desktop directory found. Proceeding with installation..."

        mkdir -p "${REPO_DIR}/Desktop"
        cp -r ${REPO_DIR}/childimage/Desktop/* "${REPO_DIR}/Desktop/" 2>/dev/null

        # Check if desktop.sh exists before executing
        if test -f "${REPO_DIR}/desktop.sh"; then
            echo "  Running ${REPO_DIR}/desktop.sh."
            chmod +x "${REPO_DIR}/desktop.sh"
            "${REPO_DIR}/desktop.sh"
        else
            echo "  Warning: desktop.sh not found. Skipping execution."
        fi
    else
        echo "  No Desktop directory found in ${REPO_DIR}/childimage/. Skipping setup."
    fi
else
    echo "  Directory ${REPO_DIR}/childimage/ does not exist. Skipping script."
fi

echo "  Success! install-desktop.sh"
