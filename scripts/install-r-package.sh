#!/bin/bash
# Required User: NB_USER

echo "Running install-r-packages.sh"

echo "Checking for ${REPO_DIR}/childimage/..."
if [ -d "${REPO_DIR}/childimage/" ]; then
    cd "${REPO_DIR}/childimage/" || exit 1

    echo "Checking for install.R in ${REPO_DIR}/childimage/..."
    if test -f "install.R"; then
        # Switch to NB_USER only if install.R exists
        if [[ $(id -u) -eq 0 ]]; then
            echo "Switching to ${NB_USER} to run install-r-packages.sh"
            exec su "${NB_USER}" -c "/bin/bash $0"  # Switches to NB_USER and reruns the script
        fi

        echo "Using install.R to install R packages as ${NB_USER}..."
        Rscript install.R
    else
        echo "No install.R found. Skipping R package installation."
    fi
else
    echo "Directory ${REPO_DIR}/childimage/ does not exist. Skipping script."
fi
