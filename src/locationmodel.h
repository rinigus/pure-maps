#ifndef LOCATIONMODEL_H
#define LOCATIONMODEL_H

#include <QAbstractListModel>
#include <QObject>
#include <QVariantList>

#include "location.h"

class LocationModel : public QAbstractListModel
{
  Q_OBJECT

  Q_PROPERTY(bool hasDestination READ hasDestination NOTIFY hasDestinationChanged)
  Q_PROPERTY(bool hasOrigin READ hasOrigin NOTIFY hasOriginChanged)

  enum RoleNames { DestinationRole = Qt::UserRole + 1,
                   OriginRole, FinalRole,
                   TextRole, XRole, YRole
                 };

public:

  LocationModel();

  // Model API
  QHash<int, QByteArray> roleNames() const override;
  QVariant data(const QModelIndex &index, int role) const override;
  int rowCount(const QModelIndex &parent = QModelIndex()) const override;

  // properties
  bool hasDestination() const { return m_hasDestination; }
  bool hasOrigin() const { return m_hasOrigin; }

  QVariantList list();

  // tests for destinations and waypoints
  void checkArrivalByPosition(const S2Point &point, double accuracy);
  void checkArrivalByRouteDistance(double length_on_route, double accuracy);
  bool hasMissedDest(double length_on_route, double accuracy); // true if missed

  // data model handling
  void append(const Location &location);
  void clear();
  void set(const QVariantList &locations);
  void set(const QList<Location> &locations);
  bool remove(int index);

signals:
  void hasDestinationChanged();
  void hasOriginChanged();
  void locationArrived(QString name, bool destination);

private:
  void dropCache();

private:
  QList<Location> m_locations;
  QVariantList m_locations_cached;

  bool m_hasDestination;
  bool m_hasOrigin;
  bool m_locations_cached_ready{false};
};

#endif // LOCATIONMODEL_H
