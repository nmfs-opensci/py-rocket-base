#!/bin/bash

echo "Running run-postbuild.sh"

# Check if a filename argument is provided
if [ -z "$1" ]; then
    echo "  Error: No script file provided. Please specify a script file to execute."
    echo "  Usage: RUN /pyrocket_scripts/run-postbuild.sh <script-file>"
    exit 1
fi

# Set SCRIPT_FILE to the provided argument
SCRIPT_FILE="$1"

# Verify that SCRIPT_FILE exists and is a file
if [ ! -f "${SCRIPT_FILE}" ]; then
    echo "  Error: Specified script file '${SCRIPT_FILE}' does not exist."
    exit 1
fi

# Check the user and output which user the script is running as
if [[ $(id -u) -eq 0 ]]; then
    echo "  Running run-postbuild.sh as root."
else
    echo "  Running run-postbuild.sh as ${NB_USER}."
fi

# Make the script executable and run it
chmod +x "${SCRIPT_FILE}"
"${SCRIPT_FILE}"

# Clean up temporary and cached files
rm -rf /tmp/*
rm -rf ${HOME}/.cache ${HOME}/.npm ${HOME}/.yarn
rm -rf ${NB_PYTHON_PREFIX}/share/jupyter/lab/staging
find ${CONDA_DIR} -follow -type f -name '*.a' -delete
find ${CONDA_DIR} -follow -type f -name '*.js.map' -delete

echo "  Success! run-postbuild.sh"

