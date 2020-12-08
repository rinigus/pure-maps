#include "maneuver.h"

Maneuver::Maneuver(const QVariantMap &map)
{
  coordinate = QGeoCoordinate(map.value("y").toDouble(), map.value("x").toDouble());
  duration = map.value("duration").toDouble();
  icon = map.value("icon").toString();
  instArrive = map.value("arrive_instruction").toString();
  instDepart = map.value("depart_instruction").toString();
  passive = map.value("passive", false).toBool();
  name = passive ? QStringLiteral("passive") : QStringLiteral("active");
  narrative = map.value("narrative").toString();
  roundabout_exit_count=map.value("roundabout_exit_count").toInt();
  sign = map.value("sign").toMap();
  street = map.value("street").toString();
  verbal_alert = map.value("verbal_alert").toString();
  verbal_post = map.value("verbal_post").toString();
  verbal_pre = map.value("verbal_pre").toString();
  if (verbal_alert.isEmpty()) verbal_alert = narrative;
  if (verbal_pre.isEmpty()) verbal_pre = narrative;
}
