# py-rocket-base image

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/nmfs-opensci/py-rocket-base/HEAD)
[![Build and push container image](https://github.com/nmfs-opensci/py-rocket-base/actions/workflows/repo2docker.yaml/badge.svg)](https://github.com/nmfs-opensci/py-rocket-base/actions/workflows/repo2docker.yaml)

The py-rocket image is the base image used for [nmfs-openscapes.2i2c.cloud](https://nmfs-openscapes.2i2c.cloud/hub/login?next=%2Fhub%2F) images that have R and Python. The image is built with [repo2docker](https://repo2docker.readthedocs.io), which uses
Ubuntu Bionic Beaver (18.04) as the base image. repo2docker saves the repo files to `${REPO_DIR}` in the image (default `/srv/repo`) and the `${REPO_DIR}/start` commands are issued after the image starts. In py-rocket-base, this is mainly used to set up the Desktop applications. Read the repo2docker docs to learn about the image and the various environmental variables.

The py-rocket-base image is designed to have the features and applications for R and Python which have more complex dependencies and to make sure that the correct environment variables are set. 

* Python + JupyterLab with conda handling package installation
* R + RStudio with bspm handling R package installation (and any apt-get dependencies) and with the CRAN repository pinned for future `install.r` used when this base image is used as `FROM` in another docker image.
* Desktop VNC for running applications
* VSCode

## Using this as a base image

* R packages: Include `install.R`
* Python packages: `environment.yml`
* Desktop applications: `*.desktop` files + entry in `mime` directory if application should be associated with specific file types.
* root installs: `app.sh` file.

Your Dockerfile in your repo will look like
```
FROM ghcr.io/nmfs-opensci/container-images/py-rocket-base:latest

# If needed to do a root install of software
USER root
COPY app.sh app.sh
RUN cp app.sh /app.sh && chmod xxxxx && ./app.sh && rm app.sh
USER ${NB_USER}

# install R packages
COPY install.R install.R
RUN cp install.R install.R && Rscript install.R && rm install.R

# install the Python libraries
COPY environment.yml environment.yml
RUN conda env update -n notebook -f environment.yml \
    && conda clean --all \
    && rm environment.yml

# If needed to do add a Desktop application
COPY *.desktop ${REPO_DIR}/*.desktop
COPY mime/*.xml ${REPO_DIR}/mime/*.xml

USER ${NB_USER}
```

## Updating packages in this repository

You can add or update packages on the NMFS Openscapes hub by making pull requests to this
repository. Follow these steps:

## Using this in JupyterHub

If the JupyterHub has the **Bring your own image** feature, then you can paste in `ghcr.io/nmfs-opensci/image-acoustics:latest` to the image and a server with your image will spin up.

<img width="772" alt="image" src="https://github.com/user-attachments/assets/13f1d200-b8a6-44e1-a9db-537260b21ec4">

