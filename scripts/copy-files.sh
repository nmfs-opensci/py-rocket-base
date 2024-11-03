#!/bin/bash
# Check if files have already been copied
if [ ! -f "${REPO_DIR}/.files_copied" ]; then
    echo "Copying files to ${REPO_DIR}/childimage..."
    sudo -u ${NB_USER} cp -r . ${REPO_DIR}/childimage
    touch "${REPO_DIR}/.files_copied"  # Flag file to indicate copy completion
else
    echo "Files have already been copied to ${REPO_DIR}/childimage. Skipping copy."
fi
