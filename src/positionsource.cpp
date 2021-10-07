#include "positionsource.h"

#include <QDebug>

#include <algorithm>
#include <math.h>

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
  if (m_source->sourceName() == "geoclue2")
    {
      m_directionCalculate = true;
      qInfo() << "Calculate direction using a sequence of coordinates";
    }

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

  SETWITHNANCHECK(horizontalAccuracy, info.attribute(QGeoPositionInfo::HorizontalAccuracy));
  SETWITHNANCHECK(speed, info.attribute(QGeoPositionInfo::GroundSpeed));
  SET(timestamp, info.timestamp());

  // update and calculate direction if needed
  if (m_directionCalculate)
    {
      if (m_horizontalAccuracyValid && m_coordinateValid)
        {
          float threshold = m_horizontalAccuracy;
          if (m_history.empty()) m_history.push_back(m_coordinate);
          QGeoCoordinate &last = m_history.back();
          if (last.distanceTo(m_coordinate) > threshold)
            {
              m_history.push_back(m_coordinate);
              if (m_history.size() > 3) m_history.removeFirst();
              double scos = 0;
              double ssin = 0;
              for (int i=0; i < m_history.size()-1; ++i)
                {
                  double az = m_history[i].azimuthTo(m_history[i+1]);
                  double s, c;
                  sincos(az / 180 * M_PI, &s, &c);
                  scos += c;
                  ssin += s;
                }
              int dir = int(round(atan2(ssin, scos) / M_PI * 180));
              while (dir < 0) dir += 360;

              SET(direction, dir);
              SET(directionValid, true);
              m_directionTimestamp = QTime::currentTime();
            }
        }

      // reset direction if it has not been updated for a while (60s)
      if (!m_stickyDirection && m_directionValid && m_directionTimestamp.elapsed() > 60000)
        {
          m_history.clear();
          SET(directionValid, false);
        }
    }
  else
    {
      // use direction as provided by the device
      float dir = info.attribute(QGeoPositionInfo::Direction);
      if (!qIsNaN(dir) || !m_stickyDirection ||
          (m_coordinateValid && m_directionLastPositionValid.distanceTo(m_coordinate) > 10 /*meters*/))
        {
          SETWITHNANCHECK(direction, dir);
          if (m_directionValid && m_coordinateValid)
            m_directionLastPositionValid = m_coordinate;
        }
    }

  // set overall state vars
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
