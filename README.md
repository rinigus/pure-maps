# Pure Maps

[![Latest release](https://img.shields.io/github/v/release/rinigus/pure-maps)](https://github.com/rinigus/pure-maps/releases)
[![SFOS](https://img.shields.io/badge/SailfishOS-OpenRepos-1CA198)](https://openrepos.net/content/rinigus/pure-maps)
[![Ubuntu Touch](https://img.shields.io/badge/Ubuntu%20Touch-OpenStore-292929)](https://open-store.io/app/pure-maps.jonnius)
[![Flatpak](https://img.shields.io/badge/Flatpak-Flathub-4A86CF)](https://flathub.org/apps/details/io.github.rinigus.PureMaps)
[![Fedora](https://img.shields.io/badge/O.B.S-Fedora-3C6EB4)](https://build.opensuse.org/package/show/home:rinigus:maps/pure-maps)

[![Matrix](https://img.shields.io/badge/matrix.org-%23pure--maps-blue)](https://matrix.to/#/#pure-maps:matrix.org)
[![TMO](https://img.shields.io/badge/forum-T.M.O-FB9200)](https://talk.maemo.org/showthread.php?t=100442)


Pure Maps is an application for Sailfish OS and Linux to display
vector and raster maps, places, routes, and provide navigation
instructions with a flexible selection of data and service providers.

Pure Maps is free software released under the GNU General Public
License (GPL), see the file [`COPYING`](COPYING) for details. Pure
Maps is a fork of [WhoGo Maps](https://github.com/otsaloma/whogo-maps)
that was made to continue its development.


## User feedback

There are three main communication channels with the users: GitHub,
Matrix channel
[#pure-maps:matrix.org](https://matrix.to/#/#pure-maps:matrix.org) and
a thread at [TMO](https://talk.maemo.org/showthread.php?t=100442).

Please use Github issues to address specific problems and development
requests. General discussion is expected either through corresponding
issues, Matrix channel, or TMO thread. Please note that users from all
platforms are welcome at TMO, not only current Sailfish OS users.

Currently, the homepage for Pure Maps is a placeholder. You are
welcome to help by working on the corresponding
[issue](https://github.com/rinigus/pure-maps/issues/400).


## Command line options

Pure Maps supports positional argument (one) that could either specify
`geo:latitude,longitude` URI or a search string that will be searched
by geocoder.

If Pure Maps instance is running already, it will be contacted via
DBus and the request will be forwarded.


## DBus API

DBus (service `io.github.rinigus.PureMaps` at session bus) can be used
to

* search: method `Search`
* show poi: method `ShowPoi`
* get navigation status and control it.

There service is split as described below.

### Global actions

Path: `/io/github/rinigus/PureMaps`
Interface: `io.github.rinigus.PureMaps`

Methods:

* `Search(String search_string)` - activates search action for given
  `search_string`

* `ShowPoi(String title, Double latitude, Double longitude)` - show
  POI on map with the given coordinates and title.


### Navigation

Path: `/io/github/rinigus/PureMaps/navigator`
Interface: `io.github.rinigus.PureMaps.navigator`

Methods:

* `Clear()` - stops navigation and removes current route

* `Start() -> Boolean` - start navigation and returns `true` if
  succesful. If already started or has no route defined, will return
  `false` to indicate failure.

* `Stop()` - stop navigation if running.

Properties and signals:

Each property has a corresponding `...Changed` signal to indicate when
the value of the property has changed.

* `destDist`, `destEta`, `destTime` - human readable strings with the
  remaining distance, time, and estimated time of arrival

* `direction` and `directionValid` - bearing of the current route
  segment and whether it is valid (current location is on route)

* `hasRoute` - whether route has been set in application

* `icon` - icon name for the next maneuver

* `language` - navigation instructions language

* `manDist`, `manTime` - remaining distance and time for the next
  maneuver in human readable form

* `mode` - mode of transportation

* `narrative` - longer next maneuver instruction, should be available
  for all maneuvers

* `alongRoute` - whether current location is on route and movement is
  along it.

* `progress` - current progress along the route in percentage (0-100)

* `running` - whether navigation in active

* `street` - short form of the narrative usually shown in Pure Maps
  next to the maneuver icon. Could be absent for some maneuvers

* `totalDist`, `totalTime` - total route distance and time in human
  readable form.



## Development

For development of Pure Maps and testing on desktop, you would have to
choose platform for which you develop, install dependencies, and be
able to run the application. In this case, Qt Creator can be used. See
details below.

Alternative, is to use Flatpak-based environment and develop using
that. For this approach, see separate
[README](packaging/flatpak/README.md).

Building and Debugging for Ubuntu Touch is described in
[README](packaging/click/README.md).


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


## Dependencies

In addition to common dependencies for QML applications, the following
are needed:

* PyOtherSide https://github.com/thp/pyotherside
* PyXDG https://www.freedesktop.org/wiki/Software/pyxdg/
* Mapbox GL Native, Qt version, use the packaged version at https://github.com/rinigus/pkg-mapbox-gl-native
* Mapbox GL QML, unofficial QML bindings, https://github.com/rinigus/mapbox-gl-qml
* GPXPy, https://github.com/tkrajina/gpxpy
* S2 Geometry Library, https://github.com/google/s2geometry
* For Kirigami platform: Nemo DBus https://git.merproject.org/mer-core/nemo-qml-plugin-dbus

When developing with Kirigami using flatpak builder, dependencies will
be pulled and installed in flatpak. See instructions regarding
Kirigami below.

GPXPy is also provided as a thirdparty submodule and can be installed
together with Pure Maps by setting corresponding option during `cmake`
configuration phase.


## Building

Starting from Pure Maps version 2.0, the application has to be
compiled. You could either

- compile/install/run
- compile/run from source tree

In the both cases, you would have to specify platform via `-DFLAVOR`
to `cmake`. Supported platforms:

- Kirigami: `FLAVOR=kirigami`
- QtControls: `FLAVOR=qtcontrols`
- Sailfish: `FLAVOR=silica`
- Ubuntu Touch: `FLAVOR=uuitk`

It is recommended to build the sources in a separate folder, as in
```
mkdir build
cd build
cmake -DFLAVOR=kirigami ..
make && make install
```

For compile/install/run, use regular `make` and `make install` before
running application.

To run from the source tree, add `-DRUN_FROM_SOURCE=ON` option when
running `cmake`. Please note that, when running from source tree, do
not run `make install` in the build folder. Otherwise it can overwrite
your source files. In this case, `make` and running compiled
executable directly would allow you to run application without
installation. For example, from Qt Creator directly.

The build options can be specified in Qt Creator under "Build
settings" of the project. Just add them to the additional arguments of
cmake.

Mainly targeting packagers, it is possible to specify default
providers using `cmake` project options. Notice the difference in
supplied values for basemap and other options:

- `DEFAULT_PROFILE=profile`
  where profile is either online or offline
- `DEFAULT_BASEMAP=provider`
  Map `provider` is either specified in basemap JSON as "provider"
  or, if absent, as "name"
- `DEFAULT_GEOCODER=provider`
- `DEFAULT_GUIDE=provider`
- `DEFAULT_ROUTER=provider`

In the last three options, `provider` corresponds to the basename of
JSON/Python file describing the provider. Example: "photon".


## API keys

Note that you will need API keys if you wish to access the services
that require them (such as Mapbox). For that, register as a developer
and insert these keys in the preferences. Among services that don't
require API keys are OSM Scout Server (for offline maps), HSL (raster
tiles for Finland), Sputnik (raster tiles in Russian), Photon
(search).


## Packaging

Pure Maps is packaged for different distributions. Included in the
source tree: Sailfish OS version is packaged as RPM, Linux version is
packaged using Flatpak or RPM, and Ubuntu Touch version as
click. Several distributions provide packaging scripts in their source
trees.

For packaging, please copy `poor/apikeys.py` to `tools/apikeys.py` and
fill missing API keys for the services that you plan to use. Note that
the format of `tools/apikeys.py` has changed with 2.9 release.

Flatpak specific instructions are available under `packaging/flatpak`.

Ubuntu Touch specific instructions are available in
[Ubuntu Touch README](packaging/click/README.md).


## Development

### General

Throughout QML, Python, and C++ code, all the same type items
(properties, signals, functions), are ordered alphabetically.

Its possible that some of the implemented code does not fully comply
with the outlined order. Then it should be fixed eventually.


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
