#!/bin/bash

# Install VSCode extensions. 
# These get installed to $CONDA_PREFIX/envs/notebook/share/code-server/extensions/

# Check if a filename argument is provided
if [ -z "$1" ]; then
    echo "  Error: No file with extension names provided. Please specify a file."
    echo "  Usage: RUN /pyrocket_scripts/install-vscode-extensions.sh <text file>"
    exit 1
fi

ext_file="$1"

echo "Checking for '$ext_file'..."

if test -f "$ext_file"
then
    for EXT in $(cat "$ext_file")
        do code-server --install-extension $EXT
    done
fi
