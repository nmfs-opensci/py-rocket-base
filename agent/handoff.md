# py-rocket-base — agent handoff

Rolling orientation for a new session. Orientation, not a task list: Eli says what to work on.
Design decisions and their reasons live in [`NOTES.md`](../NOTES.md) (dated entries); read the
latest entry before changing versions.

## Repo state (2026-11-21)

- Image **2026.11.17** (`:latest`): Python 3.13 (notebook env; conda base is 3.14 from
  Miniforge), R 4.6.1 (CRAN `p3m noble/2026-10-28`), RStudio 2026.10.1, Quarto bundled with
  RStudio, code-server ≥4.145, JDK 21, Ubuntu 24.04. Built from #319 (R keeps system
  GDAL/PROJ in conda shells) on top of #314/#317. Details in NOTES.md 2026-11-16/17.
- **License is Apache-2.0** since #323 (2026-11-21, Eli's choice). The inherited BSD-3 notice
  from the CryoCloud hub-image (2i2c) is kept verbatim in `NOTICE`. #323 also added
  `CITATION.cff`, `AGENTS.md`/`CLAUDE.md`, the README AI-assistance and Reuse and citation
  sections, and fixed `.zenodo.json`, which was invalid JSON from 2026-02-09 to 2026-11-21.
- **Release v3.2.0 was published 2026-11-21 at tag `c91a7cd`, before #323 merged.** The tag
  therefore has the broken `.zenodo.json`, and Zenodo had no v3.2.0 record ten minutes later
  (latest is still v3.1.1, `10.5281/zenodo.18512408`). Unresolved: Eli decides whether to
  re-release (e.g. v3.2.1 from current `main`) or fix it on Zenodo by hand. `CITATION.cff` and
  the README citation say v3.2.0.
- Open PRs: #322 (README versions table; merges cleanly). Open issues: #309 (deferred, see
  below), #308 (Positron, not started), #305, #302, #303, #290.

## How to work here

Working rules and the "looks wrong but is deliberate" list are in
[`AGENTS.md`](../AGENTS.md).

## Deferred

- **#309, Quarto + Python in code-server.** Parked by Eli as low priority. Findings are in
  NOTES.md 2026-11-16 (Open VSX `vscode-python-envs` has no native finder; the Run Cell lens
  behaves differently in R-containing documents).

## Next repo: py-rocket-geospatial-2

Plan and checklist are in
[nmfs-opensci/py-rocket-geospatial-2#69](https://github.com/nmfs-opensci/py-rocket-geospatial-2/issues/69),
Decisions so far (2026-11-16):

- Agents (Claude Code, Antigravity) get an opt-in helper script, not an image install.
- gcloud stays (Eli uses Google object storage regularly), installed with
  `--no-install-recommends` (drops anthoscli; ~880 MB instead of 1004 MB).
- awscli v1 replaces awscliv2.
- The source-coop CLI goes in, pinned.
- Panoply moves to its own derivative image, and cwutils moves with it.
- QGIS stays, bumped to `qgis~=3.44`.
- The icechunk packages are folded into `env-core2.yml`, listed explicitly. The combined solve
  showed no downgrades; it only adds icechunk 2.3.1. `obspec-utils` is pip-only.
- rclone and s5cmd go in the image (~60 MB together).
- All decisions are recorded in #69's comments. Next step there: the branch-safe test
  workflow, then the changes.

Its Dockerfile installs the conda env files **one at a time**; solve them the same way, never
all together. Do not dispatch its `build-and-push.yml` as a test, because it pushes `:latest`.
