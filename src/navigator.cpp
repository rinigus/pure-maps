#include "navigator.h"

#include <QCoreApplication>
#include <QDebug>
#include <QGeoCoordinate>
#include <QTime>

#include <s2/s2closest_edge_query.h>
#include <s2/s2earth.h>
#include <vector>
#include <cmath>

// NB! All distances in Rad unless having suffix _m for Meters

#define MAX_ROUTE_INTERSECTIONS 5  // Maximal number of route intersections with itself
#define REF_POINT_ADD_MARGIN    2  // Add next reference point along the route when it is that far away from the last one (relative to accuracy)
#define NUMBER_OF_REF_POINTS    2  // how many points to keep as a reference
#define MAX_OFFROAD_COUNTS      3  // times position was updated and point was off the route (counted in a sequence)

// use var without m_ prefix
#define SET(var, value) { auto t=(value); if (m_##var != t) { m_##var=t; emit var##Changed(); } }

Navigator::Navigator(QObject *parent) : QObject(parent)
{
}


void Navigator::clearRoute()
{
  setRunning(false);
  m_polyline.release();
  m_route.clear();
  emit routeChanged();

  m_distance_traveled_m = 0;
  emit progressChanged();

  SET(totalDist, "");
  SET(totalTime, "");
  SET(destDist, "");
  SET(destEta, "");
  SET(destTime, "");
  SET(onRoad, false);
}


void Navigator::setPosition(const QGeoCoordinate &c, double horizontalAccuracy, bool valid)
{
  if (!m_index || !valid || horizontalAccuracy > 100) return;

  qDebug() << c << horizontalAccuracy << valid;

  double accuracy_rad = S2Earth::MetersToRadians(20); //horizontalAccuracy));
  S1ChordAngle accuracy = S1ChordAngle::Radians(accuracy_rad);
  S2Point point = S2LatLng::FromDegrees(c.latitude(), c.longitude()).ToPoint();

  // check if standing still
  if (m_last_point_initialized && m_last_point.Angle(point) < accuracy_rad/10)
    return;

  // update travelled distance and last point
  if (m_last_point_initialized && m_running)
    m_distance_traveled_m += S2Earth::RadiansToMeters( m_last_point.Angle(point) );

  m_last_point_initialized = true;
  m_last_point = point;

  // find if are on the route
  S2ClosestEdgeQuery::PointTarget target(point);
  S2ClosestEdgeQuery query(m_index.get());
  query.mutable_options()->set_max_results(MAX_ROUTE_INTERSECTIONS);
  query.mutable_options()->set_max_distance(accuracy);

  PointInfo best;
  PointInfo ref;
  if (m_points.size() > 0) ref = m_points.front();

  for (const auto& result : query.FindClosestEdges(&target))
    {
      S2Point pr = query.Project(point, result);
      EdgeInfo &einfo = m_edges[result.edge_id()];

      // is the projected point between edge vertices?
      S2Shape::Edge edge = query.GetEdge(result);
      double dist_edge_v0 = S1ChordAngle(edge.v0, pr).radians();
      double dist_edge_v1 = S1ChordAngle(edge.v1, pr).radians();
      double dist_edge = einfo.length;

      // replace point with vertex if it is projected outside the edge
      bool betweenVertexes = true;
      if ( dist_edge < dist_edge_v0 )
        {
          pr = edge.v1;
          dist_edge_v0 = dist_edge;
          betweenVertexes = false;
        }
      else if ( dist_edge < dist_edge_v1 )
        {
          pr = edge.v0;
          dist_edge_v0 = 0;
          betweenVertexes = false;
        }

      double dist = einfo.length_before + dist_edge_v0;
      if (!best || (ref &&
                    ref.length_on_route - accuracy_rad < dist && // is it along route?
                    // consider to improve only if on the edge. otherwise
                    // turns will always prefer older edge
                    betweenVertexes &&
                    // take the point closer to the origin only if
                    // it is significantly closer
                    (best.length_on_route - dist) > 2*REF_POINT_ADD_MARGIN*accuracy_rad))
        {
          // update to the current estimate
          best.length_on_route = dist;
          best.point = pr;
          best.bearing = einfo.bearing;
          best.maneuver = einfo.maneuver;
        }
    }

  // whether we found the point on route and whether it was in expected direction
  bool on_route = ((bool)best && (!ref || ref.length_on_route - accuracy_rad < best.length_on_route));

  if (on_route)
    {
      best.accuracy = accuracy_rad;
      m_last_distance_along_route_m = S2Earth::RadiansToMeters(best.length_on_route);
      m_distance_to_route_m = 0;
      m_offroad_count = 0;

      SET(bearing, best.bearing);

      const Maneuver &man = m_maneuvers[best.maneuver];
      m_last_duration_along_route = man.duration_on_route;
      if (man.length > 0)
        m_last_duration_along_route +=
            (best.length_on_route - man.length_on_route) / man.length * man.duration;

      SET(destDist, distanceToStr(m_route_length_m - m_last_distance_along_route_m));
      SET(destTime, timeToStr(m_route_duration - m_last_duration_along_route));

      QTime time = QTime::currentTime().addSecs(m_route_duration - m_last_duration_along_route);
      SET(destEta, QLocale::system().toString(time, QLocale::ShortFormat));

      if (best.maneuver+1 < m_maneuvers.size())
        {
          const Maneuver &next = m_maneuvers[best.maneuver+1];
          const double mdist = S2Earth::RadiansToMeters(next.length_on_route - best.length_on_route);
          const double mtime = next.duration_on_route - m_last_duration_along_route;
          SET(manDist, distanceToStr(mdist));
          SET(manTime, timeToStr(mtime));
          SET(icon, next.icon);
          SET(narrative, next.narrative);
          if (m_running && (mdist < 500 || mtime < 300)) { SET(sign, next.sign); }
          else SET(sign, QVariantMap());
          SET(street, next.street);
        }

      // handle reference points
      if (!ref || // add the first reference point
          (best.length_on_route - m_points.back().length_on_route) / best.accuracy > REF_POINT_ADD_MARGIN)
        m_points.push_back(best);

      if ( m_points.size() > NUMBER_OF_REF_POINTS ||
           (m_points.size() > 0 && m_points.front().accuracy/2 > best.accuracy) )
        m_points.pop_front();

      // emit signals
      emit progressChanged();
      SET(onRoad, m_points.size() >= NUMBER_OF_REF_POINTS);

      qDebug() << "ON ROUTE:" << m_route_length_m - S2Earth::RadiansToMeters(std::max(0.0,best.length_on_route)) << "km left" << m_points.size();
    }
  else
    {
      S2ClosestEdgeQuery query(m_index.get());
      query.mutable_options()->set_max_results(1);
      m_distance_to_route_m = S2Earth::RadiansToMeters(query.GetDistance(&target).radians());
      if (m_offroad_count <= MAX_OFFROAD_COUNTS) m_offroad_count++;

//      qDebug() << "OFF ROUTE:" << m_distance_to_route_m << "m to route;"
//               << m_route_length_m - m_last_distance_along_route_m << "m left"
//               << m_offroad_count;

      // wipe history used to track direction on route if we are off the route
      if (m_offroad_count > MAX_OFFROAD_COUNTS)
        {
          m_points.clear();
        }

      SET(onRoad, false);
    }

  qDebug() << "\n";
}


void Navigator::setRoute(QVariantMap m)
{
  const double accuracy_m = 0.1;
  const double accuracy = S2Earth::MetersToRadians(accuracy_m);

  // copy route coordinates
  QVariantList x = m.value("x").toList();
  QVariantList y = m.value("y").toList();
  if (x.length() != y.length())
    {
      qWarning() << "Route given by inconsistent lists: " << x.length() << " " << y.length();
      clearRoute();
      return;
    }

  // cleanup
  m_route.clear();
  m_edges.clear();
  m_points.clear();
  m_maneuvers.clear();

  // clear distance traveled only if not running
  // that will keep progress intact on rerouting
  if (!m_running) m_distance_traveled_m = 0;

  // set global vars
  m_mode = m.value("mode", "car").toString();
  qDebug() << "Mode" << m_mode;

  // route
  m_route.reserve(x.length());
  for (int i=0; i < x.length(); ++i)
    {
      QGeoCoordinate c(y[i].toDouble(), x[i].toDouble());
      // avoid the same point entered twice (observed with MapQuest)
      if (i == 0 || c.distanceTo(m_route.back()) > accuracy_m)
        m_route.append(c);
    }
  emit routeChanged();

  std::vector<S2LatLng> coor;
  coor.reserve(x.length());
  for (QGeoCoordinate c: m_route)
    coor.push_back(S2LatLng::FromDegrees(c.latitude(), c.longitude()));

  m_polyline.reset(new S2Polyline(coor));

  // fill index
  m_index.reset(new MutableS2ShapeIndex);

  // determine each edge length
  int shape_id = m_index->Add(std::unique_ptr<S2Shape>(new S2Polyline::Shape(m_polyline.get())));
  const S2Shape *shape = m_index->shape(shape_id);
  double route_length = 0.0;
  for (int i=0; i < shape->num_edges(); ++i)
    {
      EdgeInfo edge;
      edge.length = S1ChordAngle(shape->edge(i).v0, shape->edge(i).v1).radians();
      edge.length_before = route_length;
      edge.bearing = S2Earth::GetInitialBearing(S2LatLng(shape->edge(i).v0), S2LatLng(shape->edge(i).v1)).degrees();
      m_edges.push_back(edge);
      route_length += edge.length;
    }

  m_route_length_m = S2Earth::RadiansToMeters(route_length);

  // fill maneuvers
  QVariantList man = m.value("maneuvers").toList();
  int edge_ind = 0;
  double length_on_route = 0;
  double duration_on_route = 0;
  for (int mind = 0; mind < man.length(); ++mind)
    {
      QVariantMap mc = man[mind].toMap();
      S2Point end;
      bool end_available = false;
      if (mind < man.length()-1)
        {
          QVariantMap mn = man[mind+1].toMap();
          end = S2LatLng::FromDegrees( mn.value("y").toDouble(), mn.value("x").toDouble() ).ToPoint();
          end_available = true;
        }

      double man_length = 0.0;
      for (; edge_ind < shape->num_edges() &&
             (!end_available || shape->edge(edge_ind).v0.Angle(end) > accuracy);
           ++edge_ind)
        {
          EdgeInfo &edge = m_edges[edge_ind];
          man_length += edge.length;
          edge.maneuver = mind;
        }

      Maneuver man(mc);
      man.duration_on_route = duration_on_route;
      man.length = man_length;
      man.length_on_route = length_on_route;
      m_maneuvers.push_back(man);
      length_on_route += man_length;
      duration_on_route += man.duration;

      qDebug() << "Maneuver" << mind << "Length" << S2Earth::RadiansToKm(man.length) << "m  Duration"
               << man.duration << "s  Speed" << S2Earth::RadiansToKm(man.length)/std::max(man.duration, 0.1)*3600 << "km/h" << "\n"
               << man.duration_on_route << "s / " << distanceToStr(S2Earth::RadiansToMeters(man.length_on_route))
               << man.icon << man.narrative << man.sign << man.street << "\n";
    }

  m_route_duration = duration_on_route;

  SET(totalDist, distanceToStr(m_route_length_m));
  SET(totalTime, timeToStr(m_route_duration));
}


void Navigator::setUnits(QString u)
{
  m_units = u;
  emit unitsChanged();
}

double Navigator::progress() const
{
  qDebug() << "P" << m_distance_traveled_m << m_route_length_m << m_last_distance_along_route_m
           << m_distance_traveled_m / std::max(1.0, m_distance_traveled_m + m_route_length_m - m_last_distance_along_route_m);
  return m_distance_traveled_m / std::max(1.0, m_distance_traveled_m + m_route_length_m - m_last_distance_along_route_m);
}

void Navigator::setRunning(bool r)
{
  if (!m_index && r)
    {
      qCritical() << "Navigator: Cannot start routing without route. Fix the caller.";
      r = false;
    }
  m_running = r;
  emit runningChanged();
}

static QString n2Str(double n, int roundDig=2)
{
  double rd = std::pow(10, roundDig);
  return QString("%L1").arg( round(n/rd) * rd );
}

static QString distanceToStr_american(double feet, bool condence)
{
  QString unit;
  if (feet > 1010)
    {
      unit = condence ? QCoreApplication::translate("", "mi") : QCoreApplication::translate("", "miles");
      return QString("%1 %2").arg(n2Str(feet/5280, feet > 5280 ? 0 : -1)).arg(unit);
    }
  unit = condence ? QCoreApplication::translate("", "ft") : QCoreApplication::translate("", "feet");
  return QString("%1 %2").arg(n2Str(feet, feet > 150 ? 2 : 1)).arg(unit);
}

static QString distanceToStr_british(double yard, bool condence)
{
  QString unit;
  if (yard > 1010)
    {
      unit = condence ? QCoreApplication::translate("", "mi") : QCoreApplication::translate("", "miles");
      return QString("%1 %2").arg(n2Str(yard/1760, yard > 1760 ? 0 : -1)).arg(unit);
    }
  unit = condence ? QCoreApplication::translate("", "yd") : QCoreApplication::translate("", "yards");
  return QString("%1 %2").arg(n2Str(yard, yard > 150 ? 2 : 1)).arg(unit);
}

static QString distanceToStr_metric(double meters, bool condence)
{
  QString unit;
  if (meters > 1000)
    {
      unit = condence ? QCoreApplication::translate("", "km") : QCoreApplication::translate("", "kilometers");
      return QString("%1 %2").arg(n2Str(meters/1000, 0)).arg(unit);
    }
  unit = condence ? QCoreApplication::translate("", "m") : QCoreApplication::translate("", "meters");
  return QString("%1 %2").arg(n2Str(meters, meters > 150 ? 2 : 1)).arg(unit);
}

QString Navigator::distanceToStr(double meters, bool condence) const
{
  if (m_units == QLatin1String("american"))
    return distanceToStr_american(3.28084 * meters, condence);
  if (m_units == QLatin1String("british"))
    return distanceToStr_british(1.09361 * meters, condence);
  return distanceToStr_metric(meters, condence);
}

QString Navigator::timeToStr(double seconds) const
{
  int hours = int(seconds / 3600);
  int minutes = round((seconds - hours*3600)/60);
  return hours > 0 ? QCoreApplication::translate("", "%1 h %2 min").arg(hours).arg(minutes) :
                     QCoreApplication::translate("", "%2 min").arg(minutes);
}
