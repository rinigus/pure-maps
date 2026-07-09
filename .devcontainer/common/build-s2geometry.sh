#!/usr/bin/env bash
set -euo pipefail

ABSEIL_REF="lts_2024_07_22"
S2_REF="v0.12.0"

JOBS=$(nproc)
SRC_DIR=/opt/pure-maps-deps-src-s2

mkdir -p "${SRC_DIR}"
cd "${SRC_DIR}"

# get sources
git clone https://github.com/abseil/abseil-cpp.git
git -C abseil-cpp checkout "${ABSEIL_REF}"

git clone https://github.com/google/s2geometry.git
git -C s2geometry checkout "${S2_REF}"

# build
cmake -S abseil-cpp -B abseil-cpp/build -G Ninja \
  -DBUILD_SHARED_LIBS=ON \
  -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
  -DCMAKE_INSTALL_PREFIX:PATH=/usr \
  -DCMAKE_CXX_STANDARD=17
cmake --build abseil-cpp/build --parallel "${JOBS}"
cmake --install abseil-cpp/build

cmake -S s2geometry -B s2geometry/build -G Ninja \
  -DBUILD_SHARED_LIBS=ON \
  -DCMAKE_INSTALL_PREFIX:PATH=/usr \
  -DCMAKE_CXX_STANDARD=17 \
  -DBUILD_PYTHON=OFF \
  -DBUILD_TESTS=OFF
cmake --build s2geometry/build --parallel "${JOBS}"
cmake --install s2geometry/build

rm -rf "${SRC_DIR}"
