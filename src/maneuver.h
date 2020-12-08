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
  QString duration_txt;
  QString icon;
  QString instArrive;
  QString instDepart;
  double length{0};
  double length_on_route{0};
  QString length_txt;
  QString name;
  QString narrative;
  int  next{-1};
  bool passive;
  int  roundabout_exit_count{0};
  QVariantMap sign;
  QString street;
  QString verbal_alert;
  QString verbal_post;
  QString verbal_pre;
};

#endif // MANEUVER_H
