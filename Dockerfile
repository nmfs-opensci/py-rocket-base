FROM pangeo/base-notebook

USER root

# Define environment variables
# DISPLAY Tell applications where to open desktop apps - this allows notebooks to pop open GUIs
ENV REPO_DIR="/srv/repo" \
    CONDA_ENV="notebook"
    DISPLAY=":1.0" \
    R_VERSION="4.4.1" \
    R_DOCKERFILE="verse_${R_VERSION}" \
    NB_USER="${NB_USER}"

COPY . ${REPO_DIR}
RUN chgrp -R staff ${REPO_DIR} && \
    chmod -R g+rwx ${REPO_DIR} && \
    rm -rf ${REPO_DIR}/book ${REPO_DIR}/docs

# Copy scripts to /pyrocket_scripts and set permissions
RUN mkdir -p /pyrocket_scripts && \
    cp -r ${REPO_DIR}/scripts/* /pyrocket_scripts/ && \
    chown -R root:staff /pyrocket_scripts && \
    chmod -R 775 /pyrocket_scripts

# Add NB_USER to staff group (required for rocker script)
RUN usermod -a -G staff "${NB_USER}"

# Install R, RStudio via Rocker scripts
RUN PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin && \
  chmod +x ${REPO_DIR}/rocker.sh && \
  ${REPO_DIR}/rocker.sh

# Install extra conda packages
RUN /pyrocket_scripts/install-conda-packages.sh ${REPO_DIR}/environment.yml

# Install extra apt packages
# Install linux packages after R installation since the R install scripts get rid of packages
RUN /pyrocket_scripts/install-apt-packages.sh ${REPO_DIR}/apt.txt

# Re-enable man pages disabled in Ubuntu 18 minimal image
# https://wiki.ubuntu.com/Minimal
# Enable man pages and configure MANPATH for JupyterLab integration
ENV MANPATH="${NB_PYTHON_PREFIX}/share/man:${MANPATH}"
RUN yes | unminimize && mandb

# Add custom Jupyter server configurations
RUN cp ${REPO_DIR}/custom_jupyter_server_config.json ${NB_PYTHON_PREFIX}/etc/jupyter/jupyter_server_config.d/ && \
    cp ${REPO_DIR}/custom_jupyter_server_config.json ${NB_PYTHON_PREFIX}/etc/jupyter/jupyter_notebook_config.d/

# Revert to default user and home as pwd
USER ${NB_USER}
WORKDIR ${HOME}
