# py-rocket-base — agent handoff

Rolling orientation for a new session. Orientation, not a task list: Eli says what to work on.
Design decisions and their reasons live in [`NOTES.md`](../NOTES.md) (dated entries); read the
latest entry before changing versions.

## Repo state (2026-11-16)

- `main` = image **2026.11.16**: Python 3.13, R 4.6.1 (CRAN `p3m noble/2026-10-28`),
  RStudio 2026.10.1, Quarto bundled with RStudio (1.10.18), code-server ≥4.145, JDK 21.
  Merged in #314 (issue #312); base-image re-synced with Pangeo in #313.
- The `build.yaml` run for the #314 merge (43941407540) was **still in progress at handoff**.
  Check that it published `py-rocket-base:2026.11.16` and that the conda-lock bot committed.
- Open: #312 (umbrella; left open until geospatial-2 is updated), #309 (deferred, see below),
  #308 (Positron, not started), #305, #302, #303, #290 (superseded in practice by the 4.6.1 bump).

## How to work here

- **No PR CI.** `build.yaml` builds and pushes `:latest` on every push to `main`.
  To test first: fast-forward the `test` branch to the work branch
  (`git push origin <branch>:test`, no force) and run `gh workflow run test-build.yml --ref test`.
  That pushes only `ghcr.io/nmfs-opensci/py-rocket-base/test:latest`; Eli tries it on a hub.
- **This hub cannot run Docker** (no docker or podman, `sudo` blocked). Check conda solves with
  `mamba env create --dry-run`, and use a scratch `CONDA_PKGS_DIRS`.
- `base-image/` changes rebuild `base-image:latest` on merge. Land them in their own PR
  *before* a main-image change, or the two builds race.
- R version rule: one minor release behind rocker's latest (dated CRAN). Rocker master keeps
  only the newest few `verse_*` Dockerfiles, so an old `R_VERSION` stops building.
- Eli prefers following rocker's choices over pinning old versions.

## Things that look wrong but are deliberate

- `scripts/install-rocker.sh` patches rocker's `install_pandoc.sh` (RStudio 2026.x pandoc
  path) as well as `install_texlive.sh`. Without the pandoc patch the build fails silently.
- Rocker's setup step deletes jovyan (`userdel` uid 1000), and `default_user.sh` recreates the
  user. Check `id jovyan` after R updates.
- code-server runs with `--ignore-last-opened`, because a remembered `/home` workspace drove a
  server out of memory.
- `.qmd` opens in JupyterLab's text editor (lab `overrides.json`), because the jupytext
  notebook view writes a `jupyter:` header into the file.

## Deferred

- **#309, Quarto + Python in code-server.** Parked by Eli as low priority. Findings are in
  NOTES.md 2026-11-16 (Open VSX `vscode-python-envs` has no native finder; the Run Cell lens
  behaves differently in R-containing documents).

## Next repo: py-rocket-geospatial-2

Plan and checklist are in
[nmfs-opensci/py-rocket-geospatial-2#69](https://github.com/nmfs-opensci/py-rocket-geospatial-2/issues/69),
which was waiting on Eli's answers (QGIS, cwutils, rclone/s5cmd, env-file layout). Decided there:

- Agents (Claude Code, Antigravity) get an opt-in helper script, not an image install.
- gcloud (~1 GB) moves out of the image.
- awscli v1 replaces awscliv2.
- The source-coop CLI goes in, pinned.
- Panoply moves to its own derivative image.

Its Dockerfile installs the conda env files **one at a time**; solve them the same way, never
all together. Do not dispatch its `build-and-push.yml` as a test, because it pushes `:latest`.
