FROM ghcr.io/nmfs-opensci/py-rocket-base/base-image:latest

LABEL org.opencontainers.image.maintainers="eli.holmes@noaa.gov"
LABEL org.opencontainers.image.author="eli.holmes@noaa.gov"
LABEL org.opencontainers.image.source=https://github.com/nmfs-opensci/py-rocket-base
LABEL org.opencontainers.image.description="Python (3.12), R (4.4.3), Desktop and Publishing tools"
LABEL org.opencontainers.image.licenses=Apache2.0
LABEL org.opencontainers.image.version=2025.04.11

USER root

# Define environment variables
# DISPLAY Tell applications where to open desktop apps - this allows notebooks to pop open GUIs
# Set QUARTO_VERSION due to Jupyter Lab bug with version 1.6 that won't all qmd to open
ENV REPO_DIR="/srv/repo" \
    DISPLAY=":1.0" \
    R_VERSION="4.4.3" \
    QUARTO_VERSION="1.5.57" \
    UBUNTU_VERSION="jammy"
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Fix init_conda.sh so that it only runs if we are in Jupyter Lab and not RStudio
RUN echo 'if [[ ! -v RSTUDIO || ! -v R_HOME ]]; then \
    . ${CONDA_DIR}/etc/profile.d/conda.sh; \
    conda activate ${CONDA_ENV}; \
fi' > /etc/profile.d/init_conda.sh
    
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
# Set the R_VERSION_PULL variable to specify what branch or release. If need to use a release use
# R_VERSION_PULL="R4.3.3" for example; R_VERSION_PULL="master" is getting the current master branch
# Be aware that if R_VERSION_PULL is set to the latest release, CRAN repo will use "latest" and date will not be pinned.
RUN R_VERSION_PULL="master" /pyrocket_scripts/install-rocker.sh "verse_${R_VERSION}"

# Install IRkernel and register it with Jupyter so we can select an R kernel with Jupyter Lab
# When R is invoked, the PATH is cleaned to remove conda, but need to add conda on temporarily so that
# installspec can find jupyter (which is in conda dir)
RUN Rscript - <<EOF
install.packages('IRkernel')
Sys.setenv(PATH = paste("/srv/conda/envs/notebook/bin", Sys.getenv("PATH"), sep = ":"))
IRkernel::installspec(name = "ir", displayname = "R ${R_VERSION}")
EOF
# Fix LD library path for RStudio https://github.com/rstudio/rstudio/issues/14060#issuecomment-1911329450
RUN echo "rsession-ld-library-path=/srv/conda/envs/notebook/lib" >> /etc/rstudio/rserver.conf

# Install Zotero; must be run before apt since zotero apt install requires this is run first
RUN wget -qO- https://raw.githubusercontent.com/retorquere/zotero-deb/master/install.sh | bash 

# Install extra apt packages
# Install linux packages after R installation since the R install scripts get rid of packages
RUN /pyrocket_scripts/install-apt-packages.sh ${REPO_DIR}/apt.txt

# Install some basic VS Code extensions
RUN /pyrocket_scripts/install-vscode-extensions.sh ${REPO_DIR}/vscode-extensions.txt

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

# Create a symlink for python to python3 and gh-scoped-creds for all users; need for RStudio since conda not on path
RUN ln -s /usr/bin/python3 /usr/local/bin/python
RUN ln -s /srv/conda/envs/notebook/bin/gh-scoped-creds /usr/local/bin/gh-scoped-creds
RUN ln -s /srv/conda/condabin/conda /usr/local/bin/conda
RUN ln -s /srv/conda/envs/notebook/bin/pip /usr/local/bin/pip

# Allow user to change the rstudio server conf if needed.
RUN chown jovyan:users /etc/rstudio/rserver.conf

# Set up the start command 
USER ${NB_USER}
RUN chmod +x ${REPO_DIR}/start \
    && cp ${REPO_DIR}/start /srv/start

# Revert to default user and home as pwd
USER ${NB_USER}
WORKDIR ${HOME}
