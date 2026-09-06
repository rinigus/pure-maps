#!/usr/bin/env bash
set -euo pipefail

MAPLIBRE_REF="v3.0.0"
MAPBOX_GL_QML_REF="79e0ccc"

QT_VERSION="${1:?usage: build-map-qml-deps.sh <qt5|qt6>}"
JOBS=$(nproc)
SRC_DIR=/opt/pure-maps-deps-src-map-qml

case "${QT_VERSION}" in
  qt5)
    QMAKE_BIN="qmake"
    MAPLIBRE_WITH_WIDGETS="OFF"
    ;;
  qt6)
    QMAKE_BIN="qmake6"
    MAPLIBRE_WITH_WIDGETS="ON"
    ;;
  *)
    echo "Unsupported Qt version: ${QT_VERSION}" >&2
    exit 2
    ;;
esac

mkdir -p "${SRC_DIR}"
cd "${SRC_DIR}"

# get sources
git clone https://github.com/maplibre/maplibre-native-qt.git
git -C maplibre-native-qt checkout "${MAPLIBRE_REF}"
git -C maplibre-native-qt submodule update --init --recursive --jobs "${JOBS}"

git clone https://github.com/rinigus/mapbox-gl-qml.git
git -C mapbox-gl-qml checkout "${MAPBOX_GL_QML_REF}"

# build maplibre
cmake -S maplibre-native-qt -B maplibre-native-qt/build -G Ninja \
  -DMLN_QT_WITH_WIDGETS="${MAPLIBRE_WITH_WIDGETS}" \
  -DMLN_QT_WITH_LOCATION=OFF \
  -DCMAKE_INSTALL_PREFIX:PATH=/usr \
  -DMLN_QT_WITH_INTERNAL_ICU=ON \
  -DCMAKE_CXX_FLAGS="-include cstdint" \
  -DMLN_WITH_WERROR=OFF
cmake --build maplibre-native-qt/build --parallel "${JOBS}"
cmake --install maplibre-native-qt/build

# build qml
cmake -S mapbox-gl-qml -B mapbox-gl-qml/build -G Ninja \
  -DQT_VERSION_MAJOR="${QT_VERSION#qt}" \
  -DQT_INSTALL_QML="$(${QMAKE_BIN} -query QT_INSTALL_QML)"
cmake --build mapbox-gl-qml/build --parallel "${JOBS}"
cmake --install mapbox-gl-qml/build

rm -rf "${SRC_DIR}"
