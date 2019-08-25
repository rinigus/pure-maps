#!/bin/bash

set -Eeuo pipefail

# Setup paths where clickable will look for the sources
ROOT_DIR=$(git rev-parse --show-toplevel)
MAPBOX_GL_NATIVE_SRC_DIR=$ROOT_DIR/libs/mapbox-gl-native
MAPBOX_GL_QML_SRC_DIR=$ROOT_DIR/libs/mapbox-gl-qml
NEMO_QML_PLUGIN_DBUS_SRC_DIR=$ROOT_DIR/libs/nemo-qml-plugin-dbus
QMLRUNNER_SRC_DIR=$ROOT_DIR/libs/qmlrunner
FLITE_SRC_DIR=$ROOT_DIR/libs/flite

# Remove old downloads
rm -rf $MAPBOX_GL_NATIVE_SRC_DIR $MAPBOX_GL_QML_SRC_DIR $NEMO_QML_PLUGIN_DBUS_SRC_DIR $QMLRUNNER_SRC_DIR $FLITE_SRC_DIR

# Download sources
git clone -b qt-regular https://github.com/rinigus/pkg-mapbox-gl-native.git $MAPBOX_GL_NATIVE_SRC_DIR --recurse-submodules  --shallow-submodules
git clone https://github.com/rinigus/mapbox-gl-qml.git $MAPBOX_GL_QML_SRC_DIR
git clone https://git.merproject.org/mer-core/nemo-qml-plugin-dbus.git $NEMO_QML_PLUGIN_DBUS_SRC_DIR 
git clone https://github.com/rinigus/qmlrunner.git $QMLRUNNER_SRC_DIR
git clone https://github.com/festvox/flite --depth 1 $FLITE_SRC_DIR

# Replace mapbox-gl-native pro file
rm $MAPBOX_GL_NATIVE_SRC_DIR/mapbox-gl-native/mapbox-gl-native.pro
ln -s $MAPBOX_GL_NATIVE_SRC_DIR/mapbox-gl-native-lib.pro $MAPBOX_GL_NATIVE_SRC_DIR/mapbox-gl-native
