#ifndef MANEUVER_H
#define MANEUVER_H

#include <QGeoCoordinate>
#include <QString>
#include <QVariantMap>

struct Maneuver
{
public:
  Maneuver(const QVariantMap &map);

public:
  QGeoCoordinate coordinate;
  double duration;
  double duration_on_route{0};
  QString icon;
  QString instArrive;
  QString instDepart;
  double length{0};
  double length_on_route{0};
  QString name;
  QString narrative;
  bool passive;
  QVariantMap sign;
  QString street;
};

#endif // MANEUVER_H
