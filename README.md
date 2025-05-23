# py-rocket-base: JupyterHub base image

[![Build and push container image](https://github.com/nmfs-opensci/py-rocket-base/actions/workflows/build.yaml/badge.svg)](https://github.com/nmfs-opensci/py-rocket-base/actions/workflows/build.yaml)   [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.13942617.svg)](https://doi.org/10.5281/zenodo.13942617)   [![GitHub Release](https://img.shields.io/github/v/release/nmfs-opensci/py-rocket-base)](https://github.com/nmfs-opensci/py-rocket-base/releases)

The py-rocket-base image is a base image for the JupyterHubs with Python and RStudio. The py-rocket-base image uses the [Pangeo base-image](https://github.com/pangeo-data/pangeo-docker-images/tree/master/base-image) (minus the `ONBUILD` commands) as the base image (stored in `py-rocket-base/base-image`) and the [pangeo-notebook metapackage](https://github.com/conda-forge/pangeo-notebook-feedstock/blob/main/recipe/meta.yaml) to setup the core JupyterHub environment (following [Pangeo base-notebook](https://github.com/pangeo-data/pangeo-docker-images/blob/master/base-notebook/environment.yml). [Additional Python packages](https://github.com/nmfs-opensci/py-rocket-base/blob/main/environment.yml) are installed to provide a fuller JupyterLab, RStudio, Desktop, and VSCode environment.  The R environment is installed with [Rocker](https://rocker-project.org/) installation scripts. You can scroll through the Rocker [installation scripts](https://github.com/rocker-org/rocker-versioned2/blob/master/scripts/install_rstudio.sh) to see how that environment is set up.

image url
```
ghcr.io/nmfs-opensci/py-rocket-base:latest
```

The base image has the following support:

* Python + JupyterLab with mamba handling package installation
* R + RStudio with the rocker scripts and other functions available
* Desktop ready for installing applications, including Java-based applications
* VSCode + R and Python extensions pre-installed
* Publishing infrastructure installed (TexLive, Quarto, JupyterBook, MyST, pandoc).

py-rocket-base is the base image for the NMFS OpenSci specialized images, specifically [py-rocket-geospatial](https://nmfs-opensci.github.io/container-images/).

*There are many ways to install R and RStudio into an image designed for JupyterHubs.* The objective of py-rocket-base is to create a JupyterHub (or binder) image such when you click the RStudio button in the JupyterLab UI to enter the RStudio UI (`/rstudio`), you **enter an environment that is the same as if you had used a Rocker image** but if you are in the JupyterLab UI (`/lab`), the **environment is the same as if you had used the Pangeo base image** to create the environment. See History below for other approaches we have used to create py-rocket over the years (and why this current approach is used). 

## Using this in a JupyterHub

If the JupyterHub has the **Bring your own image** feature, then you can paste in `ghcr.io/nmfs-opensci/py-rocket-base:latest` to the image and a server with your image will spin up.

<img width="772" alt="image" src="https://github.com/user-attachments/assets/13f1d200-b8a6-44e1-a9db-537260b21ec4">

## Using this as a base image

py-rocket-base has basic structure like the pangeo base-image and repo2docker images. To use as a base image, include this in your Docker file
```
FROM ghcr.io/nmfs-opensci/py-rocket-base:latest
```
py-rocket-base has pyrocket and rocket scripts that you can use to help customize your image and add more conda, R or linux packages. See the documentation on customizing images.

## History and motivation

The original [py-rocket 1.0](https://github.com/NASA-Openscapes/py-rocket) was developed by Luis Lopez and was built off a Rocker base image. Carl Boettiger and Eli Holmes later altered the image (py-rocket 2.0) so that the Python environment matched the Pangeo image structure but the image was still built off a Rocker image. Subsequently, Carl Boettiger developed [repo2docker-r](https://github.com/boettiger-lab/repo2docker-r) that creates a JupyterHub-compatible image that uses a [Jupyter docker stack image](https://jupyter-docker-stacks.readthedocs.io/en/latest/) as base. For py-rocker 3.0, Eli Holmes used Carl's ideas but used [repo2docker](https://repo2docker.readthedocs.io/en/latest/) and [repo2docker-action](https://github.com/jupyterhub/repo2docker-action) to build the base image. To do this, the [CryoCloud hub image](https://github.com/CryoInTheCloud/hub-image) repo was used for the basic structure and approach. Eli added the `rocker.sh` script and `appendix` modifications to install R and RStudio via the Rocker scripts (rather than using a Rocker image as base). Yuvi Panda (repo2docker) gave input throughout the process as snags were hit. For py-rocker 4.0, current approach, repo2docker was abandoned and the base image was created by using the Pangeo base image with the `ONBUILD` parts removed. This approach was taken after discussions with Docker image mainainers at NASA who had quickly run into the need for more tailored control of the build process when customizing images. And in fact, the need for customizing the build process became an issue quickly and I was resorting to many "hacks" to circumvent repo2docker default behavior. Given the close relationship between Pangeo base image and repo2docker developers, using the Pangeo base image Docker file still results in a base image that is very similar to that created with repo2docker.

**Why Rocker for the R/RStudio environment?** The Rocker images are the standard for R/RStudio contanier images. They are heavily tested and regularly updated. There is a large developer community that fixes problems and bugs. The stack has gone through major revisions to improve modularity and they constantly innovating (integration for machine-learning, CUDA, BLAS, spatial, etc., etc.). py-rocket is building off that work without using the images directly. Instead it uses the Docker file code and the installation scripts.  There are many other approaches to adding R and RStudio to images that work in JupyterHubs. See [repo2docker-r](https://github.com/boettiger-lab/repo2docker-r) that Carl developed and [r-conda](https://github.com/binder-examples/r-conda) for a conda native approach using repo2docker. py-rocket is not intended to create small images; it is intended to create images that emulate Rocker (verse and geospatial) in the R environments (whether in Jupyter Lab, RStudio or VSCode) on a JupyterHub.

## Building the documentation

```
cd book
quarto render .
```
This puts html in `docs`. Push to GitHub.
