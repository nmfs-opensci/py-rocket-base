FROM ghcr.io/nmfs-opensci/py-rocket-base/base-image:latest

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

# Install conda packages
RUN /pyrocket_scripts/install-conda-packages.sh ${REPO_DIR}/environment.yml

# Install R, RStudio via Rocker scripts. Requires the prefix for a rocker Dockerfile
RUN /pyrocket_scripts/install-rocker.sh "verse_${R_VERSION}"

# Install extra apt packages
# Install linux packages after R installation since the R install scripts get rid of packages
RUN /pyrocket_scripts/install-apt-packages.sh ${REPO_DIR}/apt.txt

# Re-enable man pages disabled in Ubuntu 18 minimal image
# https://wiki.ubuntu.com/Minimal
RUN yes | unminimize
ENV MANPATH="${NB_PYTHON_PREFIX}/share/man:${MANPATH}"
RUN mandb

# Add custom Jupyter server configurations
RUN mkdir -p ${NB_PYTHON_PREFIX}/etc/jupyter/jupyter_server_config.d/ && \
    mkdir -p ${NB_PYTHON_PREFIX}/etc/jupyter/jupyter_notebook_config.d/ && \
    cp ${REPO_DIR}/custom_jupyter_server_config.json ${NB_PYTHON_PREFIX}/etc/jupyter/jupyter_server_config.d/ && \
    cp ${REPO_DIR}/custom_jupyter_server_config.json ${NB_PYTHON_PREFIX}/etc/jupyter/jupyter_notebook_config.d/

# Set up the defaults for Desktop. Keep config in the base so doesn't trash user environment
ENV XDG_CONFIG_HOME=/etc/xdg/userconfig
RUN mkdir -p /etc/xdg/userconfig && \
    chown -R ${NB_USER}:${NB_USER} /etc/xdg/userconfig && \
    chmod -R u+rwx,g+rwX,o+rX /etc/xdg/userconfig && \
    chmod +x "${REPO_DIR}/desktop.sh" && \
    "${REPO_DIR}/desktop.sh"

# Set up the start command 
USER ${NB_USER}
RUN chmod +x ${REPO_DIR}/start \
    && cp ${REPO_DIR}/start /srv/start
    
# Revert to default user and home as pwd
USER ${NB_USER}
WORKDIR ${HOME}
