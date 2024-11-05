#!/bin/bash
# Required User: NB_USER

# Check if running as root and switch to NB_USER if needed
if [[ $(id -u) -eq 0 ]]; then
    echo "Switching to ${NB_USER} to run start.sh"
    exec su "${NB_USER}" -c "/bin/bash $0"  # Switches to NB_USER and reruns the script
fi

echo "Running setup-start.sh as ${NB_USER}"

echo "  Checking for ${REPO_DIR}/childimage/..."
if [ -d "${REPO_DIR}/childimage/" ]; then
    cd "${REPO_DIR}/childimage/" || exit 1

    echo "  Checking for start in ${REPO_DIR}/childimage/..."
    if test -f "start"; then
        echo "  start found in ${REPO_DIR}/childimage/."
        # Switch to NB_USER only if the start file exists
        if [[ $(id -u) -eq 0 ]]; then
            echo "  Switching to ${NB_USER} to run setup-start.sh"
            exec su "${NB_USER}" -c "/bin/bash $0"  # Switches to NB_USER and reruns the script
        fi
        chmod +x start
    else
        echo "  No start file found in ${REPO_DIR}/childimage/. Skipping."
    fi
else
    echo "  Directory ${REPO_DIR}/childimage/ does not exist. Skipping."
fi
