#!/bin/bash
# Required User: NB_USER

# Check if a filename argument is provided
if [ -z "$1" ]; then
    echo "Error: install-conda-packages.sh requires a file name (either conda-lock.yml or environment.yml)." >&2
    echo "Usage: RUN /pyrocket_scripts/install-conda-packages.sh <filename.yml> [env_name]" >&2
    exit 1
fi

# Set the environment name, defaulting to ${CONDA_ENV} if not provided
ENV_FILE="$1"
ENV_NAME="${2:-${CONDA_ENV}}"

# Check if running as root and switch to NB_USER if needed
if [[ $(id -u) -eq 0 ]]; then
    echo "Switching to ${NB_USER} to run install-conda-packages.sh"
    exec su "${NB_USER}" -c "/bin/bash $0 $ENV_FILE $ENV_NAME"
fi

# Main script execution as NB_USER
echo "Running install-conda-packages.sh as ${NB_USER}"
echo "  Using environment file: $ENV_FILE"
echo "  Target environment: $ENV_NAME"

# Verify the file exists and is readable
if [ ! -f "$ENV_FILE" ]; then
    echo "  Error: File '$ENV_FILE' not found. Please provide a valid file path." >&2
    exit 1
fi

# Check if the Conda environment exists
if ! ${CONDA_DIR}/condabin/conda env list | grep -q "^$ENV_NAME "; then
    echo "  Environment '$ENV_NAME' not found. Creating it."

    # Create environment based on file type
    if grep -q "lock_set" "$ENV_FILE"; then
        echo "  Detected conda-lock.yml file."
        ${NB_PYTHON_PREFIX}/bin/conda-lock install --name $ENV_NAME -f "$ENV_FILE"
    elif grep -q "name:" "$ENV_FILE"; then
        echo "  Detected environment.yml file."
        ${CONDA_DIR}/condabin/mamba env create -f "$ENV_FILE" --name $ENV_NAME
    else
        echo "Error: Unrecognized file format in '$ENV_FILE'."
        exit 1
    fi
else
    echo "  Environment '$ENV_NAME' exists. Updating it."

    # Update environment based on file type
    if grep -q "lock_set" "$ENV_FILE"; then
        echo "  Detected conda-lock.yml file."
        ${NB_PYTHON_PREFIX}/bin/conda-lock install --name $ENV_NAME -f "$ENV_FILE"
    elif grep -q "name:" "$ENV_FILE"; then
        echo "  Detected environment.yml file."
        ${CONDA_DIR}/condabin/mamba env update --name $ENV_NAME -f "$ENV_FILE"
    else
        echo "Error: Unrecognized file format in '$ENV_FILE'."
        exit 1
    fi
fi

# Clean up if installation occurred
${CONDA_DIR}/condabin/mamba clean -yaf
find ${CONDA_DIR} -follow -type f -name '*.a' -delete
find ${CONDA_DIR} -follow -type f -name '*.js.map' -delete
if ls ${NB_PYTHON_PREFIX}/lib/python*/site-packages/bokeh/server/static > /dev/null 2>&1; then
    find ${NB_PYTHON_PREFIX}/lib/python*/site-packages/bokeh/server/static -follow -type f -name '*.js' ! -name '*.min.js' -delete
fi

echo "  Success! install-conda-packages.sh"
