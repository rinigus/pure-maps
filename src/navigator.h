#ifndef NAVIGATOR_H
#define NAVIGATOR_H


#include <QGeoCoordinate>
#include <QHash>
#include <QLocale>
#include <QObject>
#include <QTime>
#include <QTimer>
#include <QTranslator>
#include <QVariantList>
#include <QVariantMap>

#include <deque>
#include <memory>
#include <s2/mutable_s2shape_index.h>
#include <s2/s2polygon.h>

#include "maneuver.h"
#include "maneuvermodel.h"
#include "prompt.h"

class Navigator : public QObject
{
  Q_OBJECT

  Q_PROPERTY(bool    alongRoute READ alongRoute NOTIFY alongRouteChanged)
  Q_PROPERTY(QString destDist READ destDist NOTIFY destDistChanged)
  Q_PROPERTY(QString destEta READ destEta NOTIFY destEtaChanged)
  Q_PROPERTY(QString destTime READ destTime NOTIFY destTimeChanged)
  Q_PROPERTY(double  direction READ direction NOTIFY directionChanged)
  Q_PROPERTY(bool    directionValid READ directionValid NOTIFY directionValidChanged)
  Q_PROPERTY(QString icon READ icon NOTIFY iconChanged)
  Q_PROPERTY(QString language READ language NOTIFY languageChanged)
  Q_PROPERTY(QVariantList locations READ locations NOTIFY locationsChanged)
  Q_PROPERTY(QString manDist READ manDist NOTIFY manDistChanged)
  Q_PROPERTY(QString manTime READ manTime NOTIFY manTimeChanged)
  Q_PROPERTY(QString mode READ mode NOTIFY modeChanged)
  Q_PROPERTY(QString narrative READ narrative NOTIFY narrativeChanged)
  Q_PROPERTY(QString nextIcon READ nextIcon NOTIFY nextIconChanged)
  Q_PROPERTY(QString nextManDist READ nextManDist NOTIFY nextManDistChanged)
  Q_PROPERTY(int     progress READ progress NOTIFY progressChanged)
  Q_PROPERTY(int     roundaboutExit READ roundaboutExit NOTIFY roundaboutExitChanged)
  Q_PROPERTY(bool    running READ running WRITE setRunning NOTIFY runningChanged)
  Q_PROPERTY(QVariantMap sign READ sign NOTIFY signChanged)
  Q_PROPERTY(QString street READ street NOTIFY streetChanged)
  Q_PROPERTY(QString totalDist READ totalDist NOTIFY totalDistChanged)
  Q_PROPERTY(QString totalTime READ totalTime NOTIFY totalTimeChanged)
  Q_PROPERTY(QString units READ units WRITE setUnits NOTIFY unitsChanged)

  Q_PROPERTY(QVariantList route READ route NOTIFY routeChanged)
  Q_PROPERTY(ManeuverModel* maneuvers READ maneuvers)

public:
  explicit Navigator(QObject *parent = nullptr);

  // current state
  bool    alongRoute() const { return m_alongRoute; }
  QString destDist() const { return m_destDist; }
  QString destEta() const { return m_destEta; }
  QString destTime() const { return m_destTime; }
  double  direction() const { return m_direction; }
  bool    directionValid() const { return m_directionValid; }
  QString icon() const { return m_icon; }
  QString language() const { return m_language; }
  QVariantList locations() const;
  QString manDist() const { return m_manDist; }
  QString manTime() const { return m_manTime; }
  QString mode() const { return m_mode; }
  QString narrative() const { return m_narrative; }
  QString nextIcon() const { return m_nextIcon; }
  QString nextManDist() const { return m_nextManDist; }
  double  progress() const { return m_progress; }
  int     roundaboutExit() const { return m_roundaboutExit; }
  QVariantMap sign() const { return m_sign; }
  QString street() const { return m_street; }
  QString totalDist() const { return m_totalDist; }
  QString totalTime() const { return m_totalTime; }


  Q_INVOKABLE void setPosition(const QGeoCoordinate &c, double horizontalAccuracy, bool valid);

  // route
  Q_INVOKABLE void clearRoute();
  QVariantList route() const { return m_route; }
  Q_INVOKABLE void setRoute(QVariantMap m);

  ManeuverModel* maneuvers() { return &m_maneuvers_model; }

  bool running () const { return m_running; }
  void setRunning(bool r);

  QString units() const { return m_units; }
  void setUnits(QString u);

  // standard prompts
  Q_INVOKABLE void prepareStandardPrompts();
  Q_INVOKABLE void prompt(const QString key);

signals:
  void alongRouteChanged();
  void destDistChanged();
  void destEtaChanged();
  void destTimeChanged();
  void directionChanged();
  void directionValidChanged();
  void iconChanged();
  void languageChanged();
  void locationsChanged();
  void manDistChanged();
  void manTimeChanged();
  void modeChanged();
  void narrativeChanged();
  void nextIconChanged();
  void nextManDistChanged();
  void progressChanged();
  void rerouteRequest();
  void roundaboutExitChanged();
  void routeChanged();
  void runningChanged();
  void signChanged();
  void streetChanged();
  void totalDistChanged();
  void totalTimeChanged();
  void unitsChanged();
  void promptPrepare(QString text, bool preserve);
  void promptPlay(QString text);
  void navigationEnded();

protected:
  QString distanceToStr(double meters, bool condence=true) const;
  QString distanceToStr_american(double feet, bool condence) const;
  QString distanceToStr_british(double yard, bool condence) const;
  QString distanceToStr_metric(double meters, bool condence) const;
  QString n2Str(double n, int roundDig=2) const;

  QString timeToStr(double seconds) const;
  double  distanceRounded(double meters) const;
  Prompt  makePrompt(const Maneuver &m, QString text, double dist_offset_m, double time_offset,
                     double speed_m, int importance, bool after=false) const;
  void resetPrompts();

  void setupTranslator();
  QString trans(const char *text) const;

  void updateEta();
  void updateProgress();

private:
  // Edges of the route
  struct EdgeInfo {
    double length;
    double length_before;
    double direction{0};
    size_t maneuver{0};
  };

  // Points from the past trajectory on route
  struct PointInfo {
    S2Point point;
    double accuracy;
    double direction{0};
    size_t maneuver{0};
    double length_on_route{-1};

    operator bool() const { return length_on_route > 0; }
  };

  // Location
  struct LocationInfo {
    S2Point point;
    double length_on_route;
    double distance_to_route;
    double latitude;
    double longitude;
    QString name;
  };

private:
  bool m_running{false};

  std::vector<EdgeInfo> m_edges;
  std::unique_ptr<MutableS2ShapeIndex> m_index;
  QString m_language{"en"};
  QLocale m_locale;
  QList<LocationInfo> m_locations;
  // if true, a location are considered passed only if
  // the trajectory went close to it. if false, just
  // distance along route determines if the location is passed
  bool m_locations_strict{false};
  std::vector<Maneuver> m_maneuvers;
  QString m_mode{"car"};
  std::deque<PointInfo> m_points;
  std::vector<Prompt> m_prompts;
  QVariantList m_route;
  QTimer m_timer;
  QTranslator m_translator;

  double  m_last_accuracy{-1};
  S2Point m_last_point;
  bool m_last_point_initialized{false};

  // NB! All distances in Rad unless having suffix _m for Meters

  double m_route_length_m{-1};
  double m_route_duration{0};
  double m_distance_traveled_m{0};
  double m_last_distance_along_route_m{0};
  double m_last_duration_along_route{0};
  size_t m_last_prompt{0};
  double m_distance_to_route_m{-1};
  size_t m_offroad_count{0};
  QTime  m_reroute_request;

  bool    m_alongRoute{false};
  QString m_destDist;
  QString m_destEta;
  QString m_destTime;
  double  m_direction{0};
  bool    m_directionValid{false};
  QString m_icon;
  QString m_manDist;
  QString m_manTime;
  QString m_narrative;
  QString m_nextIcon;
  QString m_nextManDist;
  bool    m_precision_insufficient{false};
  int     m_progress{0};
  int     m_roundaboutExit{0};
  QVariantMap m_sign;
  QString m_street;
  QString m_totalDist;
  QString m_totalTime;

  QString m_units{QLatin1String("metric")};

  QHash<QString, QString> m_std_prompts;
  ManeuverModel m_maneuvers_model;
};

#endif // NAVIGATOR_H
