#!/bin/bash
/scripts/copy-files.sh

echo "Checking for conda-lock.yml or environment.yml..."
cd "${REPO_DIR}/childimage/" || exit 1
if test -f "conda-lock.yml"; then
    echo "Using conda-lock.yml"
    conda-lock install --name ${CONDA_ENV}
    pip install --no-deps jupyter-remote-desktop-proxy
elif test -f "environment.yml"; then
    echo "Using environment.yml"
    mamba env update --name ${CONDA_ENV} -f environment.yml
    pip install --no-deps jupyter-remote-desktop-proxy
fi
mamba clean -yaf
find ${CONDA_DIR} -follow -type f -name '*.a' -delete
find ${CONDA_DIR} -follow -type f -name '*.js.map' -delete
if ls ${NB_PYTHON_PREFIX}/lib/python*/site-packages/bokeh/server/static > /dev/null 2>&1; then
    find ${NB_PYTHON_PREFIX}/lib/python*/site-packages/bokeh/server/static -follow -type f -name '*.js' ! -name '*.min.js' -delete
fi