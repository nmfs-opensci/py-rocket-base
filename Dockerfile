FROM ghcr.io/nmfs-opensci/py-rocket-base/base-image:latest
LABEL org.opencontainers.image.maintainers="eli.holmes@noaa.gov"
LABEL org.opencontainers.image.author="eli.holmes@noaa.gov"
LABEL org.opencontainers.image.source=https://github.com/nmfs-opensci/py-rocket-base
LABEL org.opencontainers.image.description="Python (3.12), R (4.4.1), Desktop and Publishing toolset"
LABEL org.opencontainers.image.licenses=Apache2.0
LABEL org.opencontainers.image.version=2024.11.22

USER root

# Define environment variables
# DISPLAY Tell applications where to open desktop apps - this allows notebooks to pop open GUIs
ENV REPO_DIR="/srv/repo" \
    DISPLAY=":1.0" \
    R_VERSION="4.4.1"

# Add NB_USER to staff group (required for rocker script)
# Ensure the staff group exists first
RUN groupadd -f staff && usermod -a -G staff "${NB_USER}"

# Copy files into REPO_DIR and make sure staff group can edit (use staff for rocker)
COPY --chown=${NB_USER}:${NB_USER} . ${REPO_DIR}
RUN chgrp -R staff ${REPO_DIR} && \
    chmod -R g+rwx ${REPO_DIR} && \
    rm -rf ${REPO_DIR}/book ${REPO_DIR}/docs

# Copy scripts to /pyrocket_scripts and set permissions
RUN mkdir -p /pyrocket_scripts && \
    cp -r ${REPO_DIR}/scripts/* /pyrocket_scripts/ && \
    chown -R root:staff /pyrocket_scripts && \
    chmod -R 775 /pyrocket_scripts

# Install conda packages (will switch to NB_USER in script)
RUN /pyrocket_scripts/install-conda-packages.sh ${REPO_DIR}/environment.yml

# Install R, RStudio via Rocker scripts. Requires the prefix for a rocker Dockerfile
RUN /pyrocket_scripts/install-rocker.sh "verse_${R_VERSION}"

# Install extra apt packages
# Install linux packages after R installation since the R install scripts get rid of packages
RUN /pyrocket_scripts/install-apt-packages.sh ${REPO_DIR}/apt.txt

# Install some basic VS Code extensions
RUN /pyrocket_scripts/install-vscode-extensions.sh ${REPO_DIR}/vscode-extensions.txt

# Install Zotero
RUN wget -qO- https://raw.githubusercontent.com/retorquere/zotero-deb/master/install.sh | bash 

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

# Set up the defaults for Desktop. Keep config in the /etc so doesn't trash user environment (that they might want for other environments)
ENV XDG_CONFIG_HOME=/etc/xdg/userconfig
RUN mkdir -p ${XDG_CONFIG_HOME} && \
    chown -R ${NB_USER}:${NB_USER} ${XDG_CONFIG_HOME} && \
    chmod -R u+rwx,g+rwX,o+rX ${XDG_CONFIG_HOME} && \
    mv ${REPO_DIR}/user-dirs.dirs ${XDG_CONFIG_HOME} && \
    chmod +x ${REPO_DIR}/scripts/setup-desktop.sh && \
    ${REPO_DIR}/scripts/setup-desktop.sh

# Fix home permissions. Not needed in JupyterHub with persistent memory but needed if not used in that context
RUN /pyrocket_scripts/fix-home-permissions.sh

# Set up the start command 
USER ${NB_USER}
RUN chmod +x ${REPO_DIR}/start \
    && cp ${REPO_DIR}/start /srv/start
    
# Revert to default user and home as pwd
USER ${NB_USER}
WORKDIR ${HOME}
