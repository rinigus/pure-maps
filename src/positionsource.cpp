#include "positionsource.h"

#include <QDebug>
#include <QDBusMessage>
#include <QJsonDocument>
#include <QJsonObject>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QVariantMap>

#include <algorithm>
#include <math.h>

#include "dbustracker.h"

// use var without m_ prefix
#define SET(var, value) { auto t=(value); if (m_##var != t) { m_##var=t; /*qDebug() << "Emit " #var;*/ emit var##Changed(); } }

// use var without m_ prefix
#define SETWITHVALID(var, value, valid) { \
  if (valid) { SET(var, (value)); SET(var##Valid, valid); } \
  else { SET(var##Valid, valid); SET(var, (value)); } }

#define SETWITHNANCHECK(var, value) SETWITHVALID(var, value, !qIsNaN(value))


#define MAPMATCHING_SERVICE "io.github.rinigus.OSMScoutServer"
#define MAPMATCHING_PATH    "/io/github/rinigus/OSMScoutServer/mapmatching"

PositionSource::PositionSource(QObject *parent) : QObject(parent)
{
  m_source = QGeoPositionInfoSource::createDefaultSource(this);
  if (!m_source)
    {
      qWarning() << "Failed to acquire QGeoPositionInfoSource";
      return;
    }

  qInfo() << "Acquired QGeoPositionInfoSource:" << m_source->sourceName();
  if (m_source->sourceName() == "geoclue2")
    {
      m_directionCalculate = true;
      qInfo() << "Calculate direction using a sequence of coordinates";
    }

  m_source->setPreferredPositioningMethods(QGeoPositionInfoSource::SatellitePositioningMethods);

  connect(m_source, &QGeoPositionInfoSource::positionUpdated,
          this, &PositionSource::onPositionUpdated);
  connect(m_source, SIGNAL(error(QGeoPositionInfoSource::Error)),
          this, SLOT(onError(QGeoPositionInfoSource::Error)));
  connect(m_source, &QGeoPositionInfoSource::updateTimeout,
          this, &PositionSource::onUpdateTimeout);

  // network
  connect(&m_networkManager, &QNetworkAccessManager::finished, this, &PositionSource::onNetworkFinished);

  // track map matching service
  DBusTracker::instance()->track(MAPMATCHING_SERVICE);
  connect(DBusTracker::instance(), &DBusTracker::serviceAppeared,
          this, &PositionSource::onMapMatchingServiceChanged);
  connect(DBusTracker::instance(), &DBusTracker::serviceDisappeared,
          this, &PositionSource::onMapMatchingServiceChanged);

  // timers
  m_timer.setInterval(1000);
  connect(&m_timer, &QTimer::timeout, this, &PositionSource::onTestingTimer);

  m_mapMatchingActivateTimer.setInterval(5000);
  m_mapMatchingActivateTimer.setSingleShot(false);
  connect(&m_mapMatchingActivateTimer, &QTimer::timeout, this, &PositionSource::onMapMatchingActivateTimer);
}

void PositionSource::setActive(bool active)
{
  if (!m_source || active==m_active) return;

  if (active) m_source->startUpdates();
  else
    {
      m_source->stopUpdates();
      stopMapMatching();
      checkMapMatchAvailable();
    }

  m_active = active;
  emit activeChanged();
}

void PositionSource::setPosition(const QGeoPositionInfo &info)
{
  SETWITHVALID(coordinateDevice, info.coordinate(),
               info.isValid() &&
               !qIsNaN(info.coordinate().latitude()) &&
               !qIsNaN(info.coordinate().longitude()));

  SETWITHNANCHECK(horizontalAccuracy, info.attribute(QGeoPositionInfo::HorizontalAccuracy));
  SETWITHNANCHECK(speed, info.attribute(QGeoPositionInfo::GroundSpeed));
  SET(timestamp, info.timestamp());

  // update and calculate direction if needed
  if (m_directionCalculate)
    {
      if (m_horizontalAccuracyValid && m_coordinateDeviceValid && m_horizontalAccuracy < 100)
        {
          float threshold = m_horizontalAccuracy;
          if (m_history.empty()) m_history.push_back(m_coordinateDevice);
          QGeoCoordinate &last = m_history.back();
          if (last.distanceTo(m_coordinateDevice) > threshold)
            {
              m_history.push_back(m_coordinateDevice);
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

              SET(directionDevice, dir);
              SET(directionDeviceValid, true);
              m_directionTimestamp = QTime::currentTime();
            }
        }

      // reset direction if it has not been updated for a while (60s)
      if (!m_stickyDirection && m_directionDeviceValid && m_directionTimestamp.elapsed() > 60000)
        {
          m_history.clear();
          SET(directionDeviceValid, false);
        }
    }
  else
    {
      // use direction as provided by the device
      float dir = info.attribute(QGeoPositionInfo::Direction);
      if (!qIsNaN(dir) || !m_stickyDirection ||
          (m_coordinateDeviceValid && m_directionLastPositionValid.distanceTo(m_coordinateDevice) > 10 /*meters*/))
        {
          SETWITHNANCHECK(directionDevice, dir);
          if (m_directionDeviceValid && m_coordinateDeviceValid)
            m_directionLastPositionValid = m_coordinateDevice;
        }
    }

  // call map matching update
  if (m_mapMatchingAvailable && m_coordinateDeviceValid && m_horizontalAccuracyValid)
    {
      // if call is in progress already, reset all map matching
      // vars and try to update again. It indicates that the map
      // matching is either not working or too slow
      if (m_mapMatchingCallInProgress)
        {
          qWarning() << "Position was updated faster than map matching found the location";
          resetMapMatchingValues();
        }

      m_mapMatchingCallInProgress = true;
      m_mapMatchingActive = true;
      auto reply = m_mapmatch->Update(m_mapMatchingMode,
                                      m_coordinateDevice.latitude(), m_coordinateDevice.longitude(),
                                      m_horizontalAccuracy);
      QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(reply, this);
      connect(watcher, &QDBusPendingCallWatcher::finished,
              this, &PositionSource::onMapMatchingUpdateFinished);
    }
  else
    stopMapMatching();

  // set overall state vars
  setReady(m_coordinateDeviceValid);
  SET(accurate,
      m_ready && m_coordinateDeviceValid && m_horizontalAccuracyValid &&
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

void PositionSource::onNetworkFinished(QNetworkReply *reply)
{
  // drop any reply
  reply->deleteLater();
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


///////////////////////////////////////////////
/// Map matching support
///

void PositionSource::setHasMapMatching(bool hasMapMatching)
{
  SET(hasMapMatching, hasMapMatching);

  if (!m_hasMapMatching)
    {
      if (m_mapmatch)
        {
          m_mapmatch->deleteLater();
          m_mapmatch = nullptr;
        }
    }
  else if (!m_mapmatch && m_hasMapMatching)
    {
      m_mapmatch = new OSMScoutMapMatch(MAPMATCHING_SERVICE,
                                        MAPMATCHING_PATH,
                                        QDBusConnection::sessionBus(), this);
      // connect signals
      connect(m_mapmatch, &OSMScoutMapMatch::ActiveChanged,
              this, &PositionSource::checkMapMatchAvailable);
    }

  checkMapMatchAvailable();
  resetMapMatchingValues();
}

void PositionSource::setMapMatchingMode(int mapMatchingMode)
{
  SET(mapMatchingMode, mapMatchingMode);
  checkMapMatchAvailable();
  resetMapMatchingValues();
  if (m_mapmatch)
    m_mapmatch->Reset(m_mapMatchingMode);
}

void PositionSource::checkMapMatchAvailable()
{
  bool want = (m_active && m_hasMapMatching && m_mapmatch && m_mapMatchingMode > 0);

  // if we don't need map matching, do not activate it via DBus
  // or network
  if (!want)
    {
      m_mapMatchingActivateTimer.stop();
      m_mapMatchingAvailable = false;
      resetMapMatchingValues();
      return;
    }

  // compose async call to request property value
  QDBusMessage methCall = QDBusMessage::createMethodCall(MAPMATCHING_SERVICE,
                                                         MAPMATCHING_PATH,
                                                         QLatin1String("org.freedesktop.DBus.Properties"),
                                                         QLatin1String("Get"));
  methCall << OSMScoutMapMatch::staticInterfaceName() << QLatin1String("Active");
  auto call = QDBusConnection::sessionBus().asyncCall(methCall);

  QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(call, this);
  connect(watcher, &QDBusPendingCallWatcher::finished,
          this, &PositionSource::onMapMatchingActiveFinished);
}

void PositionSource::onMapMatchingActiveFinished(QDBusPendingCallWatcher *watcher)
{
  QDBusPendingReply<QVariant> reply = *watcher;
  watcher->deleteLater();

  bool before = m_mapMatchingAvailable;
  m_mapMatchingAvailable = (!reply.isError() && reply.isValid() && reply.argumentAt<0>().toBool());
  if (before != m_mapMatchingAvailable)
    qInfo() << "Map matching active:" << m_mapMatchingAvailable;

  if (m_mapMatchingAvailable)
    {
      m_mapMatchingActivateTimer.stop();
      if (m_mapMatchingMode > 0)
        m_mapmatch->Reset(m_mapMatchingMode);
      return;
    }

  m_mapMatchingActivateTimer.start();
  onMapMatchingActivateTimer();
}

void PositionSource::onMapMatchingActivateTimer()
{
  m_networkManager.get(QNetworkRequest(QUrl("http://localhost:8553/v1/activate")));
  qInfo() << "Sending map matching activate request";
}

void PositionSource::onMapMatchingServiceChanged(QString name)
{
  if (name == MAPMATCHING_SERVICE) checkMapMatchAvailable();
}

void PositionSource::onMapMatchingUpdateFinished(QDBusPendingCallWatcher *watcher)
{
  QDBusPendingReply<QString> reply = *watcher;
  m_mapMatchingCallInProgress = false;

  if (reply.isError())
    {
      resetMapMatchingValues();
      qWarning() << "Error while receiving map matching reply";
      watcher->deleteLater();
      return;
    }

  QVariantMap obj = QJsonDocument::fromJson(reply.argumentAt<0>().toUtf8()).toVariant().toMap();
  watcher->deleteLater();

  // Map matching response will include only updates from
  // the previous call. So, we leave other variables unchanged
  // if they are not reported

  // coordinate
  if (obj.contains(QLatin1String("latitude")) && obj.contains(QLatin1String("longitude")))
    {
      QGeoCoordinate coor = QGeoCoordinate(obj.value(QLatin1String("latitude")).toDouble(),
                                           obj.value(QLatin1String("longitude")).toDouble());
      SETWITHVALID(coordinateMapMatch, coor, true);
    }

  // ensure that directionValid and direction are set in the correct order
  if (obj.contains(QLatin1String("direction_valid")) &&
      obj.contains(QLatin1String("direction")))
    {
      bool valid = obj.value(QLatin1String("direction_valid")).toInt();
      int dir = int(round(obj.value(QLatin1String("direction")).toDouble()));
      if (valid)
        {
          SET(directionMapMatch, dir);
          SET(directionMapMatchValid, valid);
        }
      else
        {
          SET(directionMapMatchValid, valid);
          SET(directionMapMatch, dir);
        }
    }
  else if (obj.contains(QLatin1String("direction")))
    {
      SET(directionMapMatch,
          int(round(obj.value(QLatin1String("direction")).toDouble())));
    }
  else if (obj.contains(QLatin1String("direction_valid")))
    {
      SET(directionMapMatchValid,
          obj.value(QLatin1String("direction_valid")).toInt());
    }

  if (obj.contains(QLatin1String("street_name")))
    {
      SET(streetName, obj.value(QLatin1String("street_name")).toString());
    }

  if (obj.contains(QLatin1String("street_speed_limit")))
    {
      SET(streetSpeedLimit, obj.value(QLatin1String("street_speed_limit"), -1).toDouble());
    }

  emit positionUpdated();
}

void PositionSource::resetMapMatchingValues()
{
  SET(coordinateMapMatchValid, false);
  SET(directionMapMatchValid, false);
  SET(streetName, "");
  SET(streetSpeedLimit, -1);
}

void PositionSource::stopMapMatching()
{
  if (!m_mapMatchingActive) return;
  if (m_mapMatchingMode > 0 && m_mapMatchingAvailable)
      m_mapmatch->Stop(m_mapMatchingMode);

  resetMapMatchingValues();
  m_mapMatchingActive = false;
}
