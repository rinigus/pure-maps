#ifndef MANEUVERMODEL_H
#define MANEUVERMODEL_H

#include <QAbstractListModel>
#include <QObject>

#include <vector>

#include "maneuver.h"

class ManeuverModel : public QAbstractListModel
{
  Q_OBJECT

  enum RoleNames { CoordinateRole = Qt::UserRole + 1,
                   DurationRole, IconRole, NameRole,
                   LengthRole, NarrativeRole,
                   ArriveRole, DepartRole,
                   SignRole };

public:
  ManeuverModel();

  QHash<int, QByteArray> roleNames() const override;
  QVariant data(const QModelIndex &index, int role) const override;
  int rowCount(const QModelIndex &parent = QModelIndex()) const override;

  void clear();
  void setManeuvers(const std::vector<Maneuver> &maneuvers);

  Q_INVOKABLE QVariantList coordinates() const;
  Q_INVOKABLE QStringList names() const;

private:
  const std::vector<Maneuver> *m_maneuvers{nullptr};
};

#endif // MANEUVERMODEL_H
