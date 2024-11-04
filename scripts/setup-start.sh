#!/bin/bash
# Required User: NB_USER

if [[ $(id -u) -eq 0 ]]; then
    echo "Switching to ${NB_USER} to run setup-desktop.sh"
    exec su "${NB_USER}" -c "/bin/bash $0"  # Switches to NB_USER and reruns the script
fi

echo "Running setup-start.sh as ${NB_USER}"

echo "Checking for start..."
cd "${REPO_DIR}/childimage/" || exit 1
if test -f "start"; then
    chmod +x start
fi
