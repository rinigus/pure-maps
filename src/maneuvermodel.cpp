#include "maneuvermodel.h"

ManeuverModel::ManeuverModel()
{
}

void ManeuverModel::clear()
{
  beginResetModel();
  m_maneuvers = nullptr;
  endResetModel();
}

void ManeuverModel::setManeuvers(const std::vector<Maneuver> &maneuvers)
{
  beginResetModel();
  m_maneuvers = &maneuvers;
  endResetModel();
}

QHash<int, QByteArray> ManeuverModel::roleNames() const
{
  return {
      { RoleNames::CoordinateRole, QByteArrayLiteral("coordinate") },
      { RoleNames::DurationRole, QByteArrayLiteral("duration") },
      { RoleNames::IconRole, QByteArrayLiteral("icon") },
      { RoleNames::NameRole, QByteArrayLiteral("name") },
      { RoleNames::LengthRole, QByteArrayLiteral("length") },
      { RoleNames::NarrativeRole, QByteArrayLiteral("narrative") },
      { RoleNames::ArriveRole, QByteArrayLiteral("arrive") },
      { RoleNames::DepartRole, QByteArrayLiteral("depart") },
      { RoleNames::SignRole, QByteArrayLiteral("sign") }
    };
}

QVariant ManeuverModel::data(const QModelIndex &index, int role) const
{
  if (!index.isValid() || index.row() < 0 ||
      !m_maneuvers ||
      (size_t)index.row() >= m_maneuvers->size())
    return {};

  const Maneuver &mc = (*m_maneuvers)[index.row()];
  switch (role) {
    case RoleNames::CoordinateRole:
      return QVariant::fromValue(mc.coordinate);
    case RoleNames::DurationRole:
      return mc.duration_txt;
    case RoleNames::IconRole:
      return mc.icon;
    case RoleNames::NameRole:
      return mc.name;
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
  return parent.isValid() || !m_maneuvers ? 0 : m_maneuvers->size();
}

QVariantList ManeuverModel::coordinates() const
{
  QVariantList cl;
  if (!m_maneuvers) return cl;
  cl.reserve(m_maneuvers->size());
  for (auto &m: *m_maneuvers)
    cl.push_back(QVariant::fromValue(m.coordinate));
  return cl;
}

QStringList ManeuverModel::names() const
{
  QStringList nl;
  if (!m_maneuvers) return nl;
  nl.reserve(m_maneuvers->size());
  for (auto &m: *m_maneuvers)
    nl.push_back(m.name);
  return nl;
}
