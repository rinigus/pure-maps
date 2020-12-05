/*
 * This file is part of Pure Maps.
 *
 * SPDX-FileCopyrightText: 2020 Rinigus https://github.com/rinigus
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 */

#ifndef DBUSROOT_H
#define DBUSROOT_H

#include "config.h"

#include <QMap>
#include <QObject>
#include <QString>
#include <QStringList>
#include <QVariant>
#include <QVariantList>

// DBus service root object
class DBusRoot : public QObject
{
  Q_OBJECT
  Q_CLASSINFO("D-Bus Interface", DBUS_INTERFACE_ROOT)

public:
  explicit DBusRoot(QObject *parent = nullptr);

public slots:
  // DBus activation
  void Activate(QMap<QString, QVariant> platform_data);
  void Open(QStringList uris, QMap<QString, QVariant> platform_data);
  void ActivateAction(QString action_name, QVariantList parameter, QMap<QString, QVariant> platform_data);

  // Forward command line options
  bool CommandLine(QStringList arguments);

  void Search(QString search_string);
  void ShowPoi(QString title, double latitude, double longitude);

public:

  DBusRoot(QString host, int port, QObject *parent = nullptr);

};

#endif // DBUSROOT_H
