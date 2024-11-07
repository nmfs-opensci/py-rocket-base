#!/bin/bash

# Install VSCode extensions. 
# These get installed to $CONDA_PREFIX/envs/notebook/share/code-server/extensions/

ext_file="$1"

echo "Checking for '$ext_file'..."

if test -f "$ext_file"
then
    for EXT in $(cat "$ext_file")
        do code-server --install-extension $EXT
    done
fi
