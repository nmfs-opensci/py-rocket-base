#!/bin/bash
# Required User: root

echo "Running install-apt-packages.sh"
echo "  Checking for ${REPO_DIR}/childimage/..."
if [ -d "${REPO_DIR}/childimage/" ]; then
    cd "${REPO_DIR}/childimage/" || exit 1

    echo "  Checking for apt.txt in ${REPO_DIR}/childimage/..."
    if test -f "apt.txt"; then
        # Check if the script is run as root
        if [[ $(id -u) -ne 0 ]]; then
            echo "  Error: This script must be run as root." >&2  # Output error message to standard error
            exit 1  # Exit with a non-zero status to indicate failure
        fi

        echo "  Running install-apt-packages.sh as root. Proceeding with installation..."

        package_list=$(grep -v '^\s*#' apt.txt | grep -v '^\s*$' | sed 's/\r//g; s/#.*//; s/^[[:space:]]*//; s/[[:space:]]*$//' | awk '{$1=$1};1')
        apt-get update --fix-missing > /dev/null
        apt-get install --yes --no-install-recommends $package_list
        apt-get autoremove --purge
        apt-get clean
        rm -rf /var/lib/apt/lists/*
    else
        echo "  No apt.txt found. Skipping package installation."
    fi
else
    echo "  Directory ${REPO_DIR}/childimage/ does not exist. Skipping script."
fi
