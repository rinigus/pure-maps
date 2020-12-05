#include "dbusservice.h"

#include <QDBusConnection>
#include <QDebug>
#include <QCoreApplication>

#include <iostream>

#include "config.h"
#include "dbusroot.h"

DBusService *DBusService::s_instance = nullptr;

DBusService::DBusService(QObject *parent) :
  QObject(parent),
  c_expected({Root, Navigator})
{
}

DBusService* DBusService::instance()
{
  if (!s_instance) s_instance = new DBusService();
  return s_instance;
}

void DBusService::init()
{
  // register objects that are available on start

  if (!QDBusConnection::sessionBus().registerObject(DBUS_PATH_ROOT,
                                                    new DBusRoot(QCoreApplication::instance()),
                                                    QDBusConnection::ExportAllSlots | QDBusConnection::ExportAllProperties))
    std::cerr << "Failed to register DBus object: " DBUS_PATH_ROOT << std::endl;
  else
    m_objects.insert(Root);

  // check after filling
  checkIfReady();
}

void DBusService::checkIfReady()
{
  // check if all service objects registered
  if (m_objects != c_expected) return;

  if (!QDBusConnection::sessionBus().registerService(DBUS_SERVICE))
    std::cerr << "Failed to register DBus service: " DBUS_SERVICE << std::endl;
  else
    std::cout << "Started DBus service at " DBUS_SERVICE << std::endl;
}

void DBusService::registerNavigator(QObject *navigator)
{
  if (!QDBusConnection::sessionBus().registerObject(DBUS_PATH_NAVIGATOR,
                                                    navigator))
    std::cerr << "Failed to register DBus object: " DBUS_PATH_NAVIGATOR << std::endl;
  else
    m_objects.insert(Navigator);

  checkIfReady();
}
