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
able to run the application. In this case, Qt Creator can be used. See
details below.

Alternative, is to use Flatpak-based environment and develop using
that. For this approach, see separate
[README](packaging/flatpak/README.md).

To build a click package for Ubuntu Touch, see separate
[README](packaging/ubports/README.md).

## Platforms

To support multiple platforms, QML code is split into
platform-specific and platform-independent parts. Platform-independent
part is in `qml` folder with the platform-dependent code under
`qml/<platform-id>`. Correct platform is picked up in installation
phase (`make install`) or is set by `make` for local builds.

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
* GPXPy, https://github.com/tkrajina/gpxpy

When developing with Kirigami using flatpak builder, dependencies will
be pulled and installed in flatpak. See instructions regarding
Kirigami below.

GPXPy is also provided as a thirdparty submodule and can be installed
together with Pure Maps by setting `INCLUDE_GPXPY=yes` argument to
`make install`. 


## Building

Starting from Pure Maps version 2.0, the application has to be
compiled. You could either

- compile/install/run
- compile/run from source tree

In the both cases, you would have to specify platform via `FLAVOR`
to `qmake`. Supported platforms:

- Kirigami: `FLAVOR=kirigami`
- QtControls: `FLAVOR=qtcontrols`
- Sailfish: `FLAVOR=silica`
- Ubuntu Touch: `FLAVOR=ubports`

It is recommended to build the sources in a separate folder, as in
```
mkdir build
cd build
qmake FLAVOR=kirigami ..
make && make install
```

For compile/install/run, use regular `make` and `make install` before
running application.

To run from the source tree, add `CONFIG+=run_from_source` option when
running `qmake`. Please note that, when running from source tree, do
not run `make install` in the build folder. Otherwise it can overwrite
your source files. In this case, `make` and running compiled
executable directly would allow you to run application without
installation. For example, from Qt Creator directly.

The build options can be specified in Qt Creator under "Build
settings" of the project. Just add them to the additional arguments of
qmake.


## API keys

Note that you will need API keys if you wish to access the services
that require them (such as Mapbox). For that, register as a developer
and insert these keys in the preferences. Among services that don't
require API keys are OSM Scout Server (for offline maps), HSL (raster
tiles for Finland), Sputnik (raster tiles in Russian), Photon
(search).


## Packaging

At present, Sailfish OS version is packaged as RPM, Linux version
is packaged using Flatpak or RPM, and UBPorts version as click.

For packaging, please copy `tools/apikeys_dummy.py` to
`tools/apikeys.py` and fill missing API keys for the services that you
plan to use.

Flatpak specific instructions are available under `packaging/flatpak`. 

UBPorts specific instructions are available under `packaging/ubports`.


## Development

### General

Throughout QML, Python, and C++ code, all the same type items
(properties, signals, functions), are ordered alphabetically.

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
