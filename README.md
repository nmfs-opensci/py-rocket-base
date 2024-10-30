# py-rocket-base: JupyterHub base image

[![Build and push container image](https://github.com/nmfs-opensci/py-rocket-base/actions/workflows/build.yaml/badge.svg)](https://github.com/nmfs-opensci/py-rocket-base/actions/workflows/build.yaml)[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.13942617.svg)](https://doi.org/10.5281/zenodo.13942617)

The py-rocket-base image is a base image for the JupyterHubs with Python and RStudio. The py-rocket-base image is designed to install the Jupyter and JupyterHub environment with [repo2docker](https://repo2docker.readthedocs.io) and the R environment with [Rocker](https://rocker-project.org/) installation scripts. You can scroll through the Rocker [installation scripts](https://github.com/rocker-org/rocker-versioned2/blob/master/scripts/install_rstudio.sh) to see how the environment is set up.

*There are many ways to install R and RStudio into an image designed for JupyterHubs.* The objective of py-rocket-base is to create a JupyterHub (or binder) image such when you click the RStudio button in the JupyterLab UI to enter the RStudio UI (`/rstudio`), you **enter an environment that is the same as if you had used a Rocker image** but if you are in the JupyterLab UI (`/lab`), the **environment is the same as if you had used repo2docker** to create the environment. There are many other ways to install R and RStudio in a JupyterHub image. See History below for other approaches we have used. 

The base image has the following support:

* Python + JupyterLab with mamba handling package installation
* R + RStudio with the rocker scripts and other functions available
* Desktop ready for installing applications, including Java-based applications
* VSCode

## Where are the images

The `.github/workflows/build.yaml` is a GitHub Action to build the image with [repo2docker-action](https://github.com/jupyterhub/repo2docker-action). It builds to GitHub packages and you will find it in the [packages for the repo](https://github.com/orgs/nmfs-opensci/packages?repo_name=py-rocket-base). The URL will look like
Your image URL in your repo will look like one of these
```
ghcr.io/nmfs-opensci/repo-name/image-name:latest
ghcr.io/nmfs-opensci/image-name:latest
```
For example, for this repo the image is `ghcr.io/nmfs-opensci/py-rocket-base:latest`.

## Using this in a JupyterHub

If the JupyterHub has the **Bring your own image** feature, then you can paste in `ghcr.io/nmfs-opensci/py-rocket-base:latest` to the image and a server with your image will spin up.

<img width="772" alt="image" src="https://github.com/user-attachments/assets/13f1d200-b8a6-44e1-a9db-537260b21ec4">

## Using this as a base image

py-rocket-base is designed like the Pangeo base-image. Your Docker file in your repo will look like
```
FROM ghcr.io/nmfs-opensci/py-rocket-base:latest
```
Then add `environment.yml`, `apt.txt` or `install.R` to the repo and those will be installed. Read the [documentation](https://nmfs-opensci.github.io/py-rocket-base/) for more examples. The behavior with files like `environment.yml` is triggered by `ONBUILD` statements in py-rocket-base. If you want to prevent this behavior, you will need to avoid the specific configuration file names.

## History and motivation

The original [py-rocket 1.0](https://github.com/NASA-Openscapes/py-rocket) was developed by Luis Lopez and was built off a Rocker base image. Carl Boettiger and Eli Holmes later altered the image (py-rocket 2.0) so that the Python environment matched the Pangeo image structure but the image was still built off a Rocker image. Subsequently, Carl Boettiger developed [repo2docker-r](https://github.com/boettiger-lab/repo2docker-r) that creates a JupyterHub-compatible image that uses a [Jupyter docker stack image](https://jupyter-docker-stacks.readthedocs.io/en/latest/) as base. For py-rocker 3.0, Eli Holmes used Carl's ideas but used [repo2docker](https://repo2docker.readthedocs.io/en/latest/) and [repo2docker-action](https://github.com/jupyterhub/repo2docker-action) to build the base image. To do this, the [CryoCloud hub image](https://github.com/CryoInTheCloud/hub-image) repo was used for the basic structure and approach. Eli added the `rocker.sh` script and `appendix` modifications to install R and RStudio via the Rocker scripts (rather than using a Rocker image as base). Yuvi Panda (repo2docker) gave input throughout the process as snags were hit.

**Why Rocker for the R/RStudio environment?** The Rocker images are the standard for R/RStudio contanier images. They are heavily tested and regularly updated. There is a large developer community that fixes problems and bugs. The stack has gone through major revisions to improve modularity and they constantly innovating (integration for machine-learning, CUDA, BLAS, spatial, etc., etc.). py-rocket is building off that work without using the images directly. Instead it uses the Docker file code and the installation scripts.  There are many other approaches to adding R and RStudio to images that work in JupyterHubs. See [repo2docker-r](https://github.com/boettiger-lab/repo2docker-r) that Carl developed and [r-conda](https://github.com/binder-examples/r-conda) for a conda native approach using repo2docker. py-rocket is not intended to create small images; it is intended to create images that emulate Rocker in the `/rstudio` environment on a JupyterHub.
