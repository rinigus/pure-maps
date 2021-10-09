/*
 * This file is part of OSM Scout Server.
 *
 * SPDX-FileCopyrightText: 2021 Rinigus https://github.com/rinigus
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

#ifndef DBUSTRACKER_H
#define DBUSTRACKER_H

#include <QMutex>
#include <QObject>
#include <QSet>
#include <QString>

/// Registers client services and tracks them
class DBusTracker : public QObject
{
  Q_OBJECT

protected:
  explicit DBusTracker(QObject *parent = nullptr);

public:
  static DBusTracker* instance();

  int numberOfServices();
  void track(const QString &service);
  void stop(const QString &service);

signals:
  void serviceAppeared(QString service);
  void serviceDisappeared(QString service);

public slots:
  // used to track lost clients
  void onNameOwnerChanged(QString name, QString old_owner, QString new_owner);

private:
  QSet<QString> m_tracked;
  QMutex m_mutex;

  static DBusTracker* s_instance;
};

#endif // DBUSTRACKER_H
