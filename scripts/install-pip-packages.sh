#!/bin/bash
# Required User: NB_USER

echo "Running install-pip-packages.sh"

echo "  Checking for ${REPO_DIR}/childimage/..."
if [ -d "${REPO_DIR}/childimage/" ]; then
    cd "${REPO_DIR}/childimage/" || exit 1

    echo "  Checking for requirements.txt in ${REPO_DIR}/childimage/..."
    if test -f "requirements.txt"; then
        # Switch to NB_USER only if requirements.txt exists
        if [[ $(id -u) -eq 0 ]]; then
            echo "Switching to ${NB_USER} to run install-pip-packages.sh"
            exec su "${NB_USER}" -c "/bin/bash $0"  # Switches to NB_USER and reruns the script
        fi

        echo "  Installing pip packages from requirements.txt as ${NB_USER}..."
        ${NB_PYTHON_PREFIX}/bin/pip install --no-cache -r requirements.txt
    else
        echo "  No requirements.txt found. Skipping pip installation."
    fi
else
    echo "  Directory ${REPO_DIR}/childimage/ does not exist. Skipping script."
fi
