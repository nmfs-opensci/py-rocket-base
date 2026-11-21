# py-rocket-base — agent instructions

Instructions for coding agents working in this repository. This file is read by
Antigravity directly and by Claude Code through `CLAUDE.md`, which holds only the
line `@AGENTS.md`. **Edit `AGENTS.md`, not `CLAUDE.md`.**

## Where things are

- [`agent/handoff.md`](agent/handoff.md): rolling session state. Read it first. It is
  orientation, not a task list; Eli says what to work on.
- [`NOTES.md`](NOTES.md): design decisions and their reasons, as dated entries. Read
  the latest entry before changing any version. New decisions go there too.
- `book/` is the Quarto documentation source; `docs/` is its rendered HTML
  (`cd book && quarto render .`), so do not put notes in `docs/`.

## How to work here

- **No PR CI.** `build.yaml` builds and pushes `:latest` on every push to `main` that
  touches the image files (`Dockerfile`, `environment.yml`, `apt.txt`, `scripts/`, …;
  `README.md`, `book/` and `docs/` do not trigger it). To test first: fast-forward the
  `test` branch to the work branch (`git push origin <branch>:test`, no force) and run
  `gh workflow run test-build.yml --ref test`. That pushes only
  `ghcr.io/nmfs-opensci/py-rocket-base/test:latest`; Eli tries it on a hub.
- **The hub cannot run Docker** (no docker or podman, `sudo` blocked). Check conda
  solves with `mamba env create --dry-run`, and use a scratch `CONDA_PKGS_DIRS`.
- `base-image/` changes rebuild `base-image:latest` on merge. Land them in their own
  PR *before* a main-image change, or the two builds race.
- The image tag is `LABEL org.opencontainers.image.version` in the `Dockerfile`. Bump
  it for a new image, or the build overwrites the existing tag.
- R version rule: one minor release behind rocker's latest (dated CRAN). Rocker master
  keeps only the newest few `verse_*` Dockerfiles, so an old `R_VERSION` stops
  building.
- Follow rocker's (and Pangeo's) choices rather than pinning old versions. Where a pin
  exists, find out why before changing it, and prefer a floor to an exact pin.
- `conda-lock.yml` is written by the conda-lock workflow after each build. Do not
  edit it by hand.
- The README's versions table and the `CITATION.cff` / `.zenodo.json` metadata go
  stale with each release; update them with it. Zenodo reads `.zenodo.json` (it must
  be valid JSON), GitHub's "Cite this repository" reads `CITATION.cff`.

## Things that look wrong but are deliberate

- `scripts/install-rocker.sh` patches rocker's `install_pandoc.sh` (RStudio 2026.x
  pandoc path) as well as `install_texlive.sh`. Without the pandoc patch the build
  fails silently.
- Rocker's setup step deletes jovyan (`userdel` uid 1000), and `default_user.sh`
  recreates the user. Check `id jovyan` after R updates.
- code-server runs with `--ignore-last-opened`, because a remembered `/home` workspace
  drove a server out of memory.
- `.qmd` opens in JupyterLab's text editor (lab `overrides.json`), because the
  jupytext notebook view writes a `jupyter:` header into the file.
- `install-rocker.sh` writes the system GDAL/PROJ paths into `Renviron.site`, so R
  started from an activated conda shell does not load conda's GDAL plugins.

## Agent-written code

Commits made with an agent end with `Co-Authored-By: Agent <agent@noreply.invalid>`,
and PR bodies end with "🤖 Generated with an AI coding agent". A PR body states the
intent, what was run to test it, and what was not.
