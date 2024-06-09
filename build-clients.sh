#!/bin/bash

# Build mysql clients for a particular mysql version and architecture
# ./build-clients.sh --mysql-version 8.0.36 --arch arm64

set -eu -o pipefail

usage() {
    echo "Usage: $0 --mysql-version <version> --arch <architecture>"
    exit 1
}

if [ $# -eq 0 ]; then
    usage
fi

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        --mysql-version)
            if [ -n "${2-}" ]; then
                MYSQL_VERSION="$2"
                shift 2
            else
                echo "Error: --mysql-version requires a value"
                usage
            fi
            ;;
        --arch)
            if [ -n "${2-}" ]; then
                ARCH="$2"
                shift 2
            else
                echo "Error: --arch requires a value"
                usage
            fi
            ;;
        *)
            echo "Error: Invalid option $1"
            usage
            ;;
    esac
done

# Check if both options are set
if [ -z "$MYSQL_VERSION" ] || [ -z "$ARCH" ]; then
    usage
fi


echo "MySQL Version: $MYSQL_VERSION"
echo "Architecture: ${ARCH}"

set -x

docker pull randyfay/cmake

if [ ! -d mysql_${MYSQL_VERSION} ]; then
  curl -L --fail -o /tmp/mysql.tgz https://dev.mysql.com/get/Downloads/MySQL-${MYSQL_VERSION%.?}/mysql-${MYSQL_VERSION}.tar.gz
  mkdir -p mysql_${MYSQL_VERSION}
  tar -C mysql_${MYSQL_VERSION} --strip-components=1 -zxf /tmp/mysql.tgz
fi
pushd mysql_${MYSQL_VERSION}
echo "Building ${ARCH} for mysql ${MYSQL_VERSION}"
docker run --rm --platform=linux/${ARCH} -e MYSQL_VERSION=${MYSQL_VERSION} -e ARCH=${ARCH} -v .:/src randyfay/cmake

popd


