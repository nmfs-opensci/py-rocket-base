#!/bin/bash
/scripts/copy-files.sh

echo "Checking for pip requirements.txt..."
cd "${REPO_DIR}/childimage/" || exit 1
if test -f "requirements.txt"; then
    ${NB_PYTHON_PREFIX}/bin/pip install --no-cache -r requirements.txt
fi
