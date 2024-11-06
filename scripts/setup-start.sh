#!/bin/bash
# Required User: NB_USER

# Check if a filename argument is provided
if [ -z "$1" ]; then
    echo "Error: setup-start.sh requires a script file to be provided as an argument." >&2
    echo "Usage: /pyrocket_scripts/setup-start.sh <filename>" >&2
    exit 1
fi

# Check if running as root and switch to NB_USER if needed
if [[ $(id -u) -eq 0 ]]; then
    echo "Switching to ${NB_USER} to run setup-start.sh"
    exec su "${NB_USER}" -c "/bin/bash $0 $1"  # Pass the script file as an argument
fi

echo "Running setup-start.sh as ${NB_USER}"

SCRIPT_FILE="$1"

# Check if the specified file exists
if [ ! -f "$SCRIPT_FILE" ]; then
    echo "  Error: The file '$SCRIPT_FILE' does not exist." >&2
    echo "  Did you use COPY to copy the file into the Docker build context?"
    exit 1
fi

# Ensure ${REPO_DIR}/childstarts exists
mkdir -p "${REPO_DIR}/childstarts"

# Copy the passed script to the childstarts directory
echo "  Copying '$SCRIPT_FILE' to ${REPO_DIR}/childstarts/"
cp "$SCRIPT_FILE" "${REPO_DIR}/childstarts/"

# Make the copied script executable
chmod +x "${REPO_DIR}/childstarts/$(basename "$SCRIPT_FILE")"

echo "  Success! setup-start.sh"
