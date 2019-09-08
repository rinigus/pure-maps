#!/bin/bash

ENABLE_MIMIC=${ENABLE_MIMIC:-1}
ENABLE_PICOTTS=${ENABLE_PICOTTS:-1}

set -Eeuo pipefail

# Setup paths
ROOT=$(git rev-parse --show-toplevel)
ARCH_TRIPLET=$1
GENERAL_BUILD_DIR=$ROOT/build_ubports/$ARCH_TRIPLET
BUILD_DIR=$GENERAL_BUILD_DIR/pure-maps
INSTALL_DIR=$BUILD_DIR/click
LIBS_INSTALL_DIR=$INSTALL_DIR/lib/$ARCH_TRIPLET
BIN_INSTALL_DIR=$INSTALL_DIR/lib/$ARCH_TRIPLET/bin
SHARE_INSTALL_DIR=$INSTALL_DIR/usr/share

# Install meta data
cp $ROOT/packaging/ubports/manifest.json $INSTALL_DIR
cp $ROOT/packaging/ubports/pure-maps.apparmor $INSTALL_DIR
cp $ROOT/packaging/ubports/pure-maps.svg $INSTALL_DIR
mv $GENERAL_BUILD_DIR/pure-maps/click/share/applications/pure-maps.desktop $INSTALL_DIR

# Replace icon name in desktop file
sed -i 's/Icon=pure-maps/Icon=pure-maps.svg/g' $INSTALL_DIR/pure-maps.desktop

# Install binaries
mkdir -p $BIN_INSTALL_DIR

mv $GENERAL_BUILD_DIR/pure-maps/click/bin/* $BIN_INSTALL_DIR
cp $GENERAL_BUILD_DIR/qmlrunner/qmlrunner $BIN_INSTALL_DIR

if [ "$ENABLE_MIMIC" == "1" ] ; then
	cp $GENERAL_BUILD_DIR/mimic/install/bin/mimic $BIN_INSTALL_DIR
	# Strip binaries
	if [ "$ARCH_TRIPLET" == "arm-linux-gnueabihf" ]; then
		arm-linux-gnueabihf-strip -s $BIN_INSTALL_DIR/mimic
	fi
fi

if [ "$ENABLE_PICOTTS" == "1" ] ; then
	cp $GENERAL_BUILD_DIR/picotts/install/usr/bin/pico2wave $BIN_INSTALL_DIR

	# Install data
	mkdir -p $SHARE_INSTALL_DIR

	cp -r $GENERAL_BUILD_DIR/picotts/install/usr/share/picotts $SHARE_INSTALL_DIR/
fi

# Install libs
mkdir -p $LIBS_INSTALL_DIR

cp -r $GENERAL_BUILD_DIR/mapbox-gl-native/install/usr/lib/$ARCH_TRIPLET/*.so* $LIBS_INSTALL_DIR/
cp -r $GENERAL_BUILD_DIR/mapbox-gl-qml/install/usr/lib/$ARCH_TRIPLET/qt5/qml/* $LIBS_INSTALL_DIR/
cp -r $GENERAL_BUILD_DIR/nemo-qml-plugin-dbus/install/usr/lib/$ARCH_TRIPLET/qt5/qml/* $LIBS_INSTALL_DIR/
cp -r $GENERAL_BUILD_DIR/nemo-qml-plugin-dbus/install/usr/lib/*.so* $LIBS_INSTALL_DIR/
