#!/usr/bin/env bash
set -euo pipefail

QT_VERSION="${1:?usage: install-debian-packages.sh <qt5|qt6>}"

COMMON_PACKAGES=(
  ca-certificates
  git
  build-essential
  g++
  cmake
  ninja-build
  pkg-config
  gettext
  curl
  wget
  xz-utils
  zlib1g-dev
  sudo
  bash-completion
  dbus-x11
  fonts-noto-core
  libgl1-mesa-dri
  libgl1-mesa-dev
  libgles2-mesa-dev
  libasound2-dev
  libgeoip-dev
  libicu-dev
  libpcre2-dev
  libpopt-dev
  libssl-dev
  libtool
  libvdpau-va-gl1
  libxkbcommon-dev
  automake
  autoconf
  libxml2-dev
  libxslt1-dev
  python3
  python3-pip
  python3-setuptools
)

QT5_PACKAGES=(
  libqt5core5a
  libqt5dbus5
  libqt5location5-plugins
  libqt5svg5-dev
  qt5-qmake
  qtbase5-dev
  qtbase5-dev-tools
  qtdeclarative5-dev
  qtdeclarative5-dev-tools
  qtpositioning5-dev
  qtquickcontrols2-5-dev
  qttools5-dev
  qttools5-dev-tools
  qtwayland5
  qml-module-io-thp-pyotherside
  qml-module-org-kde-kirigami2
  qml-module-qt-labs-platform
  qml-module-qt-labs-settings
  qml-module-qtgraphicaleffects
  qml-module-qtmultimedia
  qml-module-qtpositioning
  qml-module-qtqml-models2
  qml-module-qtquick-controls
  qml-module-qtquick-controls2
  qml-module-qtquick-dialogs
  qml-module-qtquick-layouts
  qml-module-qtquick-window2
  qml-module-qtsensors
)

QT6_PACKAGES=(
  libqt6svg6-dev
  qmake6
  qt6-base-dev
  qt6-base-dev-tools
  qt6-declarative-dev
  qt6-declarative-dev-tools
  qt6-positioning-dev
  qt6-svg-plugins
  qt6-tools-dev
  qt6-tools-dev-tools
  qt6-wayland
  qml6-module-io-thp-pyotherside
  qml6-module-org-kde-kirigami
  qml6-module-qt-labs-platform
  qml6-module-qt-labs-settings
  qml6-module-qt5compat-graphicaleffects
  qml6-module-qtmultimedia
  qml6-module-qtpositioning
  qml6-module-qtqml
  qml6-module-qtqml-models
  qml6-module-qtquick
  qml6-module-qtquick-controls
  qml6-module-qtquick-dialogs
  qml6-module-qtquick-layouts
  qml6-module-qtquick-window
  qml6-module-qtsensors
)

case "${QT_VERSION}" in
  qt5)
    QT_PACKAGES=("${QT5_PACKAGES[@]}")
    ;;
  qt6)
    QT_PACKAGES=("${QT6_PACKAGES[@]}")
    ;;
  *)
    echo "Unsupported Qt version: ${QT_VERSION}" >&2
    exit 2
    ;;
esac

apt-get update
apt-get install -y --no-install-recommends "${COMMON_PACKAGES[@]}" "${QT_PACKAGES[@]}"
rm -rf /var/lib/apt/lists/*
