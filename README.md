# ddev/mysql-client-build docker image

## Overview

This image is used to build specific versions of the `mysql` client binaries.

It's primarily intended for [DDEV](https://github.com/ddev/ddev)'s `ddev-webserver`

See [issue](https://github.com/ddev/ddev/issues/6083).

### Features

* builder for ARM64 and AMD64 versions of `mysql` and `mysqldump` binaries that will run on the related Debian 12 Bookworm versions.

## Instructions

### When to build

Luckily, this doesn't have to be built too terribly often. Mostly it's only when we have a new mysql server version to deploy.

### Building with GitHub Release

The normal way to update this is to update the list of versions in the `build.yml` and then create a new release. 

Update the list of versions to be built in the [`strategy` stanza](https://github.com/ddev/mysql-client-build/blob/6f94f620dcb28607cc71fe78e6a25f70213f8293/.github/workflows/build.yml#L26-L29) of .github/workflows/build.yml


### Running the build script manually

The build script is `build-clients.sh` and it can be run with something like:

`./build-clients.sh --mysql-version 5.7.44 --arch amd64`

### Building and pushing the image to Docker Hub

Updating the image is done with the script in image/push.sh:

```
cd image
./push.sh
```

### Running

It's unusual to run the container by itself, but:

```bash
docker run -it --rm ddev/mysql-client-build bash
```

## Source:

[https://github.com/ddev/mysql-client-build/blob/main/image/Dockerfile](https://github.com/ddev/mysql-client-build/blob/main/image/Dockerfile)

## Maintained by:

The [DDEV Docker Maintainers](https://github.com/ddev)

## Where to get help:

* [DDEV Community Discord](https://discord.gg/5wjP76mBJD)

## Where to file issues:

https://github.com/ddev/mysql-client-build/issues

## Documentation:

* https://github.com/ddev/mysql-client-build

## What is DDEV?

[DDEV](https://github.com/ddev/ddev) is an open source tool for launching local web development environments in minutes. It supports PHP, Node.js, and Python (experimental).

These environments can be extended, version controlled, and shared, so you can take advantage of a Docker workflow without Docker experience or bespoke configuration. Projects can be changed, powered down, or removed as easily as they’re started.

## License

View [license information](https://github.com/ddev/mysql-client-build/blob/main/LICENSE) for the software contained in this image.

As with all Docker images, these likely also contain other software which may be under other licenses (such as Bash, etc from the base distribution, along with any direct or indirect dependencies of the primary software being contained).

As for any pre-built image usage, it is the image user's responsibility to ensure that any use of this image complies with any relevant licenses for all software contained within.
