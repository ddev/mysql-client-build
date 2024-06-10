#!/bin/bash

set -eu -o pipefail
DOCKER_IMAGE=ddev/mysql-client-build

set -x

docker buildx create --name cmake-builder 2>/dev/null || true
docker buildx use cmake-builder

docker buildx build --push --platform linux/amd64,linux/arm64 -t ${DOCKER_IMAGE} .
