#!/bin/bash
# Required User: NB_USER

# Install VSCode extensions. 
# These get installed to $CONDA_PREFIX/envs/notebook/share/code-server/extensions/

# Check if a filename argument is provided
if [ -z "$1" ]; then
    echo "Error: install-vscode-extensions.sh requires an input file of extension names (typically called vscode-extensions.txt)." >&2
    echo "Usage: RUN /pyrocket_scripts/install-vscode-extensions.sh <filename>"
    exit 1
fi

# Check if running as root and switch to NB_USER if needed
if [[ $(id -u) -eq 0 ]]; then
    echo "Switching to ${NB_USER} to run install-vscode-extensions.sh"
    exec su "${NB_USER}" -c "/bin/bash $0 $1"  # Pass along the filename argument
fi

echo "Running install-vscode-extensions.sh as ${NB_USER}"

ext_file="$1"

# Verify that ext_file exists and is a file
if [ ! -f "${ext_file}" ]; then
    echo "  Error: Specified file '$ext_file' does not exist."
    exit 1
fi

# Install each extension listed in the file
while IFS= read -r EXT; do
    if code-server --install-extension "$EXT"; then
        echo "  Successfully installed extension: $EXT"
    else
        echo "  Failed to install extension: $EXT" >&2
    fi
done < "$ext_file"

echo "  Success! install-vscode-extensions.sh"
