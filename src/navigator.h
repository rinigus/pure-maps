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

  Q_PROPERTY(double  bearing READ bearing NOTIFY bearingChanged)
  Q_PROPERTY(QString destDist READ destDist NOTIFY destDistChanged)
  Q_PROPERTY(QString destEta READ destEta NOTIFY destEtaChanged)
  Q_PROPERTY(QString destTime READ destTime NOTIFY destTimeChanged)
  Q_PROPERTY(QString icon READ icon NOTIFY iconChanged)
  Q_PROPERTY(QString manDist READ manDist NOTIFY manDistChanged)
  Q_PROPERTY(QString manTime READ manTime NOTIFY manTimeChanged)
  Q_PROPERTY(QString mode READ mode NOTIFY modeChanged)
  Q_PROPERTY(QString narrative READ narrative NOTIFY narrativeChanged)
  Q_PROPERTY(bool    onRoad READ onRoad NOTIFY onRoadChanged)
  Q_PROPERTY(double  progress READ progress NOTIFY progressChanged)
  Q_PROPERTY(bool    running READ running WRITE setRunning NOTIFY runningChanged)
  Q_PROPERTY(QVariantMap sign READ sign NOTIFY signChanged)
  Q_PROPERTY(QString street READ street NOTIFY streetChanged)
  Q_PROPERTY(QString totalDist READ totalDist NOTIFY totalDistChanged)
  Q_PROPERTY(QString totalTime READ totalTime NOTIFY totalTimeChanged)
  Q_PROPERTY(QString units READ units WRITE setUnits NOTIFY unitsChanged)

  Q_PROPERTY(QList<QGeoCoordinate> route READ route NOTIFY routeChanged)

public:
  explicit Navigator(QObject *parent = nullptr);

  // current state
  double  bearing() const { return m_bearing; }
  QString destDist() const { return m_destDist; }
  QString destEta() const { return m_destEta; }
  QString destTime() const { return m_destTime; }
  QString icon() const { return m_icon; }
  QString manDist() const { return m_manDist; }
  QString manTime() const { return m_manTime; }
  QString mode() const { return m_mode; }
  QString narrative() const { return m_narrative; }
  bool    onRoad() const { return m_onRoad; }
  double  progress() const;
  QVariantMap sign() const { return m_sign; }
  QString street() const { return m_street; }
  QString totalDist() const { return m_totalDist; }
  QString totalTime() const { return m_totalTime; }


  Q_INVOKABLE void setPosition(const QGeoCoordinate &c, double horizontalAccuracy, bool valid);

  // route
  Q_INVOKABLE void clearRoute();
  QList<QGeoCoordinate> route() const { return m_route; }
  Q_INVOKABLE void setRoute(QVariantMap m);

  bool running () const { return m_running; }
  void setRunning(bool r);

  QString units() const { return m_units; }
  void setUnits(QString u);

signals:
  void bearingChanged();
  void destDistChanged();
  void destEtaChanged();
  void destTimeChanged();
  void iconChanged();
  void manDistChanged();
  void manTimeChanged();
  void modeChanged();
  void narrativeChanged();
  void onRoadChanged();
  void progressChanged();
  void routeChanged();
  void runningChanged();
  void signChanged();
  void streetChanged();
  void totalDistChanged();
  void totalTimeChanged();
  void unitsChanged();

protected:
  QString distanceToStr(double meters, bool condence=true) const;
  QString timeToStr(double seconds) const;

private:
  // Edges of the route
  struct EdgeInfo {
    double length;
    double length_before;
    double bearing{0};
    size_t maneuver{0};
  };

  // Points from the past trajectory on route
  struct PointInfo {
    S2Point point;
    double accuracy;
    double bearing{0};
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
  double m_last_duration_along_route{-1};
  double m_distance_to_route_m{-1};
  size_t m_offroad_count{0};

  double  m_bearing;
  QString m_destDist;
  QString m_destEta;
  QString m_destTime;
  QString m_icon;
  QString m_manDist;
  QString m_manTime;
  QString m_narrative;
  bool    m_onRoad{false};
  QVariantMap m_sign;
  QString m_street;
  QString m_totalDist;
  QString m_totalTime;

  QString m_units{QLatin1String("metric")};
};

#endif // NAVIGATOR_H
