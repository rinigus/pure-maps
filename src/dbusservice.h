#ifndef DBUSSERVICE_H
#define DBUSSERVICE_H

#include <QObject>
#include <QSet>

#include "config.h"

// DBus service manager - registration of objects
// and initialization of the service
class DBusService : public QObject
{
  Q_OBJECT
public:
  explicit DBusService(QObject *parent = nullptr);

  void init();
  void registerNavigator(QObject *navigator);

public:
  static DBusService* instance();

private:
  void checkIfReady();

private:
  enum Objects {Root, Navigator};

  const QSet<Objects> c_expected;
  QSet<Objects> m_objects;

  static DBusService *s_instance;
};

#endif // DBUSSERVICE_H
