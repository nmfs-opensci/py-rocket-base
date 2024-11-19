#!/bin/bash
set -e

echo "Running install-rocker.sh"

# Check if the script is run as root
if [[ $(id -u) -ne 0 ]]; then
    echo "Error: install-rocker.sh must be run as root. Please use 'USER root' in your Dockerfile before running this script. Exiting"
    echo "Remember to switch back to the non-root user with 'USER ${NB_USER}' after running this script."
    exit 1
fi

if [ -z "$R_VERSION" ]; then
  echo "Error: install-rocker.sh requires that the environment variable R_VERSION is set. Exiting."
  exit 1
fi

# Check if a filename argument is provided
if [ -z "$1" ]; then
    echo "Error: install-rocker.sh requires a rocker Dockerfile prefix. Will looke like verse.4.1.1. Exiting." >&2
    echo "Usage: RUN /pyrocket_scripts/install-conda-packages.sh <filename>" >&2
    exit 1
fi

# Set the Docker name
R_DOCKERFILE="$1"

# This script will copy in the rocker_scripts to install things and
# Install rocker-verse using the TAG_${R_VERSION}.Dockerfile file
# It will run just the ENV and RUN commands in that file
# Variables defined here will only be available in this script.

# Set the PATH. REQUIRED to avoid conda in the path
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Copy in the rocker files. Work in ${REPO_DIR} to make sure I don't clobber anything
cd ${REPO_DIR}
ROCKER_DOCKERFILE_NAME="${R_DOCKERFILE}.Dockerfile"
# For degugging use: wget https://github.com/eeholmes/rocker-versioned2/archive/refs/tags/R4.4.1.tar.gz
wget https://github.com/rocker-org/rocker-versioned2/archive/refs/tags/R${R_VERSION}.tar.gz
tar zxvf R${R_VERSION}.tar.gz && \
mv rocker-versioned2-R${R_VERSION}/scripts /rocker_scripts && \
mv rocker-versioned2-R${R_VERSION}/dockerfiles/${ROCKER_DOCKERFILE_NAME} /rocker_scripts/original.Dockerfile && \
rm R${R_VERSION}.tar.gz && \
rm -rf rocker-versioned2-R${R_VERSION}

cd /
# Read the Dockerfile and process each line
while IFS= read -r line; do
    # Check if the line starts with ENV or RUN
    if [[ "$line" == ENV* ]]; then
        # Assign variable
        var_assignment=$(echo "$line" | sed 's/^ENV //g')
        # Replace ENV DEFAULT_USER="jovyan"
        if [[ "$var_assignment" == DEFAULT_USER* ]]; then
            var_assignment="DEFAULT_USER=${NB_USER}"
        fi
        # Run this way eval "export ..." otherwise the " will get turned to %22
        eval "export $var_assignment"
        # Write the exported variable to env.txt
        echo "export $var_assignment" >> ${REPO_DIR}/env.txt
    elif [[ "$line" == RUN* ]]; then
        # Run the command from the RUN line
        cmd=$(echo "$line" | sed 's/^RUN //g')
        echo "Executing: $cmd"
        eval "$cmd" # || echo ${cmd}" encountered an error, but continuing..."
    fi
done < /rocker_scripts/original.Dockerfile

# Install extra tex packages that are not installed by default
if command -v tlmgr &> /dev/null; then
    echo "Installing texlive collection-latexrecommended..."
    tlmgr install collection-latexrecommended
    tlmgr install pdfcol tcolorbox eurosym upquote adjustbox titling enumitem ulem soul rsfs
fi
