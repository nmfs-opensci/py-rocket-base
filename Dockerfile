# syntax=docker/dockerfile:1
# Dockerfile for base image of all pangeo images
FROM ubuntu:22.04
# build file for pangeo images

# Setup environment to match variables set by repo2docker as much as possible
# The name of the conda environment into which the requested packages are installed
ENV CONDA_ENV=notebook \
    # Tell apt-get to not block installs by asking for interactive human input
    DEBIAN_FRONTEND=noninteractive \
    # Set username, uid and gid (same as uid) of non-root user the container will be run as
    NB_USER=jovyan \
    NB_UID=1000 \
    # Use /bin/bash as shell, not the default /bin/sh (arrow keys, etc don't work then)
    SHELL=/bin/bash \
    # Setup locale to be UTF-8, avoiding gnarly hard to debug encoding errors
    LANG=C.UTF-8  \
    LC_ALL=C.UTF-8 \
    # Install conda in the same place repo2docker does
    CONDA_DIR=/srv/conda

# All env vars that reference other env vars need to be in their own ENV block
# Path to the python environment where the jupyter notebook packages are installed
ENV NB_PYTHON_PREFIX=${CONDA_DIR}/envs/${CONDA_ENV} \
    # Home directory of our non-root user
    HOME=/home/${NB_USER}

# Add both our notebook env as well as default conda installation to $PATH
# Thus, when we start a `python` process (for kernels, or notebooks, etc),
# it loads the python in the notebook conda environment, as that comes
# first here.
ENV PATH=${NB_PYTHON_PREFIX}/bin:${CONDA_DIR}/bin:${PATH}

# Ask dask to read config from ${CONDA_DIR}/etc rather than
# the default of /etc, since the non-root jovyan user can write
# to ${CONDA_DIR}/etc but not to /etc
ENV DASK_ROOT_CONFIG=${CONDA_DIR}/etc

RUN echo "Creating ${NB_USER} user..." \
    # Create a group for the user to be part of, with gid same as uid
    && groupadd --gid ${NB_UID} ${NB_USER}  \
    # Create non-root user, with given gid, uid and create $HOME
    && useradd --create-home --gid ${NB_UID} --no-log-init --uid ${NB_UID} ${NB_USER} \
    # Make sure that /srv is owned by non-root user, so we can install things there
    && chown -R ${NB_USER}:${NB_USER} /srv

# Run conda activate each time a bash shell starts, so users don't have to manually type conda activate
# Note this is only read by shell, but not by the jupyter notebook - that relies
# on us starting the correct `python` process, which we do by adding the notebook conda environment's
# bin to PATH earlier ($NB_PYTHON_PREFIX/bin)
RUN echo ". ${CONDA_DIR}/etc/profile.d/conda.sh ; conda activate ${CONDA_ENV}" > /etc/profile.d/init_conda.sh

# Install basic apt packages
RUN echo "Installing Apt-get packages..." \
    && apt-get update --fix-missing > /dev/null \
    && apt-get install -y apt-utils wget zip tzdata > /dev/null \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Add TZ configuration - https://github.com/PrefectHQ/prefect/issues/3061
ENV TZ=UTC
# ========================

USER ${NB_USER}
WORKDIR ${HOME}

# Install latest mambaforge in ${CONDA_DIR}
RUN echo "Installing Miniforge..." \
    && URL="https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-$(uname -m).sh" \
    && wget --quiet ${URL} -O installer.sh \
    && /bin/bash installer.sh -u -b -p ${CONDA_DIR} \
    && rm installer.sh \
    && mamba install conda-lock -y \
    && mamba clean -afy \
    # After installing the packages, we cleanup some unnecessary files
    # to try reduce image size - see https://jcristharif.com/conda-docker-tips.html
    # Although we explicitly do *not* delete .pyc files, as that seems to slow down startup
    # quite a bit unfortunately - see https://github.com/2i2c-org/infrastructure/issues/2047
    && find ${CONDA_DIR} -follow -type f -name '*.a' -delete

EXPOSE 8888
ENTRYPOINT ["/srv/start"]

### END OF BASE IMAGE

### APPENDIX

USER root

# Define environment variables
# DISPLAY Tell applications where to open desktop apps - this allows notebooks to pop open GUIs
ENV REPO_DIR="/srv/repo" \
    DISPLAY=":1.0" \
    R_VERSION="4.4.1"

# Add NB_USER to staff group (required for rocker script)
# Ensure the staff group exists first
RUN groupadd -f staff && usermod -a -G staff "${NB_USER}"

COPY --chown=${NB_USER}:${NB_USER} . ${REPO_DIR}
RUN chgrp -R staff ${REPO_DIR} && \
    chmod -R g+rwx ${REPO_DIR} && \
    rm -rf ${REPO_DIR}/book ${REPO_DIR}/docs

# Copy scripts to /pyrocket_scripts and set permissions
RUN mkdir -p /pyrocket_scripts && \
    cp -r ${REPO_DIR}/scripts/* /pyrocket_scripts/ && \
    chown -R root:staff /pyrocket_scripts && \
    chmod -R 775 /pyrocket_scripts

# Install extra conda packages
RUN /pyrocket_scripts/install-conda-packages.sh ${REPO_DIR}/environment.yml

# Install R, RStudio via Rocker scripts
ENV R_DOCKERFILE="verse_${R_VERSION}"
RUN PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin && \
    chmod +x ${REPO_DIR}/rocker.sh && \
    ${REPO_DIR}/rocker.sh

# Install test conda packages
RUN /pyrocket_scripts/install-conda-packages.sh ${REPO_DIR}/test.yml

# Install extra apt packages
# Install linux packages after R installation since the R install scripts get rid of packages
RUN /pyrocket_scripts/install-apt-packages.sh ${REPO_DIR}/apt.txt

# Re-enable man pages disabled in Ubuntu 18 minimal image
# https://wiki.ubuntu.com/Minimal
RUN yes | unminimize
# NOTE: $NB_PYTHON_PREFIX is the same as $CONDA_PREFIX at run-time.
# $CONDA_PREFIX isn't available in this context.
# NOTE: Prepending ensures a working path; if $MANPATH was previously empty,
# the trailing colon ensures that system paths are searched.
ENV MANPATH="${NB_PYTHON_PREFIX}/share/man:${MANPATH}"
RUN mandb

# Add custom Jupyter server configurations
RUN mkdir -p ${NB_PYTHON_PREFIX}/etc/jupyter/jupyter_server_config.d/ && \
    mkdir -p ${NB_PYTHON_PREFIX}/etc/jupyter/jupyter_notebook_config.d/ && \
    cp ${REPO_DIR}/custom_jupyter_server_config.json ${NB_PYTHON_PREFIX}/etc/jupyter/jupyter_server_config.d/ && \
    cp ${REPO_DIR}/custom_jupyter_server_config.json ${NB_PYTHON_PREFIX}/etc/jupyter/jupyter_notebook_config.d/

# Set up the start command 
USER ${NB_USER}
RUN chmod +x ${REPO_DIR}/start \
    && cp ${REPO_DIR}/start /srv/start
    
# Revert to default user and home as pwd
USER ${NB_USER}
WORKDIR ${HOME}
