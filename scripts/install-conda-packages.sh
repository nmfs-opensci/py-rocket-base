#!/bin/bash
# Required User: NB_USER

# Check if running as root and switch to NB_USER if needed
if [[ $(id -u) -eq 0 ]]; then
    echo "Switching to ${NB_USER} to run install-conda-packages.sh"
    exec su "${NB_USER}" -c "/bin/bash $0 $1"  # Pass along the filename argument
fi

# Main script execution as NB_USER
echo "Running install-conda-packages.sh"

# Check if a filename argument is provided
if [ -z "$1" ]; then
    echo "  Error: This script requires a file name (either conda-lock.yml or environment.yml)." >&2
    echo "  Usage: RUN /pyrocket_scripts/install-conda-packages.sh <filename.yml>" >&2
    exit 1
fi

# Set the file variable to the provided argument
ENV_FILE="$1"

# Verify the file exists and is readable
if [ ! -f "$ENV_FILE" ]; then
    echo "  Error: File '$ENV_FILE' not found. Please provide a valid file path." >&2
    echo "  Usage: RUN /pyrocket_scripts/install-conda-packages.sh <filename.yml>" >&2
    exit 1
fi

echo "  Found file: $ENV_FILE"

# Determine file type based on content
if grep -q "lock_set" "$ENV_FILE"; then
    echo "  Detected conda-lock.yml file."
    ${NB_PYTHON_PREFIX}/bin/conda-lock install --name ${CONDA_ENV} -f "$ENV_FILE"
    INSTALLATION_HAPPENED=true
elif grep -q "name:" "$ENV_FILE"; then
    echo "  Detected environment.yml file."
    ${CONDA_DIR}/condabin/mamba env update --name ${CONDA_ENV} -f "$ENV_FILE"
    INSTALLATION_HAPPENED=true
else
    # If neither condition matches, output a helpful error message
    echo "Error: Unrecognized file format in '${env_file}'."
    echo "  - For an environment.yml file, ensure it includes a 'name:' entry. Any name is acceptable."
    echo "  - For a conda-lock.yml file, ensure it includes a 'lock_set:' entry."
    exit 1
fi

# Run cleanup if installation occurred
if [ "$INSTALLATION_HAPPENED" = true ]; then
    ${CONDA_DIR}/condabin/mamba clean -yaf
    find ${CONDA_DIR} -follow -type f -name '*.a' -delete
    find ${CONDA_DIR} -follow -type f -name '*.js.map' -delete
    if ls ${NB_PYTHON_PREFIX}/lib/python*/site-packages/bokeh/server/static > /dev/null 2>&1; then
        find ${NB_PYTHON_PREFIX}/lib/python*/site-packages/bokeh/server/static -follow -type f -name '*.js' ! -name '*.min.js' -delete
    fi
fi
