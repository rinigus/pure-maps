# Pure Maps

Pure Maps is a fork of [WhoGo Maps](https://github.com/otsaloma/whogo-maps) 
that was made to continue its development. Pure Maps is an application
for Sailfish OS and Linux to display vector and raster maps, places,
routes, and provide navigation instructions with a flexible selection
of data and service providers.

Pure Maps is free software released under the GNU General Public License
(GPL), see the file [`COPYING`](COPYING) for details.


## Platforms

To support multiple platforms, QML code is split into
platform-specific and platform-independent parts. Platform-independent
part is in `qml` folder with the platform-dependent code under
`qml/<platform-id>`. To switch between platforms, one has to make a
symbolic link from the corresponding `qml/<platform-id>` to
`qml/platform`. This can be done by running 

```
make platform-qtcontrols
```

for example. Current platforms are 

* platform.qtcontrols -> make target `platform-qtcontrols`
* platform.silica -> make target `platform-silica`

Within platform-independent code, platform is included allowing to
access platform-specific implementations of page stack, file dialog,
and other specific aspects. For this approach to work, API in the
platform specific implementation has to be the same for all platforms. 

To add new platform, add new directory under `qml`, new Makefile
target to set it, and implement all the required QML items. Take a
look under other platforms for examples.

For testing purposes you can just run `qmlscene qml/pure-maps.qml`,
after setting the platform.


## Dependencies

In addition to common dependencies for QML applications, the following
are needed:

* Nemo DBus https://git.merproject.org/mer-core/nemo-qml-plugin-dbus
* PyOtherSide https://github.com/thp/pyotherside
* PyXDG https://www.freedesktop.org/wiki/Software/pyxdg/
* Mapbox GL Native, Qt version, use the packaged version at https://github.com/rinigus/pkg-mapbox-gl-native
* Mapbox GL QML, unofficial QML bindings, https://github.com/rinigus/mapbox-gl-qml
* [flatpak only] QML runner https://github.com/rinigus/qmlrunner


## Packaging

At present, Sailfish OS version is packaged as RPM and Linux version
is packaged using Flatpak.

For packaging, please copy `tools/apikeys_dummy.py` to
`tools/apikeys.py` and fill missing API keys for the services that you
plan to use.

For installation on Sailfish, you can build the RPM package with
command `make rpm`. You don't need an SDK to build the RPM, only basic
tools: `make`, `rpmbuild`, `gettext` and `qttools`.

Flatpak specific instructions are available under `packaging/flatpak`.
