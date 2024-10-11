# py-rocket-base image (take 2)

[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/nmfs-opensci/py-rocket-2/HEAD)
[![Build and push container image](https://github.com/nmfs-opensci/py-rocket-2/actions/workflows/build.yaml/badge.svg)](https://github.com/nmfs-opensci/py-rocket-2/actions/workflows/build.yaml)

The py-rocket-base image is a base image for the JupyterHubs with a scientific stack for Python and R for the earth sciences. This base image does not have the scientific stack, rather it is a base image to which a set of packages can be added. The image is built with [repo2docker](https://repo2docker.readthedocs.io), which uses Ubuntu Jammy (22.04) as the base image. 

The py-rocket-base image is designed to install the Jupyter and JupyterHub environment with repo2docker and the R environment with Rocker (or other R installation scripts) intallation scripts.

* Python + JupyterLab with conda handling package installation
* R + RStudio
* Desktop VNC for running applications
* VSCode

## Where are the images

The `.github/workflows/repo2docker.yaml` is a GitHub Action to build the image with [repo2docker-action](https://github.com/jupyterhub/repo2docker-action). It builds to GitHub packages and you will find it in the [packages for the repo](https://github.com/orgs/nmfs-opensci/packages?repo_name=py-rocket-2). The URL will look like
Your Dockerfile in your repo will look like
```
ghcr.io/nmfs-opensci/container-images/py-rocket-base:latest
```

<!--
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
-->

## Using this in JupyterHub

If the JupyterHub has the **Bring your own image** feature, then you can paste in `ghcr.io/nmfs-opensci/py-rocket-2:latest` to the image and a server with your image will spin up.

<img width="772" alt="image" src="https://github.com/user-attachments/assets/13f1d200-b8a6-44e1-a9db-537260b21ec4">
