#!/bin/bash
/scripts/copy-files.sh

echo "Checking for install.R..."
cd "${REPO_DIR}/childimage/" || exit 1
if test -f "install.R"; then
    echo "Using install.R"
    Rscript install.R
fi
