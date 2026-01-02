# Building PureMaps (Tested on Debian 12 and Ubuntu 24.04)

This document covers the full process for building and installing **PureMaps** and its dependencies from source. It applies to common Linux distributions and has been tested on **Debian 12** and **Ubuntu 24.04**.

---

## Dependencies

In addition to general QML development packages, the following specific dependencies are required:

* [PyOtherSide](https://github.com/thp/pyotherside)
* [PyXDG](https://www.freedesktop.org/wiki/Software/pyxdg/)
* [Mapbox GL Native (Qt fork)](https://github.com/rinigus/pkg-mapbox-gl-native) or [MapLibre Native Qt](https://github.com/maplibre/maplibre-native-qt)
* [Mapbox GL QML](https://github.com/rinigus/mapbox-gl-qml)
* [GPXPy](https://github.com/tkrajina/gpxpy) (available as submodule)
* [S2 Geometry Library](https://github.com/google/s2geometry)
* [Nemo DBus](https://github.com/sailfishos/nemo-qml-plugin-dbus) (needed for Kirigami platform)

> When building with **flatpak-builder**, dependencies will be handled via Flatpak manifest.

---

## Install System Packages

```bash
sudo apt update
sudo apt install -y git build-essential cmake ninja-build pkg-config \
    qt5-qmake libqt5core5a libqt5dbus5 qtbase5-dev qtdeclarative5-dev \
    python3 python3-pip python3-setuptools \
    libpcre2-dev libasound2-dev libssl-dev \
    libtool automake autoconf libxml2-dev libxslt1-dev \
    libgeoip-dev libgl1-mesa-dev libgles2-mesa-dev \
    libicu-dev libpopt-dev libqt5svg5-dev qtpositioning5-dev \
    qttools5-dev gettext qtquickcontrols2-5-dev \
    qml-module-qtpositioning qml-module-qtmultimedia \
    qml-module-qtsensors libqt5location5-plugins
```

---

## Build Third-Party Dependencies

### Abseil

```bash
git clone https://github.com/abseil/abseil-cpp.git
cd abseil-cpp
git checkout 4447c7562e3bc702ade25105912dce503f0c4010
mkdir build && cd build
cmake -DBUILD_SHARED_LIBS=ON -G Ninja ..
ninja
sudo ninja install
cd ../..
```

### S2Geometry

```bash
git clone https://github.com/google/s2geometry.git
cd s2geometry
git checkout 713f9c27fed3085cc8dcf18a9d664c39227a0c45
mkdir build && cd build
cmake -DBUILD_SHARED_LIBS=ON -DBUILD_PYTHON=OFF -DBUILD_TESTS=OFF -G Ninja ..
ninja
sudo ninja install
cd ../..
```

### Nemo DBus (for Kirigami)

```bash
wget https://github.com/sailfishos/nemo-qml-plugin-dbus/archive/refs/tags/2.1.27.tar.gz
tar -xzvf 2.1.27.tar.gz
cd nemo-qml-plugin-dbus-2.1.27
qmake
make
sudo make install
cd ..
```

### PyOtherSide

```bash
wget https://github.com/thp/pyotherside/archive/1.5.9.tar.gz
tar -xzvf 1.5.9.tar.gz
cd pyotherside-1.5.9
qmake
make
sudo make install
cd ..
```

### PyXDG

```bash
pip3 install pyxdg
```

### MapLibre GL Native Qt

```bash
git clone https://github.com/maplibre/maplibre-native-qt.git
cd maplibre-native-qt
git checkout d929c783737120787b43417d9ef05da88da75dfd
git submodule update --init --recursive
sed -i 's/add_subdirectory(test)/#add_subdirectory(test)/' CMakeLists.txt
mkdir build && cd build
cmake -DMLN_QT_WITH_WIDGETS=OFF -DMLN_QT_WITH_LOCATION=OFF \
      -DMLN_QT_WITH_INTERNAL_ICU=ON -DMLN_WITH_WERROR=OFF -G Ninja ..
ninja
sudo ninja install
cd ../..
```

### Mapbox GL QML

```bash
git clone https://github.com/rinigus/mapbox-gl-qml.git
cd mapbox-gl-qml
git checkout 7cb85afbf26369db3698ff34af84436cb0d897e7
mkdir build && cd build
cmake -DQT_INSTALL_QML=/usr/lib/qml -G Ninja ..
ninja
sudo ninja install
cd ../..
```

### Mimic1 (TTS Engine)

```bash
git clone https://github.com/MycroftAI/mimic1.git
cd mimic1
git checkout eba879c6e4ece50ca6de9b4966f2918ed89148bd
./autogen.sh
./configure --with-audio=none
make
sudo make install
cd ..
```

### Libpopt

```bash
wget https://ftp.osuosl.org/pub/rpm/popt/releases/popt-1.x/popt-1.19.tar.gz
tar -xzvf popt-1.19.tar.gz
cd popt-1.19
./configure
make
sudo make install
cd ..
```

### PicoTTS

```bash
git clone https://github.com/ihuguet/picotts.git
cd picotts
git checkout 21089d223e177ba3cb7e385db8613a093dff74b5
cd pico
./autogen.sh
./configure --prefix=/usr
make
sudo make install
cd ../../
```

---

## Build PureMaps

```bash
git clone https://github.com/rinigus/pure-maps.git
cd pure-maps
git checkout b594d2f5c480686a2b7df15eb565df3c2f51adff
git submodule update --init --recursive
cp poor/apikeys.py tools/apikeys.py
mkdir build && cd build
cmake -DFLAVOR=kirigami -DAPP_NAME=pure-maps \
      -DUSE_BUNDLED_GPXPY=ON -DMAPMATCHING_CHECK_RUNTIME=OFF \
      -DMAPMATCHING_AVAILABLE=ON -DUSE_BUNDLED_GEOCLUE2=ON ..
make
sudo make install
```

---

## Notes on Build Options

* To **run without installing**, add `-DRUN_FROM_SOURCE=ON` and avoid using `make install`.
* Platform can be specified using `-DFLAVOR=`:

  * `kirigami`
  * `qtcontrols`
  * `silica`
  * `uuitk`
* Recommended: use an out-of-source build with a separate `build/` directory.

---

## Packaging and Defaults

To configure default services for packaging:

```bash
cmake -DDEFAULT_PROFILE=online \
      -DDEFAULT_BASEMAP=osm \
      -DDEFAULT_GEOCODER=photon \
      -DDEFAULT_GUIDE=guideservice \
      -DDEFAULT_ROUTER=graphhopper ..
```

Each provider refers to its corresponding JSON or Python configuration file in PureMaps.

---

## Environment Setup

```bash
echo 'export QT_PLUGIN_PATH=/usr/local/qml' >> ~/.bashrc
echo 'export QML2_IMPORT_PATH=/usr/lib/qml' >> ~/.bashrc
source ~/.bashrc
```

---

## Run PureMaps

```bash
pure-maps
```
