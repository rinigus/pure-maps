#!/bin/bash

set -Eeuo pipefail

# Setup paths
ROOT=$(git rev-parse --show-toplevel)
ARCH_TRIPLET=$1
GENERAL_BUILD_DIR=$ROOT/build_ubports/$ARCH_TRIPLET
BUILD_DIR=$GENERAL_BUILD_DIR/pure-maps
INSTALL_DIR=$BUILD_DIR/click
LIBS_INSTALL_DIR=$INSTALL_DIR/lib/$ARCH_TRIPLET
BIN_INSTALL_DIR=$INSTALL_DIR/lib/$ARCH_TRIPLET/bin

# Install meta data
cp $ROOT/packaging/ubports/manifest.json $INSTALL_DIR
cp $ROOT/packaging/ubports/pure-maps.apparmor $INSTALL_DIR
cp $ROOT/packaging/ubports/pure-maps.svg $INSTALL_DIR/pure-maps
mv $GENERAL_BUILD_DIR/pure-maps/click/share/applications/pure-maps.desktop $INSTALL_DIR

# Install binaries
mkdir -p $BIN_INSTALL_DIR

mv $GENERAL_BUILD_DIR/pure-maps/click/bin/* $BIN_INSTALL_DIR
cp $GENERAL_BUILD_DIR/qmlrunner/qmlrunner $BIN_INSTALL_DIR
cp $GENERAL_BUILD_DIR/flite/install/bin/flite{,_cmu_us_kal16,_cmu_us_slt} $BIN_INSTALL_DIR

# Strip binaries
if [ "$ARCH_TRIPLET" == "arm-linux-gnueabihf" ]; then
	arm-linux-gnueabihf-strip -s $BIN_INSTALL_DIR/flite*
fi

# Install libs
mkdir -p $LIBS_INSTALL_DIR

cp -r $GENERAL_BUILD_DIR/mapbox-gl-native/install/usr/lib/$ARCH_TRIPLET/*.so* $LIBS_INSTALL_DIR/
cp -r $GENERAL_BUILD_DIR/mapbox-gl-qml/install/usr/lib/$ARCH_TRIPLET/qt5/qml/* $LIBS_INSTALL_DIR/
cp -r $GENERAL_BUILD_DIR/nemo-qml-plugin-dbus/install/usr/lib/$ARCH_TRIPLET/qt5/qml/* $LIBS_INSTALL_DIR/
cp -r $GENERAL_BUILD_DIR/nemo-qml-plugin-dbus/install/usr/lib/*.so* $LIBS_INSTALL_DIR/
