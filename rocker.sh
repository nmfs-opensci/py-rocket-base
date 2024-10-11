#!/bin/bash
set -e

# This script will copy in the R environment install scripts to install things and
# Install an R environment using a Dockerfile file
# It will run just the ENV and RUN commands in that file
# Variables defined here will only be available in this script.

# Script uses the tag feature of releases in GitHub
R_GITHUB_OWNER="rocker-org"
R_GITHUB_REPO="rocker-versioned2"
R_RELEASE_TAG="R${R_VERSION}"
R_TARNAME="${R_GITHUB_REPO}-${R_RELEASE_TAG}"
R_DOCKERFILE="${DOCKER_TAG}_${R_VERSION}.Dockerfile"

# Copy in the rocker files. Work in ${REPO_DIR} to make sure I don't clobber anything
cd ${REPO_DIR}
# For degugging use: wget https://github.com/eeholmes/rocker-versioned2/archive/refs/tags/R4.4.1.tar.gz
wget https://github.com/rocker-org/rocker-versioned2/archive/refs/tags/${R_RELEASE_TAG}.tar.gz
tar zxvf ${R_RELEASE_TAG}.tar.gz && \
mv ${R_TARNAME}/scripts /rocker_scripts && \
mv ${R_TARNAME}/dockerfiles/${R_DOCKERFILE} /rocker_scripts/original.Dockerfile && \
rm ${R_RELEASE_TAG}.tar.gz && \
rm -rf ${R_TARNAME}

cd /
# Read the Dockerfile and process each line
while IFS= read -r line; do
    # Check if the line starts with ENV or RUN
    if [[ "$line" == ENV* ]]; then
        # Assign variable
        var_assignment=$(echo "$line" | sed 's/^ENV //g')
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
