# Build documentation

Currently done locally. 
```
cd book
quarto render .
```
Then push to GitHub

## 2026-11-16

Issue #312. Minimal update so py-rocket-geospatial-2 can move to Python ≥3.12 (needed by icechunk, virtualizarr, zarr 3).

* Python 3.11 → 3.13 (#310, #311). The 3.11 reason ("same as CryoCloud") no longer holds; CryoCloud is on 3.14 and the Pangeo base-notebook image on 3.13.
* pangeo-notebook 2026.01.21 → 2026.10.29.
* R 4.5.1 → 4.6.1. Rule: one minor release behind the latest rocker release, so CRAN is a dated p3m snapshot rather than `latest`. 4.6.1 is also the last rocker release on Ubuntu noble; verse_4.6.2 moved to Ubuntu resolute (26.04). Rocker master only keeps the newest few Dockerfiles, and verse_4.5.1 had already been removed, so main could not be rebuilt without this bump. 4.6.1 brings CRAN `noble/2026-10-28` and RStudio 2026.10.1+239.
* JupyterLab now opens `.qmd` in the text editor by default (`share/jupyter/lab/settings/overrides.json`, `defaultViewers: {"quarto": "Editor"}`). Opening a .qmd as a jupytext notebook makes autosave add a `jupyter:` jupytext/kernelspec header; for R .qmd files that switches Quarto from knitr to the Jupyter (IR) engine. A jupytext `notebook_metadata_filter = "-all"` still leaves `jupyter: <kernel>`, so it is not enough. Right-click > Open With > Jupytext Notebook still works. The 2025 attempt (#246) put this lab setting in the server config, where it has no effect.
* Quarto: removed `QUARTO_VERSION=1.7.34`. Rocker 4.6.1 does not set it, so rocker installs the Quarto bundled with RStudio. The old JupyterLab problem (quarto-dev/jupyterlab-quarto#13) is about Quarto being installed twice (deb and conda), not about the version. If .qmd files stop opening in JupyterLab, set `QUARTO_VERSION="latest"`.
* code-server: the exact pin 4.98.0 is now the floor `>=4.145`. The pin was added (#252) to stop child images downgrading code-server (which caused a node "I2 Connector" error), not to hold an old version; a floor prevents that too.
* Java: `openjdk-11-jre` → `default-jdk` (full JDK 21, with javac). Why the old image had only Java 11: rocker's `install_R_source.sh` installs `default-jdk` as a build dependency and purges it (R's Makeconf still points at JDK 21); `install_verse.sh` reinstalls it, but then ran `apt-get remove -y systemd`, and on noble the full JRE depends on systemd, so the JDK went too (seen in the Feb 2026 dpkg log). Nothing intended the Java removal; that line was only cleaning up systemd. Rocker removed it in rocker-versioned2#1048 (2026-11-08), so rocker's JDK 21 now stays and rJava can load. `default-jdk` is listed in apt.txt as a guard.
* Rocker `install_pandoc.sh` does not know the RStudio 2026.x bundled pandoc path (`quarto/bin/tools/<arch>/pandoc`), so it fell back to a GitHub API lookup and exited 1 with no output in the first test build. `install-rocker.sh` now patches the path in (like the texlive patches).
* code-server `settings.json` gets `python.defaultInterpreterPath` so Quarto in code-server uses the notebook python (#309). `start` adds the key to existing settings files if it is missing; it skips files that are not plain JSON and never fails start.
* GitHub Actions: `actions/checkout` → v7 and `docker/login-action` → v4 in all workflows (Node 24; v3/v4 targeted the retired Node 20). checkout v7 blocks fork-PR checkouts in `workflow_run` workflows; conda-lock.yaml checks out `main`, so it is unaffected.
* Watch item: rocker's setup_R heredoc runs `userdel --remove "$(id -un 1000)"`, and uid 1000 is jovyan. The 2026-11-16 test build log confirms it deletes jovyan (`userdel: jovyan mail spool ... not found`); rocker's `default_user.sh` (DEFAULT_USER=jovyan) appears to recreate the user. Check `id jovyan` and the ownership of /home/jovyan and /srv/conda in the image after any R update.
* geospatial-2 notes from local conda dry-run solves on Python 3.13 (each env file solved separately on top of base, as in its Dockerfile): core1, core2, geo, ioos and viz solve; `qgis~=3.40` has no solvable build for 3.13, but `qgis~=3.44` (3.44.14) solves. The icechunk stack solves (icechunk 2.3.1, virtualizarr 2.8.0, zarr 3.4.2, obstore 0.12.1).

## 2026-02-07

* Update pangeo feedstock to latest version 2026-01-21
* Set Python back to 3.11, same as CryoCloud
* R packages installed with install-r-packages.sh are not using binaries. I was circumventing the behavior in $R_HOME/etc/Rprofile.site that ensures that using repo p3m.dev gets binaries instead of source.
* The `set -euo` meant that unbound variables in scripts throw and error. This is probably correct although now threw some errors when calling install-r-packages.sh

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


