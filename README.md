# ddev/mysql-client-build

This repo builds the `mysql`/`mysqladmin`/`mysqldump` client binaries that DDEV bundles into [`ddev-webserver`](https://github.com/ddev/ddev/tree/main/containers/ddev-webserver), matched by major.minor version to whatever mysql server version a project is configured to use. See [ddev/ddev#6083](https://github.com/ddev/ddev/issues/6083) for the original motivation.

## How this repo works

There are two separate pipelines here that are easy to conflate — they share the repo, and both involve "building" something, but they run on very different schedules.

### Primary Job: building the mysql clients

[`.github/workflows/build.yml`](.github/workflows/build.yml) is the actual product. For each mysql version/arch in its build matrix, it downloads the mysql source, runs it through the Secondary Job's image (`docker run ... ddev/mysql-client-build`) to compile `mysql`/`mysqladmin`/`mysqldump`, and tars up the resulting binaries. On a tag push, those tarballs are attached to a GitHub Release.

Because this always pulls whatever `ddev/mysql-client-build:latest` currently is, a Secondary Job change can alter the Primary Job's output even without any Primary Job code change.

This is the pipeline that changes often — whenever a mysql server version DDEV supports needs a matching (or updated) client. To update it:

1. Edit the `dbversion` list in `build.yml`'s `strategy` matrix.
2. Push and confirm the `tests` jobs pass for every version/arch.
3. Tag a release (e.g. `v0.2.6`) to trigger the `release` job, which publishes the tarballs.

You can also run the build script directly, outside of CI:

```bash
./build-clients.sh --mysql-version 8.0.46 --arch amd64
```

### Secondary Job: the builder image

[`image/Dockerfile`](image/Dockerfile) defines a plain Debian image with the tools needed to compile the mysql client from source (`build-essential`, `cmake`, etc.). It's pushed to Docker Hub as `ddev/mysql-client-build:latest` and is a reusable compile *environment* that the Primary Job depends on — not something DDEV or end users consume directly.

**This needs attention:** its Debian base has drifted out of sync with `ddev-webserver`'s own base — it should be updated to match and hasn't been. This hasn't caused visible problems so far because binaries linked against an older glibc run fine on a system with an equal-or-newer glibc, but that's a reason it hasn't broken yet, not a reason to leave it as-is. Whether the other libraries the client dynamically links against (`libssl`, `libsasl2`, `libncurses`, `zlib`) stay ABI-compatible across that gap hasn't been explicitly verified either. Bumping `image/Dockerfile`'s base to match is the fix; watch for package name/availability changes when doing so.

This image otherwise changes rarely — mainly when the build environment itself needs something new (a Debian version bump like the one above, an added build dependency), not as part of routine maintenance. To update it:

```bash
cd image
./push.sh
```

or trigger the [`Push tagged image`](.github/workflows/push-tagged-image.yml) workflow (`workflow_dispatch`), which builds each arch on its native runner and pushes a multi-arch manifest. Re-pushing `latest` when nothing has changed is harmless.

To poke around inside the builder image itself (e.g. while debugging a build failure):

```bash
docker run -it --rm ddev/mysql-client-build bash
```

## Consumption

`ddev-webserver`'s [`mysql-client-install.sh`](https://github.com/ddev/ddev/blob/main/containers/ddev-webserver/ddev-webserver-base-files/usr/local/bin/mysql-client-install.sh) downloads a release tarball keyed by mysql major.minor version (e.g. `mysql-8.0-amd64.tar.gz`) from this repo's [Releases](https://github.com/ddev/mysql-client-build/releases), pinned via a `TARBALL_VERSION` tag in that script. Bumping the mysql client version consumed by DDEV means: do a Primary Job update here, cut a release, then update `TARBALL_VERSION` in `ddev/ddev`.

## Source

* [`.github/workflows/build.yml`](.github/workflows/build.yml) — the Primary Job client build/release pipeline
* [`image/Dockerfile`](image/Dockerfile) — the Secondary Job builder image

## Maintained by

The [DDEV Docker Maintainers](https://github.com/ddev)

## Where to get help

* [DDEV Community Discord](https://discord.gg/5wjP76mBJD)

## Where to file issues

[https://github.com/ddev/mysql-client-build/issues](https://github.com/ddev/mysql-client-build/issues)

## What is DDEV?

[DDEV](https://github.com/ddev/ddev) is an open source tool for launching local web development environments in minutes. It supports PHP, Node.js, and Python (experimental).

These environments can be extended, version controlled, and shared, so you can take advantage of a Docker workflow without Docker experience or bespoke configuration. Projects can be changed, powered down, or removed as easily as they're started.

## License

View [license information](LICENSE) for the software contained in this repo.

As with all Docker images, the builder image likely also contains other software which may be under other licenses (such as Bash, etc. from the base distribution, along with any direct or indirect dependencies of the primary software being contained).

As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.
