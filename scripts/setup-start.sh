#!/bin/bash
# Required User: NB_USER

echo "Checking for ${REPO_DIR}/childimage/..."
if [ -d "${REPO_DIR}/childimage/" ]; then
    cd "${REPO_DIR}/childimage/" || exit 1

    echo "Checking for start..."
    if test -f "start"; then
        # Switch to NB_USER only if the start file exists
        if [[ $(id -u) -eq 0 ]]; then
            echo "Switching to ${NB_USER} to run setup-start.sh"
            exec su "${NB_USER}" -c "/bin/bash $0"  # Switches to NB_USER and reruns the script
        fi

        echo "Running setup-start.sh as ${NB_USER}"
        chmod +x start
        # Optionally, you can execute the start script here
        ./start
    else
        echo "No start file found. Skipping execution."
    fi
else
    echo "Directory ${REPO_DIR}/childimage/ does not exist. Exiting gracefully."
    exit 0  # Exit with a success status
fi
