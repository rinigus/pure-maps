#include "maneuvermodel.h"

ManeuverModel::ManeuverModel()
{
}

void ManeuverModel::clear()
{
  beginResetModel();
  m_maneuvers.clear();
  endResetModel();
}

void ManeuverModel::setManeuvers(const std::vector<Maneuver> &maneuvers)
{
  beginResetModel();
  m_maneuvers = maneuvers;
  endResetModel();
}

QHash<int, QByteArray> ManeuverModel::roleNames() const
{
  return {
      { RoleNames::CoordinateRole, QByteArrayLiteral("coordinate") },
      { RoleNames::DurationRole, QByteArrayLiteral("duration") },
      { RoleNames::IconRole, QByteArrayLiteral("icon") },
      { RoleNames::LengthRole, QByteArrayLiteral("length") },
      { RoleNames::NarrativeRole, QByteArrayLiteral("narrative") },
      { RoleNames::ArriveRole, QByteArrayLiteral("arrive") },
      { RoleNames::DepartRole, QByteArrayLiteral("depart") },
      { RoleNames::SignRole, QByteArrayLiteral("sign") }
    };
}

QVariant ManeuverModel::data(const QModelIndex &index, int role) const
{
  if (!index.isValid() || index.row() < 0 || index.row() >= m_maneuvers.size())
    return {};

  const Maneuver &mc = m_maneuvers[index.row()];
  switch (role) {
    case RoleNames::CoordinateRole:
      return QVariant::fromValue(mc.coordinate);
    case RoleNames::DurationRole:
      return mc.duration_txt;
    case RoleNames::IconRole:
      return mc.icon;
    case RoleNames::LengthRole:
      return mc.length_txt;
    case RoleNames::NarrativeRole:
      return mc.narrative;
    case RoleNames::ArriveRole:
      return mc.instArrive;
    case RoleNames::DepartRole:
      return mc.instDepart;
    case RoleNames::SignRole:
      return mc.sign;
    }

  return {};
}

int ManeuverModel::rowCount(const QModelIndex &parent) const
{
  return parent.isValid() ? 0 : m_maneuvers.size();
}
