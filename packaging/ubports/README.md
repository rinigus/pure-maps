# Ubuntu Touch Packaging

## Preparations

Install [Clickable](http://clickable.bhdouglass.com/en/latest/install.html)
which is used to build and publish click packages.

Also copy `tools/apikeys_dummy.py` to `tools/apikeys.py` and fill missing API
keys for the services that you plan to use.

You may want to create a symlink to the config file to omit the `-c` flag in
all clickable calls:

    ln -s packaging/ubports/clickable.json clickable.json

Otherwise you'll have to append `-c packaging/ubports/clickable.json` to all
clickable commands.

## Dependencies

**WARNING**: Dependencies may take hours to build (especially mimic).

Download dependency sources:

    clickable prepare-deps

### Python >= 3.6
Run the following command to download and compile the app dependencies:

    clickable build-libs --arch armhf # or arm64 depending on your device

If you'd like to debug on desktop, too, also compile the dependencies for amd64:

    clickable build-libs --arch amd64

### Python < 3.6
Run the following command to download and compile the app dependencies:

    clickable build-libs mapbox-gl-native --arch armhf # or arm64
    clickable build-libs mapbox-gl-qml --arch armhf # or arm64
    clickable build-libs qmlrunner --arch armhf # or arm64
    clickable build-libs nemo-qml-plugin-dbus --arch armhf # or arm64
    clickable build-libs mimic --arch armhf # or arm64
    clickable build-libs picotts --arch armhf # or arm64

If you'd like to debug on desktop, too, also compile the dependencies for amd64:

    clickable build-libs mapbox-gl-native --arch amd64
    clickable build-libs mapbox-gl-qml --arch amd64
    clickable build-libs qmlrunner --arch amd64
    clickable build-libs nemo-qml-plugin-dbus --arch amd64
    clickable build-libs mimic --arch amd64
    clickable build-libs picotts --arch amd64

## Building

Build the app by running

    clickable build --arch armhf # for armhf devices
    clickable build --arch arm64 # for arm64 devices
    clickable build --arch amd64 # for desktop mode

## Debugging

To debug on a Ubuntu Touch device simply run

    clickable # implies a clean build run, installing on device and launching
    clickable logs # to watch logs

To debug on the desktop run of these:

    clickable desktop # implies a clean build run
    clickable desktop --dirty # avoid clean before build
    clickable desktop --skip-build # start app without building

See [Clickable docs](http://clickable.bhdouglass.com/en/latest/) for details.
