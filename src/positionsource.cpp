#include "positionsource.h"

#include <QDebug>

#include <algorithm>

// use var without m_ prefix
#define SET(var, value) { auto t=(value); if (m_##var != t) { m_##var=t; /*qDebug() << "Emit " #var;*/ emit var##Changed(); } }

// use var without m_ prefix
#define SETWITHVALID(var, value, valid) { \
  if (valid) { SET(var, (value)); SET(var##Valid, valid); } \
  else { SET(var##Valid, valid); SET(var, (value)); } }

#define SETWITHNANCHECK(var, value) SETWITHVALID(var, value, !qIsNaN(value))

PositionSource::PositionSource(QObject *parent) : QObject(parent)
{
  m_source = QGeoPositionInfoSource::createDefaultSource(this);
  if (!m_source)
    {
      qWarning() << "Failed to acquire QGeoPositionInfoSource";
      return;
    }

  qDebug() << "Acquired QGeoPositionInfoSource:" << m_source->sourceName();

  connect(m_source, &QGeoPositionInfoSource::positionUpdated,
          this, &PositionSource::onPositionUpdated);
  connect(m_source, SIGNAL(error(QGeoPositionInfoSource::Error)),
          this, SLOT(onError(QGeoPositionInfoSource::Error)));
  connect(m_source, &QGeoPositionInfoSource::updateTimeout,
          this, &PositionSource::onUpdateTimeout);

  m_timer.setInterval(1000);
  connect(&m_timer, &QTimer::timeout, this, &PositionSource::onTestingTimer);
}

void PositionSource::setActive(bool active)
{
  if (!m_source || active==m_active) return;

  if (active) m_source->startUpdates();
  else m_source->stopUpdates();

  m_active = active;
  emit activeChanged();
}

void PositionSource::setPosition(const QGeoPositionInfo &info)
{
  qDebug() << "Position update:" << info;

  SETWITHVALID(coordinate, info.coordinate(),
               info.isValid() &&
               !qIsNaN(info.coordinate().latitude()) &&
               !qIsNaN(info.coordinate().longitude()));

  SETWITHNANCHECK(direction, info.attribute(QGeoPositionInfo::Direction));
  SETWITHNANCHECK(horizontalAccuracy, info.attribute(QGeoPositionInfo::HorizontalAccuracy));
  SETWITHNANCHECK(speed, info.attribute(QGeoPositionInfo::GroundSpeed));
  SET(timestamp, info.timestamp());

  setReady(m_coordinateValid);
  SET(accurate,
      m_ready && m_coordinateValid && m_horizontalAccuracyValid &&
      m_horizontalAccuracy < 25);

  SET(updateInterval, std::max(m_source->updateInterval(), m_source->minimumUpdateInterval()));

  emit positionUpdated();
}

void PositionSource::setReady(bool ready)
{
  SET(ready,ready);
  if (!ready) SET(accurate, false);
}

void PositionSource::setStickyDirection(bool stickyDirection)
{
  SET(stickyDirection, stickyDirection);
}

void PositionSource::setTestingCoordinate(QGeoCoordinate testingCoordinate)
{
  SET(testingCoordinate, testingCoordinate);
}

void PositionSource::setTestingMode(bool testingMode)
{
  SET(testingMode, testingMode);
  if (m_testingMode) m_timer.start();
  else m_timer.stop();
}

void PositionSource::onError(QGeoPositionInfoSource::Error positioningError)
{
  qWarning() << "Positioning error:" << positioningError;
  setReady(false);
}

void PositionSource::onTestingTimer()
{
  if (!m_testingMode) return;
  QGeoPositionInfo info;
  info.setCoordinate(m_testingCoordinate);
  info.setAttribute(QGeoPositionInfo::HorizontalAccuracy, 10);
  info.setTimestamp(QDateTime::currentDateTime());
  setPosition(info);
}

void PositionSource::onUpdateTimeout()
{
  qWarning() << "Positioning update timeout";
  setReady(false);
}

void PositionSource::onPositionUpdated(const QGeoPositionInfo &info)
{
  if (!m_testingMode) setPosition(info);
}