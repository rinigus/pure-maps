# Ubuntu Touch Packaging

## Preparations

Install [Clickable](https://clickable-ut.dev/en/latest/install.html)
which is used to build and publish click packages.

Copy `tools/apikeys_dummy.py` to `tools/apikeys.py` and fill missing API
keys for the services that you plan to use.

Create a symlink to the config file to omit the `-c` flag in all clickable
calls:

    ln -s packaging/click/full-build.yaml clickable.yaml

for the full build including Mimic, resulting in a 100 MB click package, or:

    ln -s packaging/click/slim-build.yaml clickable.yaml

for the slim build without Mimic (but still with PicoTTS), resulting in a 10 MB
click package.

## Dependencies

**WARNING**: Dependencies may take hours to build (especially mimic).

Run the following command to download and compile the app dependencies:

    clickable script prepare-deps
    clickable build --libs --arch armhf # for armhf devices
    clickable build --libs --arch arm64 # for arm64 devices
    clickable build --libs --arch amd64 # for desktop mode

## Building

Build the app by running

    clickable build --arch armhf # for armhf devices
    clickable build --arch arm64 # for arm64 devices
    clickable build --arch amd64 # for desktop mode

## Debugging

To debug on a Ubuntu Touch device run

    clickable chain build install launch logs --arch arm64 # or armhf

To debug in desktop mode run one of these:

    clickable desktop # implies to build and run
    clickable desktop --clean # build clean
    clickable desktop --skip-build # start app without rebuilding

See [Clickable docs](https://clickable-ut.dev/en/latest/) for details.
