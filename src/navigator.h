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

#include "maneuver.h"

class Navigator : public QObject
{
  Q_OBJECT

  Q_PROPERTY(QString mode READ mode NOTIFY modeChanged)
  Q_PROPERTY(double progress READ progress NOTIFY progressChanged)
  Q_PROPERTY(QString units READ units WRITE setUnits NOTIFY unitsChanged)
  Q_PROPERTY(QList<QGeoCoordinate> route READ route NOTIFY routeChanged)

public:
  explicit Navigator(QObject *parent = nullptr);

  // commands
  Q_INVOKABLE bool start();
  Q_INVOKABLE void stop();

  // current state
  QString mode() const { return m_mode; }
  double progress() const;

  Q_INVOKABLE void setPosition(const QGeoCoordinate &c, double horizontalAccuracy, bool valid);

  // route
  Q_INVOKABLE void clearRoute();
  QList<QGeoCoordinate> route() const { return m_route; }
  Q_INVOKABLE void setRoute(QVariantMap m);

  QString units() const { return m_units; }
  void setUnits(QString u);

signals:
  void modeChanged();
  void progressChanged();
  void routeChanged();
  void unitsChanged();

protected:
  QString distanceToStr(double meters, bool condence=true) const;

private:
  // Edges of the route
  struct EdgeInfo {
    double length;
    double length_before;
    size_t maneuver{0};
  };

  // Points from the past trajectory on route
  struct PointInfo {
    S2Point point;
    double accuracy;
    size_t maneuver{0};
    double length_on_route{-1};

    operator bool() const { return length_on_route > 0; }
  };

private:
  bool m_running{false};

  std::vector<EdgeInfo> m_edges;
  std::unique_ptr<MutableS2ShapeIndex> m_index;
  std::vector<Maneuver> m_maneuvers;
  QString m_mode{"car"};
  std::deque<PointInfo> m_points;
  std::unique_ptr<S2Polyline> m_polyline;
  QList<QGeoCoordinate> m_route;

  S2Point m_last_point;
  bool m_last_point_initialized{false};

  // NB! All distances in Rad unless having suffix _m for Meters

  double m_route_length_m{-1};
  double m_route_duration{0};
  double m_distance_traveled_m{0};
  double m_last_distance_along_route_m{-1};
  double m_distance_to_route_m{-1};
  size_t m_offroad_count{0};

  QString m_units{QLatin1String("metric")};
};

#endif // NAVIGATOR_H
