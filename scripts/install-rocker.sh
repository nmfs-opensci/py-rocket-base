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
    echo "Error: install-rocker.sh requires a rocker Dockerfile prefix. Will look like verse.4.1.1. Exiting." >&2
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
# R_VERSION_PULL may be different than R_VERSION. Specifically pulling latest but using R_VERSION prior to latest
# So that CRAN repo is pinned to a date.
cd ${REPO_DIR}
ROCKER_DOCKERFILE_NAME="${R_DOCKERFILE}.Dockerfile"
# Pull a tag (release) or pull the latest master (stable)
# TAR_NAME="R${R_VERSION_PULL}"
TAR_NAME="master"
# For degugging use: wget https://github.com/eeholmes/rocker-versioned2/archive/refs/tags/R4.4.1.tar.gz
# wget https://github.com/rocker-org/rocker-versioned2/archive/refs/tags/R${R_VERSION_PULL}.tar.gz
if [[ "$TAR_NAME" == "master" ]]; then
    wget https://github.com/rocker-org/rocker-versioned2/archive/refs/heads/${TAR_NAME}.tar.gz
else
    wget https://github.com/rocker-org/rocker-versioned2/archive/refs/tags/${TAR_NAME}.tar.gz
fi
tar zxvf ${TAR_NAME}.tar.gz && \
mv rocker-versioned2-${TAR_NAME}/scripts /rocker_scripts && \
mv rocker-versioned2-${TAR_NAME}/dockerfiles/${ROCKER_DOCKERFILE_NAME} /rocker_scripts/original.Dockerfile && \
rm ${TAR_NAME}.tar.gz && \
rm -rf rocker-versioned2-${TAR_NAME}

cd /

# Read the Dockerfile and process each line
in_run_block=false
cmd=""

while IFS= read -r line; do
    if [[ "$line" == ENV* ]]; then
        var_assignment=$(echo "$line" | sed 's/^ENV //g')
        if [[ "$var_assignment" == DEFAULT_USER* ]]; then
            var_assignment="DEFAULT_USER=${NB_USER}"
        fi
        eval "export $var_assignment"
        echo "export $var_assignment" >> "${REPO_DIR}/env.txt"
    
    elif [[ "$line" == RUN* ]]; then
        # Detect start of a multi-line RUN block
        if [[ "$line" =~ RUN\ \<\<([A-Za-z0-9_]+) ]]; then
            in_run_block=true
            cmd=""  # Reset command buffer
            eof_marker="${BASH_REMATCH[1]}"  # Store EOF marker (e.g., EOF)
            continue
        fi
        cmd=$(echo "$line" | sed 's/^RUN //g')
        echo "Executing: $cmd"
        eval "$cmd"

    elif $in_run_block; then
        # Detect end of the here-document
        if [[ "$line" == "$eof_marker" ]]; then
            in_run_block=false
            echo "Executing multi-line RUN block:"
            echo "$cmd"
            eval "$cmd"
        else
            cmd+=$'\n'"$line"
        fi
    fi
done < /rocker_scripts/original.Dockerfile

# Install extra tex packages that are not installed by default
if command -v tlmgr &> /dev/null; then
    echo "Installing texlive collection-latexrecommended..."
    tlmgr install collection-latexrecommended
    tlmgr install pdfcol tcolorbox eurosym upquote adjustbox titling enumitem ulem soul rsfs
fi
