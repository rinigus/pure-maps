#include "navigator.h"

#include <QDebug>
#include <QGeoCoordinate>

#include <s2/s2closest_edge_query.h>
#include <s2/s2earth.h>
#include <vector>

#define MAX_ROUTE_INTERSECTIONS 5  // Maximal number of route intersections with itself
#define REF_POINT_ADD_MARGIN    10 // Add next reference point along the route when it is that far away from the last one (relative to accuracy)
#define NUMBER_OF_REF_POINTS    2  // how many points to keep as a reference
#define MAX_OFFROAD_COUNTS      5  // times position was updated and point was off the route (counted in a sequence)

Navigator::Navigator(QObject *parent) : QObject(parent)
{

}

void Navigator::clearRoute()
{
  m_polyline.release();
  m_route.clear();
  routeChanged();
}

void Navigator::setPosition(const QGeoCoordinate &c, double horizontalAccuracy, bool valid)
{
  if (!m_polyline) return;

  qDebug() << c << horizontalAccuracy << valid;

  double accuracy_rad = S2Earth::MetersToRadians(20); //horizontalAccuracy));
  S1ChordAngle accuracy = S1ChordAngle::Radians(accuracy_rad);
  S2Point point = S2LatLng::FromDegrees(c.latitude(), c.longitude()).ToPoint();
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
      if ( dist_edge < dist_edge_v0 )
        {
          pr = edge.v1;
          dist_edge_v0 = dist_edge;
          qDebug() << "Vertex 1";
        }
      else if ( dist_edge < dist_edge_v1 )
        {
          pr = edge.v0;
          dist_edge_v0 = 0;
          qDebug() << "Vertex 0";
        }

      double dist = einfo.length_before + dist_edge_v0;
      if (!best || (ref &&  ref.length_on_route - accuracy_rad < dist &&
                    best.length_on_route-ref.length_on_route > dist-ref.length_on_route ))
        {
          // update to the current estimate
          best.length_on_route = dist;
          best.point = pr;
          qDebug() << "New best ref point:" << dist;
        }

//      qDebug() << result.shape_id() << result.edge_id()
//               << S2Earth::RadiansToKm(m_route_length - dist) << S2Earth::RadiansToMeters(result.distance().radians())
//               << S2Earth::RadiansToMeters(dist_edge_v0.radians()) << S2Earth::RadiansToMeters(dist_edge_v1.radians()) << S2Earth::RadiansToMeters(dist_edge.radians())
//               << (dist_edge_v0 < dist_edge && dist_edge_v1 < dist_edge);

    }

  // whether we found the point on route and whether it was in expected direction
  bool on_route = ((bool)best && (!ref || ref.length_on_route - accuracy_rad < best.length_on_route));

  if (on_route)
    {
      best.accuracy = accuracy_rad;
      m_last_distance_along_route_m = S2Earth::RadiansToMeters(best.length_on_route);
      m_distance_to_route_m = 0;
      m_offroad_count = 0;

      if (!ref || // add the first reference point
          (best.length_on_route - m_points.back().length_on_route) / best.accuracy > REF_POINT_ADD_MARGIN)
        {
          m_points.push_back(best);
          qDebug() << "NEW REFERENCE POINT";
        }

      if ( m_points.size() > NUMBER_OF_REF_POINTS ||
           (m_points.size() > 0 && m_points.front().accuracy/2 > best.accuracy) )
        m_points.pop_front();

      qDebug() << "ON ROUTE:" << m_route_length_m - S2Earth::RadiansToMeters(std::max(0.0,best.length_on_route)) << "km left" << m_points.size();
    }
  else
    {
      S2ClosestEdgeQuery query(m_index.get());
      query.mutable_options()->set_max_results(1);
      m_distance_to_route_m = S2Earth::RadiansToMeters(query.GetDistance(&target).radians());
      if (m_offroad_count <= MAX_OFFROAD_COUNTS) m_offroad_count++;

      qDebug() << "OFF ROUTE:" << m_distance_to_route_m << "m to route;"
               << m_route_length_m - m_last_distance_along_route_m << "m left"
               << m_offroad_count;

      // wipe history if we are off the route
      if (m_offroad_count > MAX_OFFROAD_COUNTS)
        m_points.clear();
    }

  qDebug() << "\n";
}

void Navigator::setRoute(QVariantMap m)
{
  // copy route coordinates
  QVariantList x = m.value("x").toList();
  QVariantList y = m.value("y").toList();
  if (x.length() != y.length())
    {
      qWarning() << "Route given by inconsistent lists: " << x.length() << " " << y.length();
      return;
    }

  m_route.clear();
  m_edges.clear();
  m_points.clear();

  m_route.reserve(x.length());
  for (int i=0; i < x.length(); ++i)
    {
      QGeoCoordinate c(y[i].toDouble(), x[i].toDouble());
      m_route.append(c);
    }
  routeChanged();

  std::vector<S2LatLng> coor;
  coor.reserve(x.length());
  for (QGeoCoordinate c: m_route)
    coor.push_back(S2LatLng::FromDegrees(c.latitude(), c.longitude()));

  m_polyline.reset(new S2Polyline(coor));
  qDebug() << "Route length:" << S2Earth::RadiansToKm( m_polyline->GetLength().radians() ) << "km";

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
      m_edges.push_back(edge);
      route_length += edge.length;
    }

  m_route_length_m = S2Earth::RadiansToMeters(route_length);

  qDebug() << "Route length 2:" << m_route_length_m / 1e3 << "km";
}
