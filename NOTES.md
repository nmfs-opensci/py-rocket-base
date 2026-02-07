# Build documentation

Currently done locally. 
```
cd book
quarto render .
```
Then push to GitHub

## 2026-02-07

* Update pangeo feedstock to latest version 2026-01-21

## 2026-02-06

A series of fixes related to VSCode OSS and ssh into JuptyerHub from VSCode
* code-server was by default opening in ~ and trying to index all the file = RAM blowup
* bash terminals in code-server and vscode are not login and so notebook conda env was not being activated
* ssh does not get the Docker ENV so failing when bash startup tried to use CONDA_DIR
* the various scripts were not using `set -euo` so failing but not erroring out

## 2025-12-22

* Update R to 4.5.1
* Unbuntu updated to 24.04 in base image
* Fix JupyterLab Quarto extension not working by adding back in jupytext after Quarto team fixed bug
* Add in a few Python packages: conda-lock, pigz, jupyterlab-quarto (was in geospatial-2)
  
## 2025-04-26

* I had removed ms-toolsai.jupyter from the VSCode extensions but turns out that is required for VSCode to work in a Jupyter Hub. Without it, first Jupyter notebooks don't open but more importantly, there is a memory leak that will crash the kernel in about 5-10 minutes.
* I added a catch in the Docker file so that the build fails if the extensions script does not run.

## 2025-04-11

* Adding IRkernel in Docker file. Added notes to developer section of documentation. Allows one to select R kernel in Jupyter Lab.
* Updated to 4.4.3 as 4.4.2 no longer on rocker-org

## 2025-02

* Fixed problem with tex not building due to dead tinytex link
* Fixed problem with Quarto + JupyterLab by pinning Quarto to 1.5.57. https://github.com/quarto-dev/jupyterlab-quarto/issues/13
* Updated to 4.4.2


