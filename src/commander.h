/*
 * This file is part of Pure Maps.
 *
 * SPDX-FileCopyrightText: 2020 Rinigus https://github.com/rinigus
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 */

#ifndef COMMANDER_H
#define COMMANDER_H

#include <QObject>
#include <QString>

class Commander: public QObject
{
  Q_OBJECT

public:
  Commander();

signals:
  void search(QString searchString);
  void showPoi(QString title, double latitude, double longitude);

public:
  static Commander* instance();

private:

  static Commander *s_instance;
};

#endif // COMMANDER_H
