#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
# Required User: root

# Install VSCode extensions. 
# These get installed to ${NB_PYTHON_PREFIX}/share/code-server/extensions/

# Check if a filename argument is provided
if [ -z "$1" ]; then
    echo "Error: install-vscode-extensions.sh requires an input file of extension names (typically called vscode-extensions.txt)." >&2
    echo "Usage: RUN /pyrocket_scripts/install-vscode-extensions.sh <filename>"
    exit 1
fi

# Check if the script is run as root; 
# Since some prior installs might have created .local as root. Easier just to install vscode extensions as root
if [[ $(id -u) -ne 0 ]]; then
    echo "Error: install-vscode-extensions.sh must be run as root. Please use 'USER root' in your Dockerfile before running this script."
    echo "Remember to switch back to the non-root user with 'USER ${NB_USER}' after running this script."
    exit 1
fi

echo "Running install-vscode-extensions.sh as $(whoami)"
echo "PATH = ${PATH}"

ext_file="$1"

# Verify that ext_file exists and is a file
if [ ! -f "${ext_file}" ]; then
    echo "  Error: Specified file '$ext_file' does not exist."
    exit 1
fi

# Set the extensions directory to be the conda dir so that it persists
# Create if it doesn't exist; make owner jovyan
EXT_DIR="${NB_PYTHON_PREFIX}/share/code-server/extensions"
install -o ${NB_USER} -g ${NB_USER} -m 755 -d "${EXT_DIR}"

# Install each extension listed in the file; skip empty lines or comments
FAILED=0
while IFS= read -r EXT; do
    # Remove comments and leading/trailing whitespace
    EXT=$(echo "$EXT" | sed 's/#.*//; s/^[[:space:]]*//; s/[[:space:]]*$//')

    # Skip if the line is now empty
    [[ -z "$EXT" ]] && continue

    echo "Installing extension: $EXT"

    if ${NB_PYTHON_PREFIX}/bin/code-server --extensions-dir "${EXT_DIR}" --install-extension "$EXT"; then
        echo "  Successfully installed extension from open-vsx: $EXT"
    else
        echo "  Failed to install $EXT from open-vsx. Trying local vsix..."

        # Try to install local VSIX
        if [ -f "${REPO_DIR}/extensions/${EXT}.vsix" ]; then
            if ${NB_PYTHON_PREFIX}/bin/code-server --extensions-dir "${EXT_DIR}" --install-extension "${REPO_DIR}/extensions/${EXT}.vsix"; then
                echo "  Successfully installed extension from local vsix: $EXT"
            else
                echo "  Failed to install local vsix for extension: $EXT" >&2
                FAILED=1
            fi
        else
            echo "  No local vsix file found for extension: $EXT" >&2
            FAILED=1
        fi
    fi
done < "$ext_file"

# Fix ownership so user can install/uninstall extensions later
echo "Fixing ownership of installed extensions..."
chown -R ${NB_USER}:${NB_USER} "${EXT_DIR}"
chmod -R u+rwX,go+rX "${EXT_DIR}"

if [ "$FAILED" -ne 0 ]; then
  echo "One or more VSCode extensions failed to install. Exiting." >&2
  exit 1
fi
