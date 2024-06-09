# mysql-client-build

Build various versions of the mysql clients (mysql, mysqldump)

Primarily intended for [DDEV](https://github.com/ddev/ddev)'s `ddev-webserver`

See [issue](https://github.com/ddev/ddev/issues/6083).

## Docker Image

A Docker image is used to do the build, so that we have the right upstream environment, currently Debian 12 Bookworm, and the right architecture (amd64/arm64).

If updates need to be made to the image:

`cd image && ./push`

## Running the build script

The build script is `build-clients.sh` and it can be run with something like:

`./build-clients.sh --mysql-version 5.7.44 --arch amd64`

## Building with GitHub Release

Every push builds a set of files that are available on the test page.

But mostly a new release will create a set of tarballs for each version and architecture.

You can update the list of things to be built in the "strategy" section of .github/workflows/tests.yaml

## When to build

Luckily, this doesn't have to be built too terribly often. Mostly it's only when we have a new mysql server version to deploy.

