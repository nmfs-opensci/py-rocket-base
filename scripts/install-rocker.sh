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
cd ${REPO_DIR}
ROCKER_DOCKERFILE_NAME="${R_DOCKERFILE}.Dockerfile"
# Pull a tag (release) or pull the latest master (stable); R_VERSION_PULL is defined in Dockerfile when this script is called.
TAR_NAME=${R_VERSION_PULL}
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
        # Special handling for CRAN
        if [[ "$var_assignment" =~ ^CRAN=.*__linux__/([^/]+)/(.+)$ ]]; then
            var_assignment="CRAN=https://p3m.dev/cran/__linux__/${UBUNTU_VERSION}/${BASH_REMATCH[2]//\"/}"
        fi
        # Special handling for DEFAULT_USER
        if [[ "$var_assignment" == DEFAULT_USER* ]]; then
            var_assignment="DEFAULT_USER=${NB_USER}"
        fi
        echo "Processed ENV variable: $var_assignment"
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

# Make sure the env vars set in the rocker Dockerfile are in Renviron.site
ENV_FILE="${REPO_DIR}/env.txt"
RENVIRO_SITE="${R_HOME}/etc/Renviron.site"

# Ensure the file exists before processing
if [[ -f "$ENV_FILE" ]]; then
    echo "Appending environment variables from $ENV_FILE to $RENVIRO_SITE..."

    awk -F '=' '
    /^export / {
        gsub(/"/, "", $2);  # Remove double quotes around values
        if ($1 ~ /PATH/) {
            print substr($1, 8) "=\"" ENVIRON["PATH"] ":" $2 "\""
        } else {
            print substr($1, 8) "=\"" $2 "\""
        }
    }' "$ENV_FILE" > "$RENVIRO_SITE"

    echo "Done."
else
    echo "Warning: $ENV_FILE not found. No changes made."
fi

# Ensure jovyan can modify Rprofile.site and Renviron.site because start will need to this
# to set the gh-scoped-cred variables if they are present
chown ${NB_USER}:staff ${R_HOME}/etc/Rprofile.site
chmod g+w ${R_HOME}/etc/Rprofile.site
chown ${NB_USER}:staff ${R_HOME}/etc/Renviron.site
chmod g+w ${R_HOME}/etc/Renviron.site

echo "Updated permissions for Rprofile.site and Renviron.site"
