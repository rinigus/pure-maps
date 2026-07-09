#!/usr/bin/env bash
set -euo pipefail

PYOTHERSIDE_REF="1.6.2"

JOBS=$(nproc)
SRC_DIR=/opt/pure-maps-deps-src-pyotherside

mkdir -p "${SRC_DIR}"
cd "${SRC_DIR}"

# get sources
git clone https://github.com/thp/pyotherside.git
git -C pyotherside checkout "${PYOTHERSIDE_REF}"

# build
cd pyotherside
qmake6 PYTHON_CONFIG=python3-config
make -j"${JOBS}"
make install

rm -rf "${SRC_DIR}"
