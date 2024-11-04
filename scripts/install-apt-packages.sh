#!/bin/bash
# Required User: root

# Check if the script is run as root
if [[ $(id -u) -ne 0 ]]; then
    echo "Error: This script must be run as root." >&2  # Output error message to standard error
    exit 1  # Exit with a non-zero status to indicate failure
fi

# The rest of the script continues here, running as root
echo "Running install-apt-packages.sh as root. Proceeding with installation..."

echo "Checking for apt.txt..."
cd "${REPO_DIR}/childimage/" || exit 1
if test -f "apt.txt"; then
    package_list=$(grep -v '^\s*#' apt.txt | grep -v '^\s*$' | sed 's/\r//g; s/#.*//; s/^[[:space:]]*//; s/[[:space:]]*$//' | awk '{$1=$1};1')
    apt-get update --fix-missing > /dev/null
    apt-get install --yes --no-install-recommends $package_list
    apt-get autoremove --purge
    apt-get clean
    rm -rf /var/lib/apt/lists/*
fi
