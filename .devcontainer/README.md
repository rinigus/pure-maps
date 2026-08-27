# Dev Containers

This directory contains development containers for building and running Pure
Maps from the source tree. The containers are intended for local development
with a Dev Containers compatible editor and either Podman or Docker (tested
with Podman only so far).

## Naming

Container display names focus on the Qt version first and keep the base system
in parentheses:

* `Qt5 Latest (Debian 12)` uses the latest Qt 5 packages shipped by Debian 12.
* `Qt6 Stable (Debian 13)` uses the stable Qt 6 packages shipped by Debian 13.
* `Qt6 Latest (Fedora 44)` tracks the latest Qt 6 packages released by Fedora.

Directory names use the base distribution family first, followed by the Qt line,
for stable paths used by mounts and cache directories. Distribution release
numbers are intentionally kept out of these names so the base image version can
change without changing the Dev Container entry or state directory name:

* `debian-qt5`
* `debian-qt6`
* `fedora-qt6`

The scripts use `qt5` and `qt6` as short arguments when the build step only
needs to know the Qt major version.

## Layout

Each container directory contains a `devcontainer.json` and a `Dockerfile`.
The build context is `.devcontainer`, which allows each Dockerfile to copy
shared scripts from `common` while keeping distro-specific package installation
in the per-container Dockerfile.

The shared scripts are organized as follows:

* `common/install-debian-packages.sh` installs common Debian packages and the
  selected Qt package set. It is used by the Debian-based containers only.
* `common/build-s2geometry.sh` builds and installs Abseil and S2 Geometry from
  pinned upstream versions. All containers use it.
* `common/build-map-qml-deps.sh` builds and installs MapLibre Native Qt and
  `mapbox-gl-qml`. It accepts `qt5` or `qt6` to select the matching qmake and
  Qt build options.
* `common/build-pyotherside.sh` builds PyOtherSide for Qt 6. It is used by the
  Fedora container because Fedora does not provide the needed package.
* `common/create-user.sh` contains the common user-creation logic. The current
  Dockerfiles keep that logic inline.

Source archives cloned during image builds are placed under `/opt` and removed
before the image layer completes.

## Build Options

All containers define the `INSTALL_MAP_QML_DEPS` build argument and set it to
`true` from `devcontainer.json`. When enabled, the image builds MapLibre Native
Qt and `mapbox-gl-qml` during image creation. Set this argument to `false` only
when you intentionally want a lighter image without those QML map dependencies.

The Debian containers install Qt and most runtime dependencies from distro
packages. The Fedora container installs Qt from Fedora packages too, but builds
PyOtherSide from source because the needed Qt 6 package is not available there.

## Mounts

The source checkout is mounted into the container as `/workspace`:

```json
"workspaceMount": "source=${localWorkspaceFolder},target=/workspace,type=bind"
```

All containers run as the `dev` user and enable `updateRemoteUserUID` so file
ownership matches the host user where supported by the container runtime.

The containers also mount selected host runtime paths so the desktop
application can be launched from inside the container:

* `/tmp/.X11-unix` and `${HOME}/.Xauthority` provide X11 access.
* `${XDG_RUNTIME_DIR}/${WAYLAND_DISPLAY}` provides Wayland access.
* `${XDG_RUNTIME_DIR}/bus` provides the host session D-Bus socket.
* `${XDG_RUNTIME_DIR}/pulse/native` provides PulseAudio access.
* `/run/dbus/system_bus_socket` provides read-only access to the system D-Bus
  socket.
* `/dev/dri` exposes GPU rendering devices.

Persistent editor and user state is stored under `.devcontainer/state` in the
checkout:

* `.devcontainer/state/config` is shared by all containers and mounted as
  `/home/dev/.config`.
* `.devcontainer/state/<container>/local` is mounted as `/home/dev/.local`.
* `.devcontainer/state/<container>/cache` is mounted as `/home/dev/.cache`.

The per-container `local` and `cache` directories avoid mixing Qt 5, Qt 6,
Debian, and Fedora generated files. The shared `config` directory keeps editor
and application configuration available when switching containers.

`.devcontainer/state` is ignored by Git. Remove the corresponding
`.devcontainer/state/<container>` directory if you need to reset user-local or
cache files for one container. Remove `.devcontainer/state/config` only if you
also want to reset shared application and editor configuration.

## Editor Configuration

The VSCode customization installs Qt, CMake, and C++ extensions, enables CMake
presets, and configures the container Qt path for the Qt extension. Qt 6
containers also point the Qt QML extension at the distro `qmlls` executable and
disable the prompt to download another one.

The containers use `shutdownAction: stopContainer`, so closing the editor stops
the container but keeps the image and the mounted state directories for the next
session.

## Runtime Notes

The runtime mounts are aimed at Linux desktop sessions with X11, Wayland, D-Bus,
PulseAudio, and `/dev/dri` available on the host. The images include the matching
Qt Wayland plugin and the devcontainers default `QT_QPA_PLATFORM` to `wayland`.
Use `QT_QPA_PLATFORM=xcb` to force X11/Xwayland when needed.

The `--userns=keep-id` and `--security-opt=label:disable` run arguments are
included for Podman-friendly host integration. Docker generally ignores user
namespace behavior that it does not support in the same way, but the container
still runs as the `dev` user configured by Dev Containers.
