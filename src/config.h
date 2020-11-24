/*
 * This file is part of Pure Maps.
 *
 * SPDX-FileCopyrightText: 2020 Rinigus https://github.com/rinigus
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 */

#ifndef CONFIG_H
#define CONFIG_H

#include <QDBusConnection>

// d-bus access
#define DBUS_SERVICE "io.github.rinigus.PureMaps"
#define DBUS_PATH_ROOT "/io/github/rinigus/PureMaps"
#define DBUS_INTERFACE_ROOT "io.github.rinigus.PureMaps"

#define DBUS_PATH_NAVIGATOR DBUS_PATH_ROOT "/navigator"
#define DBUS_INTERFACE_NAVIGATOR DBUS_INTERFACE_ROOT ".navigator"

extern QDBusConnection *dbusconnection;

#endif // CONFIG_H
