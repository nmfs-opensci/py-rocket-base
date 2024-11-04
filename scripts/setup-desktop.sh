#!/bin/bash
# Required User: root

echo "Running setup-desktop.sh"

echo "  Checking for ${REPO_DIR}/childimage/..."
if [ -d "${REPO_DIR}/childimage/" ]; then
    cd "${REPO_DIR}/childimage/" || exit 1

    echo "  Checking for Desktop directory..."
    if test -d "${REPO_DIR}/childimage/Desktop"; then
        # Check if the script is run as root
        if [[ $(id -u) -ne 0 ]]; then
            echo "  Error: This script must be run as root." >&2  # Output error message to standard error
            exit 1  # Exit with a non-zero status to indicate failure
        fi

        echo "  Running setup-desktop.sh as root. Proceeding with installation..."

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
