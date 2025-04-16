#!/bin/bash
# Required User: NB_USER

# Check if a filename argument is provided
if [ -z "$1" ]; then
    echo "Error: install-r-packages.sh requires an input file (an R script and typically called install.R)." >&2
    echo "Usage: RUN /pyrocket_scripts/install-r-packages.sh <filename>" >&2
    exit 1
fi

# Check if running as root and switch to NB_USER if needed
if [[ $(id -u) -eq 0 ]]; then
    echo "Switching to ${NB_USER} to run install-r-packages.sh"
    exec su "${NB_USER}" -c "/bin/bash $0 $1"  # Pass along the filename argument
fi

# Main script execution as NB_USER
echo "Running install-r-packages.sh as ${NB_USER}"

# Make sure we install to the System library
syslib <- .Library
.libPaths(c(syslib, .libPaths()))

# Set the file variable to the provided argument
INSTALL_FILE="$1"

# Verify the file exists and is readable
if [ ! -f "$INSTALL_FILE" ]; then
    echo "  Error: File '$INSTALL_FILE' not found. Please provide a valid R script file." >&2
    echo "  Usage: RUN /pyrocket_scripts/install-r-packages.sh <filename>" >&2
    exit 1
fi

echo "  Found file: $INSTALL_FILE"

# Install R packages using the provided R script
if ! Rscript "$INSTALL_FILE"; then
    echo "  Error: Installation of packages from '$INSTALL_FILE' failed. Please check the script for errors." >&2
    exit 1
fi

echo "  Success! install-r-packages.sh"
