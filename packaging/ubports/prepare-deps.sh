#!/bin/bash

ENABLE_MIMIC=${ENABLE_MIMIC:-1}
ENABLE_PICOTTS=${ENABLE_PICOTTS:-1}

set -Eeuo pipefail

# Setup paths where clickable will look for the sources
ROOT_DIR=$(git rev-parse --show-toplevel)
MAPBOX_GL_NATIVE_SRC_DIR=$ROOT_DIR/libs/mapbox-gl-native
MAPBOX_GL_QML_SRC_DIR=$ROOT_DIR/libs/mapbox-gl-qml
NEMO_QML_PLUGIN_DBUS_SRC_DIR=$ROOT_DIR/libs/nemo-qml-plugin-dbus
QMLRUNNER_SRC_DIR=$ROOT_DIR/libs/qmlrunner
MIMIC_SRC_DIR=$ROOT_DIR/libs/mimic
PICOTTS_SRC_DIR=$ROOT_DIR/libs/picotts

# Remove old downloads
rm -rf $MAPBOX_GL_NATIVE_SRC_DIR $MAPBOX_GL_QML_SRC_DIR $NEMO_QML_PLUGIN_DBUS_SRC_DIR $QMLRUNNER_SRC_DIR $MIMIC_SRC_DIR $PICOTTS_SRC_DIR

# Download sources
git clone -b qt-regular https://github.com/rinigus/pkg-mapbox-gl-native.git $MAPBOX_GL_NATIVE_SRC_DIR --recurse-submodules  --shallow-submodules
git clone https://github.com/rinigus/mapbox-gl-qml.git $MAPBOX_GL_QML_SRC_DIR
git clone https://git.merproject.org/mer-core/nemo-qml-plugin-dbus.git $NEMO_QML_PLUGIN_DBUS_SRC_DIR 
git clone https://github.com/rinigus/qmlrunner.git $QMLRUNNER_SRC_DIR

if [ "$ENABLE_MIMIC" == "1" ] ; then
	wget -qO- https://github.com/MycroftAI/mimic1/archive/1.2.0.2.tar.gz  | tar -xzv && mv mimic1-1.2.0.2 $MIMIC_SRC_DIR
fi

if [ "$ENABLE_PICOTTS" == "1" ] ; then
	git clone https://github.com/jonnius/pkg-picotts.git $PICOTTS_SRC_DIR
fi

# Replace mapbox-gl-native pro file
rm $MAPBOX_GL_NATIVE_SRC_DIR/mapbox-gl-native/mapbox-gl-native.pro
ln -s $MAPBOX_GL_NATIVE_SRC_DIR/mapbox-gl-native-lib.pro $MAPBOX_GL_NATIVE_SRC_DIR/mapbox-gl-native
