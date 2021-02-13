#include "location.h"

template <typename T>
static void _varFiller(T &var, const QVariantMap &l, QString key)
{
  if (l.contains(key) && l[key].canConvert<T>())
    var=l[key].value<T>();
}

Location::Location(const QVariantMap &lm)
{
  // setting minimal location info
  _varFiller(name, lm, QStringLiteral("text"));
  _varFiller(longitude, lm, QStringLiteral("x"));
  _varFiller(latitude, lm, QStringLiteral("y"));
  _varFiller(destination, lm, QStringLiteral("destination"));
}

