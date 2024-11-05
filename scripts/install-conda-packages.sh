#!/bin/bash
# Required User: NB_USER

echo "Running install-conda-packages.sh"

echo "  Checking for ${REPO_DIR}/childimage/..."
if [ -d "${REPO_DIR}/childimage/" ]; then
    cd "${REPO_DIR}/childimage/" || exit 1

    echo "  Checking for conda-lock.yml or environment.yml in ${REPO_DIR}/childimage/..."
    if test -f "conda-lock.yml" || test -f "environment.yml"; then
        # Switch to NB_USER only if the relevant files exist
        if [[ $(id -u) -eq 0 ]]; then
            echo "  Switching to ${NB_USER} to run install-conda-packages.sh"
            exec su "${NB_USER}" -c "/bin/bash $0"  # Switches to NB_USER and reruns the script
        fi
        
        if test -f "conda-lock.yml"; then
            echo "  Using conda-lock.yml"
            ${NB_PYTHON_PREFIX}/bin/conda-lock install --name ${CONDA_ENV}
            ${NB_PYTHON_PREFIX}/bin/pip install --no-deps jupyter-remote-desktop-proxy
            INSTALLATION_HAPPENED=true
        elif test -f "environment.yml"; then
            echo "  Using environment.yml"
            ${CONDA_DIR}/condabin/mamba env update --name ${CONDA_ENV} -f environment.yml
            ${NB_PYTHON_PREFIX}/bin/pip install --no-deps jupyter-remote-desktop-proxy
            INSTALLATION_HAPPENED=true
        fi

        # Only run cleanup if installation occurred
        if [ "$INSTALLATION_HAPPENED" = true ]; then
            ${CONDA_DIR}/condabin/mamba clean -yaf
            find ${CONDA_DIR} -follow -type f -name '*.a' -delete
            find ${CONDA_DIR} -follow -type f -name '*.js.map' -delete
            if ls ${NB_PYTHON_PREFIX}/lib/python*/site-packages/bokeh/server/static > /dev/null 2>&1; then
                find ${NB_PYTHON_PREFIX}/lib/python*/site-packages/bokeh/server/static -follow -type f -name '*.js' ! -name '*.min.js' -delete
            fi
        fi
    else
        echo "  No conda-lock.yml or environment.yml found. Skipping installation."
    fi
else
    echo "  Directory ${REPO_DIR}/childimage/ does not exist. Skipping script."
fi
