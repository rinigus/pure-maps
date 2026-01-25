#!/bin/bash

ENABLE_MIMIC=${ENABLE_MIMIC:-1}
ENABLE_PICOTTS=${ENABLE_PICOTTS:-1}

set -Eeuo pipefail

ROOT_DIR=$(git rev-parse --show-toplevel)
CLONE_ARGS="--recursive --shallow-submodules --depth 1"
MAPLIBRE_NATIVE_SRC_DIR=$ROOT_DIR/libs/maplibre-native
MAPBOX_GL_QML_SRC_DIR=$ROOT_DIR/libs/mapbox-gl-qml
QMLRUNNER_SRC_DIR=$ROOT_DIR/libs/qmlrunner
MIMIC_SRC_DIR=$ROOT_DIR/libs/mimic
MIMIC_VERSION="1.3.0.1"
PICOTTS_SRC_DIR=$ROOT_DIR/libs/picotts
ABSEIL_SRC_DIR=$ROOT_DIR/libs/abseil
S2GEOMETRY_SRC_DIR=$ROOT_DIR/libs/s2geometry
PATCH_DIR=$ROOT_DIR/packaging/click/patches

# Remove old downloads
rm -rf $MAPLIBRE_NATIVE_SRC_DIR $MAPBOX_GL_QML_SRC_DIR $QMLRUNNER_SRC_DIR $MIMIC_SRC_DIR $PICOTTS_SRC_DIR $S2GEOMETRY_SRC_DIR $ABSEIL_SRC_DIR

# Download sources
git clone -b v3.0.0 ${CLONE_ARGS} https://github.com/maplibre/maplibre-native-qt.git $MAPLIBRE_NATIVE_SRC_DIR
git clone -b 3.1.1 ${CLONE_ARGS} https://github.com/rinigus/mapbox-gl-qml.git $MAPBOX_GL_QML_SRC_DIR
git clone -b 1.0.2 ${CLONE_ARGS} https://github.com/rinigus/qmlrunner.git $QMLRUNNER_SRC_DIR
git clone -b v0.11.1 ${CLONE_ARGS} https://github.com/google/s2geometry.git $S2GEOMETRY_SRC_DIR
git clone -b 20250127.1 ${CLONE_ARGS} https://github.com/abseil/abseil-cpp.git $ABSEIL_SRC_DIR

if [ "$ENABLE_MIMIC" == "1" ] ; then
	wget -qO- https://github.com/MycroftAI/mimic1/archive/${MIMIC_VERSION}.tar.gz  | tar -xzv && mv mimic1-${MIMIC_VERSION} $MIMIC_SRC_DIR
fi

if [ "$ENABLE_PICOTTS" == "1" ] ; then
	git clone -b 17.08.10-ut1 ${CLONE_ARGS} https://github.com/jonnius/pkg-picotts.git $PICOTTS_SRC_DIR
fi

# Apply patches
cd $MAPLIBRE_NATIVE_SRC_DIR
git apply $PATCH_DIR/maplibre-native/*.patch

cd $MAPLIBRE_NATIVE_SRC_DIR/vendor/maplibre-native
git apply $PATCH_DIR/maplibre-native_vendor/*.patch

cd $ABSEIL_SRC_DIR
git apply $PATCH_DIR/abseil/*.patch

cd $MIMIC_SRC_DIR
patch -p1 < $PATCH_DIR/mimic/fix-compilation.patch
