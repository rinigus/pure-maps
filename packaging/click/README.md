# Ubuntu Touch Packaging

## Preparations

Install [Clickable](http://clickable.bhdouglass.com/en/latest/install.html)
which is used to build and publish click packages.

Also copy `tools/apikeys_dummy.py` to `tools/apikeys.py` and fill missing API
keys for the services that you plan to use.

Create a symlink to the config file to omit the `-c` flag in all clickable
calls:

    ln -s packaging/click/full-build.json clickable.json

for the full build including Mimic, resulting in a 98 MB click package, or:

    ln -s packaging/click/slim-build.json clickable.json

for the slim build without Mimic (but still with PicoTTS), resulting in a 10 MB
click package.

## Dependencies

**WARNING**: Dependencies may take hours to build (especially mimic).

Run the following command to download and compile the app dependencies:

    clickable prepare-deps
    clickable build-libs --arch armhf # for armhf devices
    clickable build-libs --arch arm64 # for arm64 devices
    clickable build-libs --arch amd64 # for desktop mode

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

See [Clickable docs](https://clickable-ut.dev/en/latest/) for details.
