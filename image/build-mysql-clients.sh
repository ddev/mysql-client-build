#!/bin/bash

set -eu -o pipefail

set -x

BUILDDIR=build_${ARCH}
rm -rf ${BUILDDIR}
mkdir -p ${BUILDDIR}
# OUTPUTDIR contructed from required MYSQL_VERSION and ARCH
OUTPUTDIR="/src/built_${MYSQL_VERSION}_${ARCH}"

cmake -B${BUILDDIR} -H. -DWITHOUT_SERVER=1 -DDOWNLOAD_BOOST=1 -DWITH_BOOST=/usr/local/boost -DCMAKE_INSTALL_PREFIX=${OUTPUTDIR}
cd ${BUILDDIR}
make mysql mysqldump
make install

# Output version to verify version and arch
${OUTPUTDIR}/bin/mysql --version
${OUTPUTDIR}/bin/mysqldump --version
