#!/bin/bash

ENABLE_MIMIC=${ENABLE_MIMIC:-1}
ENABLE_PICOTTS=${ENABLE_PICOTTS:-1}

set -Eeuo pipefail

ROOT_DIR=$(git rev-parse --show-toplevel)
CLONE_ARGS="--recursive --shallow-submodules --depth 1"
MAPLIBRE_GL_NATIVE_SRC_DIR=$ROOT_DIR/libs/maplibre-gl-native
MAPBOX_GL_QML_SRC_DIR=$ROOT_DIR/libs/mapbox-gl-qml
QMLRUNNER_SRC_DIR=$ROOT_DIR/libs/qmlrunner
MIMIC_SRC_DIR=$ROOT_DIR/libs/mimic
MIMIC_VERSION="1.3.0.1"
PICOTTS_SRC_DIR=$ROOT_DIR/libs/picotts
ABSEIL_SRC_DIR=$ROOT_DIR/libs/abseil
S2GEOMETRY_SRC_DIR=$ROOT_DIR/libs/s2geometry

# Remove old downloads
rm -rf $MAPLIBRE_GL_NATIVE_SRC_DIR $MAPBOX_GL_QML_SRC_DIR $QMLRUNNER_SRC_DIR $MIMIC_SRC_DIR $PICOTTS_SRC_DIR $S2GEOMETRY_SRC_DIR $ABSEIL_SRC_DIR

# Download sources
git clone -b qt-v2.0.1 ${CLONE_ARGS} https://github.com/maplibre/maplibre-gl-native.git $MAPLIBRE_GL_NATIVE_SRC_DIR
git clone -b 2.1.1 ${CLONE_ARGS} https://github.com/rinigus/mapbox-gl-qml.git $MAPBOX_GL_QML_SRC_DIR
git clone -b 1.0.2 ${CLONE_ARGS} https://github.com/rinigus/qmlrunner.git $QMLRUNNER_SRC_DIR
git clone -b v0.11.1 ${CLONE_ARGS} https://github.com/google/s2geometry.git $S2GEOMETRY_SRC_DIR
git clone -b 20240722.0 ${CLONE_ARGS} https://github.com/abseil/abseil-cpp.git $ABSEIL_SRC_DIR

if [ "$ENABLE_MIMIC" == "1" ] ; then
	wget -qO- https://github.com/MycroftAI/mimic1/archive/${MIMIC_VERSION}.tar.gz  | tar -xzv && mv mimic1-${MIMIC_VERSION} $MIMIC_SRC_DIR
fi

if [ "$ENABLE_PICOTTS" == "1" ] ; then
	git clone ${CLONE_ARGS} https://github.com/jonnius/pkg-picotts.git $PICOTTS_SRC_DIR
fi

# Apply patches
cd $MAPLIBRE_GL_NATIVE_SRC_DIR
git apply $ROOT_DIR/packaging/click/patches/maplibre-gl-native/*.patch

cd $ABSEIL_SRC_DIR
git apply $ROOT_DIR/packaging/click/patches/abseil/*.patch
