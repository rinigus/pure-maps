#!/bin/bash

set -Eeuo pipefail

# Setup paths where clickable will look for the sources
ROOT_DIR=$(git rev-parse --show-toplevel)
MAPBOX_GL_NATIVE_SRC_DIR=$ROOT_DIR/libs/mapbox-gl-native
MAPBOX_GL_QML_SRC_DIR=$ROOT_DIR/libs/mapbox-qml
QMLRUNNER_SRC_DIR=$ROOT_DIR/libs/qmlrunner

# Remove old downloads
rm -rf $MAPBOX_GL_NATIVE_SRC_DIR $MAPBOX_GL_QML_SRC_DIR $QMLRUNNER_SRC_DIR

# Download sources
git clone -b qt-regular git@github.com:rinigus/pkg-mapbox-gl-native.git $MAPBOX_GL_NATIVE_SRC_DIR --recurse-submodules  --shallow-submodules
git clone git@github.com:rinigus/mapbox-gl-qml.git $MAPBOX_GL_QML_SRC_DIR
git clone git@github.com:rinigus/qmlrunner.git $QMLRUNNER_SRC_DIR

# Replace mapbox-gl-native pro file
rm $MAPBOX_GL_NATIVE_SRC_DIR/mapbox-gl-native/mapbox-gl-native.pro
ln -s $MAPBOX_GL_NATIVE_SRC_DIR/mapbox-gl-native-lib.pro $MAPBOX_GL_NATIVE_SRC_DIR/mapbox-gl-native
