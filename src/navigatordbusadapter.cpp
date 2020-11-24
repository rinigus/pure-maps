#include "navigatordbusadapter.h"

NavigatorDBusAdapter::NavigatorDBusAdapter(Navigator *navigator):
  QDBusAbstractAdaptor(navigator),
  m(navigator)
{
  assert(m!= nullptr);
  setAutoRelaySignals(true);
  update();

  connect(m, &Navigator::routeChanged, this, &NavigatorDBusAdapter::update);
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
