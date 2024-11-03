#!/bin/bash
# Ensure files are copied before proceeding
/scripts/copy-files.sh

echo "Checking for Desktop directory..."
cd "${REPO_DIR}/childimage/" || exit 1
if test -d Desktop; then
    mkdir -p "${REPO_DIR}/Desktop"
    cp -r Desktop/* "${REPO_DIR}/Desktop/" 2>/dev/null
    chmod +x "${REPO_DIR}/desktop.sh"
    "${REPO_DIR}/desktop.sh"
fi
