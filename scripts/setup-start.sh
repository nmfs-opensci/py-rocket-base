#!/bin/bash
# Required User: root

# Check if the script is run as root
if [[ $(id -u) -ne 0 ]]; then
    echo "Error: This script must be run as root." >&2  # Output error message to standard error
    exit 1  # Exit with a non-zero status to indicate failure
fi

# The rest of the script continues here, running as root
echo "Running setup-start.sh as root. Proceeding with installation..."

/scripts/copy-files.sh

echo "Checking for start..."
cd "${REPO_DIR}/childimage/" || exit 1
if test -f "start"; then
    chmod +x start
fi
