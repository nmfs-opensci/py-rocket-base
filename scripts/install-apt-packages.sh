#!/bin/bash
# Required User: root

echo "Running install-apt-packages.sh"

# Check that a file name is provided
if [ -z "$1" ]; then
    echo "  Error: No file provided. Usage: RUN /pyrocket_scripts/install-apt-packages.sh <apt.txt>"
    exit 1
fi

# Set variable for the provided file
apt_file="$1"
echo "  Using packages file: ${apt_file}"

# Check if the specified file exists
if [ ! -f "${apt_file}" ]; then
    echo "  Error: File '${apt_file}' not found. Ensure the file exists and try again."
    exit 1
fi

# Check if the script is run as root
if [[ $(id -u) -ne 0 ]]; then
    echo "  Error: This script must be run as root. Please use 'USER root' in your Dockerfile before running this script."
    echo "  Remember to switch back to the non-root user with 'USER ${NB_USER}' after running this script."
    exit 1
fi

echo "  Running install-apt-packages.sh as root. Proceeding with installation..."

# Update package list and handle errors
echo "  Updating package list..."
if ! apt-get update --fix-missing; then
    echo "  Error: Failed to update package list. Exiting."
    exit 1
fi

# Install packages and handle errors
echo "  Installing packages from ${apt_file}..."
package_list=$(grep -v '^\s*#' "${apt_file}" | grep -v '^\s*$' | sed 's/\r//g; s/#.*//; s/^[[:space:]]*//; s/[[:space:]]*$//' | awk '{$1=$1};1')
if ! apt-get install --yes --no-install-recommends $package_list; then
    echo "  Error: Installation of packages failed. Please check the package names and try again."
    exit 1
fi

# Clean up
apt-get autoremove --purge
apt-get clean
rm -rf /var/lib/apt/lists/*

echo "  Success! install-apt-packages.sh"
