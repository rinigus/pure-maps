#ifndef LOCATION_H
#define LOCATION_H

#include <QString>
#include <QVariantMap>

#include <s2/s2point.h>
#include <s2/s1chord_angle.h>

struct Location {
  Location() = default;
  Location(const Location &) = default;
  Location(const QVariantMap &lm);

  // true if point is close to the location
  // assuming that the point is on the route
  bool closeToRoutePoint(const S2Point &p, double accuracy)
  {
    return S1ChordAngle(point, p).radians() < distance_to_route + accuracy;
  }

  // variables
  bool destination{false};
  bool origin{false};
  bool final{false};
  double distance_to_route;
  double duration_on_route{0};
  double length_on_route{0};
  double length_on_route_m{0};
  double latitude;
  double longitude;
  QString name;
  S2Point point;

  // stats
  QString dist;
  QString time;
  QString eta;
  QString legDist;
  QString legTime;

  // arrival info
  bool arrived{false};
  QString arrivedAt;
};

#endif // LOCATION_H
