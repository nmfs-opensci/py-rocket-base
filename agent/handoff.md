# py-rocket-base — agent handoff

Rolling orientation for a new session. Orientation, not a task list: Eli says what to work on.
Design decisions and their reasons live in [`NOTES.md`](../NOTES.md) (dated entries); read the
latest entry before changing versions.

## Repo state (2026-11-16)

- `main` = image **2026.11.16**: Python 3.13, R 4.6.1 (CRAN `p3m noble/2026-10-28`),
  RStudio 2026.10.1, Quarto bundled with RStudio (1.10.18), code-server ≥4.145, JDK 21.
  Merged in #314 (issue #312); base-image re-synced with Pangeo in #313.
- Published `ghcr.io/nmfs-opensci/py-rocket-base:2026.11.16` (also `:latest`, `:9a7f8ce`), with
  digest `sha256:61faa90d…`, from build 43941407540. The conda-lock workflow ran after it.
  #312 is closed.
- Open: #309 (deferred, see below), #308 (Positron, not started), #305, #302, #303,
  #290 (superseded in practice by the 4.6.1 bump).

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
