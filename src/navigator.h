#ifndef NAVIGATOR_H
#define NAVIGATOR_H


#include <QGeoCoordinate>
#include <QObject>
#include <QVariantList>
#include <QVariantMap>

#include <deque>
#include <memory>
#include <s2/mutable_s2shape_index.h>
#include <s2/s2polygon.h>

class Navigator : public QObject
{
  Q_OBJECT

  Q_PROPERTY(QList<QGeoCoordinate> route READ route NOTIFY routeChanged)

public:
  explicit Navigator(QObject *parent = nullptr);

  Q_INVOKABLE void setPosition(const QGeoCoordinate &c, double horizontalAccuracy, bool valid);

  // route
  Q_INVOKABLE void clearRoute();
  QList<QGeoCoordinate> route() const { return m_route; }
  Q_INVOKABLE void setRoute(QVariantMap m);

signals:
  void routeChanged();

private:
  // Edges of the route
  struct EdgeInfo {
    double length;
    double length_before;
  };

  // Points from the past trajectory on route
  struct PointInfo {
    S2Point point;
    double length_on_route{-1};
    double accuracy;

    operator bool() const { return length_on_route > 0; }
  };

private:

  std::vector<EdgeInfo> m_edges;
  std::unique_ptr<MutableS2ShapeIndex> m_index;
  std::deque<PointInfo> m_points;
  std::unique_ptr<S2Polyline> m_polyline;
  QList<QGeoCoordinate> m_route;
  double m_route_length_m{-1};

  double m_last_distance_along_route_m{-1};
  double m_distance_to_route_m{-1};
  size_t m_offroad_count{0};
};

#endif // NAVIGATOR_H
