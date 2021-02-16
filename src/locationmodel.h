#ifndef LOCATIONMODEL_H
#define LOCATIONMODEL_H

#include <QAbstractListModel>
#include <QObject>
#include <QVariantList>

#include "location.h"

class Navigator;

class LocationModel : public QAbstractListModel
{
  Q_OBJECT

  Q_PROPERTY(bool    hasDestination READ hasDestination NOTIFY hasDestinationChanged)
  Q_PROPERTY(bool    hasOrigin READ hasOrigin NOTIFY hasOriginChanged)
  Q_PROPERTY(bool    nextLocationDestination READ nextLocationDestination NOTIFY nextLocationDestinationChanged)
  Q_PROPERTY(QString nextLocationDist READ nextLocationDist NOTIFY nextLocationDistChanged)
  Q_PROPERTY(QString nextLocationEta READ nextLocationEta NOTIFY nextLocationEtaChanged)
  Q_PROPERTY(QString nextLocationTime READ nextLocationTime NOTIFY nextLocationTimeChanged)

  enum RoleNames { DestinationRole = Qt::UserRole + 1,
                   OriginRole, FinalRole,
                   TextRole, XRole, YRole,
                   DistRole, TimeRole, EtaRole,
                   LegDistRole, LegTimeRole,
                   ArrivedRole, ArrivedAtRole,
                   ActiveIndexRole
                 };

public:

  LocationModel(Navigator *navigator);

  // Model API
  QHash<int, QByteArray> roleNames() const override;
  QVariant data(const QModelIndex &index, int role) const override;
  int rowCount(const QModelIndex &parent = QModelIndex()) const override;

  // properties
  bool hasDestination() const { return m_hasDestination; }
  bool hasOrigin() const { return m_hasOrigin; }
  bool    nextLocationDestination() const { return m_nextLocationDestination; }
  QString nextLocationDist() const { return m_nextLocationDist; }
  QString nextLocationEta() const { return m_nextLocationEta; }
  QString nextLocationTime() const { return m_nextLocationTime; }


  QVariantList list();

  // tests for destinations and waypoints
  void checkArrivalByPosition(const S2Point &point, double accuracy);
  void checkArrivalByRouteDistance(double length_on_route, double accuracy);
  bool hasMissedDest(double length_on_route, double accuracy); // true if missed

  void fillLegInfo();
  void updateRoutePosition(double last_distance_along_route_m,
                           double last_duration_along_route);
  void updateEta(double last_duration_along_route);


  // data model handling
  void append(const Location &location);
  void clear();
  void set(const QVariantList &locations);
  void set(const QList<Location> &locations, bool merge);
  bool remove(int index);

signals:
  void hasDestinationChanged();
  void hasOriginChanged();
  void locationArrived(QString name, bool destination);
  void nextLocationDestinationChanged();
  void nextLocationDistChanged();
  void nextLocationEtaChanged();
  void nextLocationTimeChanged();

private:
  void dropCache();
  void updateNextLocationInfo();

private:
  QList<Location> m_locations;
  QList<Location> m_locations_arrived;
  QVariantList m_locations_cached;
  Navigator *m_navigator;

  bool m_hasDestination;
  bool m_hasOrigin;
  bool m_locations_cached_ready{false};
  bool    m_nextLocationDestination{false};
  QString m_nextLocationDist;
  QString m_nextLocationEta;
  QString m_nextLocationTime;
};

#endif // LOCATIONMODEL_H
