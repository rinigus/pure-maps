#include "navigatordbusadapter.h"

#include <QGeoCoordinate>

NavigatorDBusAdapter::NavigatorDBusAdapter(Navigator *navigator):
  QDBusAbstractAdaptor(navigator),
  m(navigator)
{
  assert(m!= nullptr);
  setAutoRelaySignals(true);
  update();

  connect(m, &Navigator::routeChanged, this, &NavigatorDBusAdapter::update);
}

QList<double> NavigatorDBusAdapter::route() const
{
  const QVariantList points = m->route();
  QList<double> route;
  route.reserve(points.size() * 2);
  for (const QVariant &point : points)
    {
      const QGeoCoordinate c = point.value<QGeoCoordinate>();
      if (!c.isValid())
        continue;
      route.append(c.latitude());
      route.append(c.longitude());
    }
  return route;
}

void NavigatorDBusAdapter::update()
{
  bool hr = (m->route().length() > 0);
  if (hr != m_hasRoute)
    {
      m_hasRoute = hr;
      emit hasRouteChanged();
    }
}

void NavigatorDBusAdapter::Clear()
{
  m->clearRoute();
}

bool NavigatorDBusAdapter::Start()
{
  if (!m_hasRoute || running())
    return false;
  m->setRunning(true);
  return true;
}

void NavigatorDBusAdapter::Stop()
{
  if (!m_hasRoute || !running())
    return;
  m->setRunning(false);
}
