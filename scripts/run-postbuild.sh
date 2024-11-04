#!/bin/bash

echo "Checking for postBuild..."
cd "${REPO_DIR}/childimage/" || exit 1

if test -f "postBuild"; then
    # Check the user and output which user the script is running as
    if [[ $(id -u) -eq 0 ]]; then
        echo "Running as root."
    else
        echo "Running as ${NB_USER}."
    fi

    chmod +x postBuild
    ./postBuild
    rm -rf /tmp/*
    rm -rf ${HOME}/.cache ${HOME}/.npm ${HOME}/.yarn
    rm -rf ${NB_PYTHON_PREFIX}/share/jupyter/lab/staging
    find ${CONDA_DIR} -follow -type f -name '*.a' -delete
    find ${CONDA_DIR} -follow -type f -name '*.js.map' -delete
fi
