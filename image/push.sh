#!/bin/bash

set -eu -o pipefail
DOCKER_IMAGE=randyfay/cmake

docker buildx create --name cmake --use 2>/dev/null || true

docker buildx build --push --platform linux/amd64,linux/arm64 -t ${DOCKER_IMAGE} .
