#!/bin/bash
/scripts/copy-files.sh

echo "Checking for start..."
cd "${REPO_DIR}/childimage/" || exit 1
if test -f "start"; then
    chmod +x start
fi
