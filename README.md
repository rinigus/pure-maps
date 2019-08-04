# Pure Maps

Pure Maps is an application for Sailfish OS and Linux to display
vector and raster maps, places, routes, and provide navigation
instructions with a flexible selection of data and service providers.

Pure Maps is free software released under the GNU General Public
License (GPL), see the file [`COPYING`](COPYING) for details. Pure
Maps is a fork of [WhoGo Maps](https://github.com/otsaloma/whogo-maps)
that was made to continue its development.


## User feedback

There are two main communication channels with the users: GitHub and a
thread at
[TMO](https://talk.maemo.org/showthread.php?t=100442). 

Please use Github issues to address specific problems and development
requests. General discussion is expected either through corresponding
issues opened by maintainer or TMO thread. Please note that users from
all platforms are welcome at TMO, not only current Sailfish OS users.


## Development

For development of Pure Maps and testing on desktop, you would have to
choose platform for which you develop, install dependencies, and be
able to run application. All this is covered below. 

Alternative, is to use Flatpak-based environment and develop using
that. For this approach, see separate
[README](packaging/flatpak/README.md).


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

* platform.kirigami -> make target `platform-kirigami`
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
* [non-Sailfish] QML runner https://github.com/rinigus/qmlrunner
* GPXPy, https://github.com/tkrajina/gpxpy

When developing with Kirigami using flatpak builder, dependencies will
be pulled and installed in flatpak. See instructions regarding
Kirigami below.

GPXPy is also provided as a thirdparty submodule and can be installed
together with Pure Maps by setting `INCLUDE_GPXPY=yes` argument to
`make install`. 


## Running

For development purposes, Pure Maps doesn't need to be installed in
the system and can be started wither using `qmlscene`, `qmlrunner`, or
some similar tool. On Linux desktop, `qmlrunner` is recommended since
it adds support for fallback icons.

The both solutions require the path used to install QML
dependencies. In the following examples, `/usr/local/lib64/qml`,
please adjust if needed.

To run Pure Maps from the folder containing source, make a symbolic
links

```
ln -s qml/icons/fallback icons
ln -s ../thirdparty/open-location-code poor/openlocationcode
```

and then run with

```
qmlrunner -P .. -path /usr/local/lib64/qml pure-maps
```

or

```
qmlscene -I /usr/local/lib64/qml qml/pure-maps.qml
```

Note that you will need API keys if you wish to access the services
that require them (such as Mapbox). For that, register as a developer
and insert these keys in the preferences. Among services that don't
require API keys are OSM Scout Server (for offline maps), HSL (raster
tiles for Finland), Sputnik (raster tiles in Russian), Photon
(search).


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


## Platform specific notes

### Kirigami

Kirigami platform may require latest platform SDK available as
flatpaks. See instructions at
https://docs.plasma-mobile.org/AppDevelopment.html for local
development. From these instructions, only SDK install is
needed. After that, building and running can be performed by

```
make flatpak-build flatpak-run
```

If you wish to install development version for testing, you could use
the following command instead (will build the package, bundle it,
uninstall current version of Pure Maps, and install the freshly built
one):
```
make flatpak-dev-install
```


## Development

### General

Throughout QML and Python code, all the same type items (properties,
signals, functions), are ordered alphabetically. 

Its possible that some of the implemented code does not fully comply
with the outlined order. Then it should be fixed eventually.

If you wish to run the code while developing, it is recommended to
make a symbolic link (command run from Pure Maps source folder):

```
ln -s ../thirdparty/open-location-code poor/openlocationcode
```

If GPXPy is not installed in the system, but is pulled as a thirdparty
module, Pure Maps will run when executed using `qmlscene`, `qmlrunner`
or similar tool, but the automatic tests will fail. This is an expected
behavior or the implementation.

### QML

To simplify development, there are few simple rules regarding QML file
organization. QML files are organized as follows (use the needed
components):

```
import A
import B
import "."

import "js/util.js" as Util

Item {
    id: item
    
    // base class defined properties in alphabetic order
    prop_a: val_a
    prop_b: val_b
    
    // new properties in alphabetic order
    property         var  np_a: default_a
    default property bool np_b: default_b
    
    // readonly properties
    readonly property var images: QtObject {
        readonly property string pixel:         "pure-image-pixel"
        readonly property string poi:           "pure-image-poi"
        readonly property string poiBookmarked: "pure-image-poi-bookmarked"
    }
    
    // signals
    signal mySignal

    // local unexported properties
    property bool _locked: false

    // behavior
    Behavior on bearing {
        RotationAnimation {
            direction: RotationAnimation.Shortest
            duration: map.ready ? 500 : 0
            easing.type: Easing.Linear
        }
    }
    
    // new sub-items following the same principles
    Item {
        id: subitem
    }
    
    // connections
    Connections {
    }

    // signal handlers
    Component.onCompleted: init()
    onActivated: doSomething()
    
    // functions 
    function a() {
        return 10;
    }
}
```
