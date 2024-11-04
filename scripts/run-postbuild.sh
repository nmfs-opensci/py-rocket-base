#!/bin/bash

echo "Checking for ${REPO_DIR}/childimage/..."
if [ -d "${REPO_DIR}/childimage/" ]; then
    cd "${REPO_DIR}/childimage/" || exit 1

    echo "Checking for postBuild..."
    if test -f "postBuild"; then
        # Check the user and output which user the script is running as
        if [[ $(id -u) -eq 0 ]]; then
            echo "Running run-postbuild.sh as root."
        else
            echo "Running run-postbuild.sh as ${NB_USER}."
        fi

        chmod +x postBuild
        ./postBuild
        rm -rf /tmp/*
        rm -rf ${HOME}/.cache ${HOME}/.npm ${HOME}/.yarn
        rm -rf ${NB_PYTHON_PREFIX}/share/jupyter/lab/staging
        find ${CONDA_DIR} -follow -type f -name '*.a' -delete
        find ${CONDA_DIR} -follow -type f -name '*.js.map' -delete
    else
        echo "No postBuild file found. Skipping execution."
    fi
else
    echo "Directory ${REPO_DIR}/childimage/ does not exist. Exiting gracefully."
    exit 0  # Exit with a success status
fi
