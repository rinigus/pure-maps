/*
 * This file is part of Pure Maps.
 *
 * SPDX-FileCopyrightText: 2020 Rinigus https://github.com/rinigus
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 */

#include "dbusroot.h"

#include "cmdlineparser.h"
#include "commander.h"

#include <QDebug>

DBusRoot::DBusRoot(QObject *parent) : QObject(parent)
{
}

// DBus activation
void DBusRoot::Activate(QMap<QString, QVariant> /*platform_data*/)
{
  qDebug() << "DBus Activate called";
}

void DBusRoot::Open(QStringList /*uris*/, QMap<QString, QVariant> /*platform_data*/)
{
  qDebug() << "DBus Open called";
}

void DBusRoot::ActivateAction(QString /*action_name*/, QVariantList /*parameter*/, QMap<QString, QVariant> /*platform_data*/)
{
  qDebug() << "DBus ActivateAction called";
}

// Command line options forwarded from other instances
bool DBusRoot::CommandLine(QStringList arguments)
{
  qDebug() << "Command line options received from secondary instance: " << arguments;

  if (CmdLineParser::instance()->parse(arguments))
    CmdLineParser::instance()->process();

  return true;
}

void DBusRoot::Search(QString search_string)
{
  Commander::instance()->search(search_string);
}

void DBusRoot::ShowPoi(QString title, double latitude, double longitude)
{
  Commander::instance()->showPoi(title, latitude, longitude);
}
