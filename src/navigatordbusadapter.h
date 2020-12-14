#ifndef NAVIGATORDBUSADAPTER_H
#define NAVIGATORDBUSADAPTER_H

#include <QDBusAbstractAdaptor>
#include <QObject>

#include "config.h"
#include "navigator.h"

class NavigatorDBusAdapter : public QDBusAbstractAdaptor
{
  Q_OBJECT
  Q_CLASSINFO("D-Bus Interface", DBUS_INTERFACE_NAVIGATOR)

  Q_PROPERTY(bool    alongRoute READ alongRoute NOTIFY alongRouteChanged)
  Q_PROPERTY(QString destDist READ destDist NOTIFY destDistChanged)
  Q_PROPERTY(QString destEta READ destEta NOTIFY destEtaChanged)
  Q_PROPERTY(QString destTime READ destTime NOTIFY destTimeChanged)
  Q_PROPERTY(double  direction READ direction NOTIFY directionChanged)
  Q_PROPERTY(bool    directionValid READ directionValid NOTIFY directionValidChanged)
  Q_PROPERTY(bool    hasRoute READ hasRoute NOTIFY hasRouteChanged)
  Q_PROPERTY(QString icon READ icon NOTIFY iconChanged)
  Q_PROPERTY(QString language READ language NOTIFY languageChanged)
  Q_PROPERTY(QString manDist READ manDist NOTIFY manDistChanged)
  Q_PROPERTY(QString manTime READ manTime NOTIFY manTimeChanged)
  Q_PROPERTY(QString mode READ mode NOTIFY modeChanged)
  Q_PROPERTY(QString narrative READ narrative NOTIFY narrativeChanged)
  Q_PROPERTY(int     progress READ progress NOTIFY progressChanged)
  Q_PROPERTY(int     roundaboutExit READ roundaboutExit NOTIFY roundaboutExitChanged)
  Q_PROPERTY(bool    running READ running NOTIFY runningChanged)
  Q_PROPERTY(QString street READ street NOTIFY streetChanged)
  Q_PROPERTY(QString totalDist READ totalDist NOTIFY totalDistChanged)
  Q_PROPERTY(QString totalTime READ totalTime NOTIFY totalTimeChanged)

public:
  NavigatorDBusAdapter(Navigator *navigator);

  bool    alongRoute() const { return m->alongRoute(); }
  QString destDist() const { return m->destDist(); }
  QString destEta() const { return m->destEta(); }
  QString destTime() const { return m->destTime(); }
  double  direction() const { return m->direction(); }
  bool    directionValid() const { return m->directionValid(); }
  bool    hasRoute() const { return m_hasRoute; }
  QString icon() const { return m->icon(); }
  QString language() const { return m->language(); }
  QString manDist() const { return m->manDist(); }
  QString manTime() const { return m->manTime(); }
  QString mode() const { return m->mode(); }
  QString narrative() const { return m->narrative(); }
  int     progress() const { return m->progress(); }
  int     roundaboutExit() const { return m->roundaboutExit(); }
  bool    running() const { return m->running(); }
  QString street() const { return m->street(); }
  QString totalDist() const { return m->totalDist(); }
  QString totalTime() const { return m->totalTime(); }

public slots:
  void Clear();
  bool Start();
  void Stop();


signals:
  void alongRouteChanged();
  void destDistChanged();
  void destEtaChanged();
  void destTimeChanged();
  void directionChanged();
  void directionValidChanged();
  void hasRouteChanged();
  void iconChanged();
  void languageChanged();
  void manDistChanged();
  void manTimeChanged();
  void modeChanged();
  void narrativeChanged();
  void progressChanged();
  void roundaboutExitChanged();
  void runningChanged();
  void streetChanged();
  void totalDistChanged();
  void totalTimeChanged();

protected:
  void update();

private:
  Navigator *m{nullptr};
  bool       m_hasRoute{false};
};

#endif // NAVIGATORDBUSADAPTER_H
