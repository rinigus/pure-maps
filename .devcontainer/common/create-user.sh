#!/bin/sh
set -eu

USERNAME=${USERNAME:-dev}
USER_UID=${USER_UID:-1000}
USER_GID=${USER_GID:-$USER_UID}

groupadd --gid "$USER_GID" "$USERNAME"
useradd --uid "$USER_UID" --gid "$USER_GID" -m -s /bin/bash "$USERNAME"
mkdir -p "/tmp/runtime-$USERNAME"
chown "$USER_UID:$USER_GID" "/tmp/runtime-$USERNAME"
chmod 0700 "/tmp/runtime-$USERNAME"
printf '%s ALL=(root) NOPASSWD:ALL\n' "$USERNAME" > "/etc/sudoers.d/$USERNAME"
chmod 0440 "/etc/sudoers.d/$USERNAME"
