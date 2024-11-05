#!/bin/bash
# Required User: NB_USER

# Check if running as root and switch to NB_USER if needed
if [[ $(id -u) -eq 0 ]]; then
    echo "Switching to ${NB_USER} to run start.sh"
    exec su "${NB_USER}" -c "/bin/bash $0"  # Switches to NB_USER and reruns the script
fi

echo "Running setup-start.sh as ${NB_USER}"

# Check if a filename argument is provided
if [ -n "$1" ]; then
    echo "  Warning: Passed-in file '$1' is ignored. Looking for a file named 'start' in your repository." >&2
fi

echo "  Checking for ${REPO_DIR}/childimage/..."
if [ -d "${REPO_DIR}/childimage/" ]; then
    cd "${REPO_DIR}/childimage/" || exit 1

    echo "  Checking for start in ${REPO_DIR}/childimage/..."
    if test -f "start"; then
        echo "  start found in ${REPO_DIR}/childimage/."
        chmod +x start
    else
        echo "  No start file found in ${REPO_DIR}/childimage/. Skipping."
    fi
else
    echo "  Directory ${REPO_DIR}/childimage/ does not exist. Skipping."
fi

echo "  Success! setup-start.sh"
