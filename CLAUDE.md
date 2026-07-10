# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

See also [ddev/.github's CLAUDE.md](https://github.com/ddev/.github/blob/main/CLAUDE.md) for conventions shared across DDEV repositories (communication style, branch naming, PR structure, commit format). This file covers what's specific to `mysql-client-build`.

## Project Overview

This repo builds the `mysql`/`mysqladmin`/`mysqldump` client binaries that DDEV bundles into `ddev-webserver`, matched by mysql major.minor version to whatever a project is configured to use. See [ddev/ddev#6083](https://github.com/ddev/ddev/issues/6083) for the original motivation. `README.md` has the full explanation below; this file is the condensed, agent-facing version.

## How This Repo Works — Two Distinct Pipelines

Don't conflate these — they share the repo and the word "build," but run on very different schedules:

- **Job A — the builder image** (`image/Dockerfile` → `ddev/mysql-client-build` on Docker Hub): a Debian Bookworm image with the tools needed to compile the mysql client from source. Changes rarely (a Debian version bump, a new build dependency). Updated via `image/push.sh` (manual) or `.github/workflows/push-tagged-image.yml` (`workflow_dispatch`, native per-arch runners + multi-arch manifest merge).
- **Job B — building the mysql clients** (`.github/workflows/build.yml` + `build-clients.sh` + `image/build-mysql-clients.sh`): the actual product. Pulls whatever Job A's image currently is, compiles specific mysql versions inside it, tars up `mysql`/`mysqladmin`/`mysqldump`, and (on a tag push) attaches them to a GitHub Release. Changes often — whenever a mysql server version DDEV supports needs a matching client.

Job B always pulls `ddev/mysql-client-build:latest`, so a Job A change can alter Job B's output with no Job B code change. Keep this distinction in mind when diagnosing an unexpected build result.

## Key Files

- `image/Dockerfile` — Job A: the builder image definition (`FROM debian:bookworm`, intentionally — see "Known Open Questions" below)
- `image/build-mysql-clients.sh` — the cmake/make invocation run inside the builder image
- `image/push.sh` — manual Job A build-and-push script
- `.github/workflows/push-tagged-image.yml` — CI Job A push (`workflow_dispatch`)
- `build-clients.sh` — top-level script: downloads mysql source, runs it through the Job A image
- `.github/workflows/build.yml` — Job B: the `dbversion`/`arch` test matrix, plus the tag-triggered `release` job
- `README.md` — the full human-facing explanation of both jobs and how ddev-webserver consumes the output

## Development Commands

```bash
# Build a single mysql version/arch locally (Job B, outside CI)
./build-clients.sh --mysql-version 8.0.46 --arch amd64

# Rebuild and push the builder image (Job A, outside CI)
cd image && ./push.sh
```

## CI/Runner Notes

- Both `build.yml` and `push-tagged-image.yml` run their arm64 legs on native `ubuntu-24.04-arm` runners, not QEMU emulation on `ubuntu-24.04` — QEMU previously caused the C++ compiler to segfault mid-build (see PR #2). Don't reintroduce `multiarch/qemu-user-static`-style emulation for this repo's arch matrix.
- A new `workflow_dispatch` workflow can't be triggered via `gh workflow run`/the API until it's merged to the default branch (`main`) — GitHub only registers dispatch triggers from the default branch, even if the workflow file is pushed on a feature branch.
- Docker Hub auth uses the org's 1Password-backed `PUSH_SERVICE_ACCOUNT_TOKEN` secret plus `DOCKER_ORG`/`DOCKERHUB_USERNAME` org vars, shared with this repo from ddev org settings — same pattern `ddev/ddev` uses.
- Use `actionlint` to validate workflow changes before committing; prefer action versions with declared Node 24 runtime support (e.g. `actions/checkout@v7`, not `@v4`) to avoid the "Node.js 20 is deprecated" warning.

## Git Workflow

- All changes go through PRs against `upstream/main` — no direct pushes to `main`.
- Branch naming: `YYYYMMDD_<username>_<short_description>`, created from `upstream/main`:

  ```bash
  git fetch upstream && git checkout -b <branch_name> upstream/main --no-track
  ```

- `.github/PULL_REQUEST_TEMPLATE.md` asks which pipeline (Job A / Job B / Other) a PR touches — fill that in.

## Versioning

- mysql client versions are tracked in `build.yml`'s `dbversion` matrix; tarballs are named by minor version only (e.g. `mysql-8.0-amd64.tar.gz`), so a patch-version bump doesn't change the tarball name.
- Release tags follow `vX.Y.Z` (e.g. `v0.2.5`).
- Consuming side: `ddev/ddev`'s `containers/ddev-webserver/.../mysql-client-install.sh` pins a specific release tag via `TARBALL_VERSION`. Bumping the mysql client version consumed by DDEV requires a change in **both** repos: a Job B update + release here, then a `TARBALL_VERSION` bump in `ddev/ddev`.

## Known Open Questions

- The builder image (Job A) stays on Debian Bookworm even though `ddev-webserver` (the deployment target) moved to Debian Trixie. glibc's forward compatibility makes this safe for the client binaries themselves, but whether the other libraries they dynamically link against (`libssl`, `libsasl2`, `libncurses`, `zlib`) stay ABI-compatible from Bookworm into Trixie has not been explicitly verified — it has just worked empirically so far. If `mysql`/`mysqldump` ever fail to start in `ddev-webserver` with a missing- or mismatched-library error, check this first.
