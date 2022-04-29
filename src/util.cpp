/*
 * This file is part of Pure Maps. Misc utility functions
 *
 * SPDX-FileCopyrightText: 2022 Rinigus https://github.com/rinigus
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 */

#include "config.h"

#include <QDir>
#include <QDebug>
#include <QFile>
#include <QSettings>
#include <QStandardPaths>

#ifdef IS_SAILFISH_OS
void migrateSailfishSettings()
{
  // The new location of config file
  QSettings settings(QStandardPaths::writableLocation(QStandardPaths::ConfigLocation) + "/" SFOS_HOME_PREFIX "/PureMaps.conf", QSettings::NativeFormat);
  const QString key(QStringLiteral("sailjail_migrated"));

  if (settings.contains(key)) return;

  // copy old configuration into new location
  qInfo() << "Migrating the settings to new location";

  const QString oldPath(QStandardPaths::writableLocation(QStandardPaths::ConfigLocation) + "/harbour-pure-maps");
  const QString newPath(QStandardPaths::writableLocation(QStandardPaths::ConfigLocation) + "/" SFOS_HOME_PREFIX);

  if (!QDir().mkpath(newPath))
    {
      qCritical() << "Failed to create directory" << newPath;
      return;
    }

  QDir oldDir(oldPath);
  for (QString fname: oldDir.entryList(QDir::Files))
    {
      qInfo() << oldPath + QDir::separator() + fname << "->"
              << newPath + QDir::separator() + fname;
      QFile::rename(oldPath + QDir::separator() + fname,
                    newPath + QDir::separator() + fname);
    }

  settings.setValue(key, 1);
}
#endif
