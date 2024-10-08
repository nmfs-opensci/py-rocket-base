#!/bin/bash
set -e

# This script will copy in the rocker_scripts to install things and
# Install rocker-verse using the verse_${R_VERSION}.Dockerfile file
# It will run just the ENV and RUN commands in that file

R_VERSION="4.4.1"

# Copy in the rocker files
cd ${REPO_DIR}
wget https://github.com/rocker-org/rocker-versioned2/archive/refs/tags/R${R_VERSION}.tar.gz
tar zxvf R${R_VERSION}.tar.gz && \
mv rocker-versioned2-R${R_VERSION}/scripts rocker_scripts && \
mv rocker-versioned2-R${R_VERSION}/dockerfiles/verse_${R_VERSION}.Dockerfile rocker_scripts/verse_${R_VERSION}.Dockerfile && \
rm R${R_VERSION}.tar.gz && \
rm -rf rocker-versioned2-R${R_VERSION}

# Read the Dockerfile and process each line
while IFS= read -r line; do
    # Check if the line starts with ENV or RUN
    if [[ "$line" == ENV* ]]; then
        # Export the environment variable from the ENV line
        eval $(echo "$line" | sed 's/^ENV //g')
    elif [[ "$line" == RUN* ]]; then
        # Run the command from the RUN line
        cmd=$(echo "$line" | sed 's/^RUN //g')
        echo "Executing: $cmd"
        eval "$cmd"
    fi
done < rocker_scripts/verse_${R_VERSION}.Dockerfile
