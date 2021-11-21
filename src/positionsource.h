#ifndef POSITIONSOURCE_H
#define POSITIONSOURCE_H

#include <QObject>

#include <QDateTime>
#include <QDBusPendingCallWatcher>
#include <QGeoCoordinate>
#include <QGeoPositionInfoSource>
#include <QList>
#include <QNetworkAccessManager>
#include <QTimer>

#include "osmscout_mapmatching.h"

class PositionSource: public QObject
{
  Q_OBJECT

  Q_PROPERTY(bool accurate READ accurate NOTIFY accurateChanged)
  Q_PROPERTY(bool active READ active WRITE setActive NOTIFY activeChanged)
  Q_PROPERTY(QGeoCoordinate coordinateDevice READ coordinateDevice NOTIFY coordinateDeviceChanged)
  Q_PROPERTY(bool coordinateDeviceValid READ coordinateDeviceValid NOTIFY coordinateDeviceValidChanged)
  Q_PROPERTY(QGeoCoordinate coordinateMapMatch READ coordinateMapMatch NOTIFY coordinateMapMatchChanged)
  Q_PROPERTY(bool coordinateMapMatchValid READ coordinateMapMatchValid NOTIFY coordinateMapMatchValidChanged)
  Q_PROPERTY(int directionDevice READ directionDevice NOTIFY directionDeviceChanged)
  Q_PROPERTY(bool directionDeviceValid READ directionDeviceValid NOTIFY directionDeviceValidChanged)
  Q_PROPERTY(int directionMapMatch READ directionMapMatch NOTIFY directionMapMatchChanged)
  Q_PROPERTY(bool directionMapMatchValid READ directionMapMatchValid NOTIFY directionMapMatchValidChanged)
  Q_PROPERTY(float horizontalAccuracy READ horizontalAccuracy NOTIFY horizontalAccuracyChanged)
  Q_PROPERTY(bool horizontalAccuracyValid READ horizontalAccuracyValid NOTIFY horizontalAccuracyValidChanged)
  Q_PROPERTY(int mapMatchingMode READ mapMatchingMode WRITE setMapMatchingMode NOTIFY mapMatchingModeChanged)
  Q_PROPERTY(bool ready READ ready NOTIFY readyChanged)
  Q_PROPERTY(float speed READ speed NOTIFY speedChanged)
  Q_PROPERTY(bool speedValid READ speedValid NOTIFY speedValidChanged)
  Q_PROPERTY(bool stickyDirection READ stickyDirection WRITE setStickyDirection NOTIFY stickyDirectionChanged)
  Q_PROPERTY(QString streetName READ streetName NOTIFY streetNameChanged)
  Q_PROPERTY(float streetSpeedLimit READ streetSpeedLimit NOTIFY streetSpeedLimitChanged) // in m/s
  Q_PROPERTY(QGeoCoordinate testingCoordinate READ testingCoordinate WRITE setTestingCoordinate  NOTIFY testingCoordinateChanged)
  Q_PROPERTY(bool testingMode READ testingMode WRITE setTestingMode NOTIFY testingModeChanged)
  Q_PROPERTY(QDateTime timestamp READ timestamp NOTIFY timestampChanged)
  Q_PROPERTY(int updateInterval READ updateInterval NOTIFY updateIntervalChanged)

public:
  explicit PositionSource(QObject *parent = nullptr);

  // read property values
  bool accurate() const { return m_accurate; }
  bool active() const{ return m_active; }
  QGeoCoordinate coordinateDevice() const { return m_coordinateDevice; }
  bool coordinateDeviceValid() const { return m_coordinateDeviceValid; }
  QGeoCoordinate coordinateMapMatch() const { return m_coordinateMapMatch; }
  bool coordinateMapMatchValid() const { return m_coordinateMapMatchValid; }
  int directionDevice() const { return m_directionDevice; }
  bool directionDeviceValid() const { return m_directionDeviceValid; }
  int directionMapMatch() const { return m_directionMapMatch; }
  bool directionMapMatchValid() const { return m_directionMapMatchValid; }
  float horizontalAccuracy() const { return m_horizontalAccuracy; }
  bool horizontalAccuracyValid() const { return m_horizontalAccuracyValid; }
  int mapMatchingMode() const { return m_mapMatchingMode; }
  bool ready() const { return m_ready; }
  float speed() const { return m_speed; }
  bool speedValid() const { return m_speedValid; }
  bool stickyDirection() const { return m_stickyDirection; }
  QString streetName() const { return m_streetName; }
  float streetSpeedLimit() const { return m_streetSpeedLimit; }
  QGeoCoordinate testingCoordinate() const { return m_testingCoordinate; }
  bool testingMode() const { return m_testingMode; }
  QDateTime timestamp() const { return m_timestamp; }
  int updateInterval() const { return m_updateInterval; }

  // setters
  void setActive(bool active);
  void setMapMatchingMode(int mapMatchingMode);
  void setStickyDirection(bool stickyDirection);
  void setTestingCoordinate(QGeoCoordinate testingCoordinate);
  void setTestingMode(bool testingMode);

signals:
  // properties
  void accurateChanged();
  void activeChanged();
  void coordinateDeviceChanged();
  void coordinateDeviceValidChanged();
  void coordinateMapMatchChanged();
  void coordinateMapMatchValidChanged();
  void directionDeviceChanged();
  void directionDeviceValidChanged();
  void directionMapMatchChanged();
  void directionMapMatchValidChanged();
  void horizontalAccuracyChanged();
  void horizontalAccuracyValidChanged();
  void mapMatchingModeChanged();
  void readyChanged();
  void speedChanged();
  void speedValidChanged();
  void stickyDirectionChanged();
  void streetNameChanged();
  void streetSpeedLimitChanged();
  void testingCoordinateChanged();
  void testingModeChanged();
  void timestampChanged();
  void updateIntervalChanged();

  // other signals
  void positionUpdated();

public slots:
  void onError(QGeoPositionInfoSource::Error positioningError);

private:
  void checkMapMatchAvailable();

  void onMapMatchingActive(bool active);
  void onMapMatchingActiveFinished(QDBusPendingCallWatcher*);
  void onMapMatchingActivateTimer();
  void onMapMatchingServiceChanged(QString name);
  void onMapMatchingUpdateFinished(QDBusPendingCallWatcher*);
  void onNetworkFinished(QNetworkReply *reply);
  void onPositionUpdated(const QGeoPositionInfo &info);
  void onTestingTimer();
  void onUpdateTimeout();

  void resetMapMatchingValues();
  void setPosition(const QGeoPositionInfo &info);
  void setReady(bool ready);
  void stopMapMatching();

private:
  // properties
  bool m_accurate{false};
  bool m_active{false};
  QGeoCoordinate m_coordinateDevice;
  bool m_coordinateDeviceValid{false};
  QGeoCoordinate m_coordinateMapMatch;
  bool m_coordinateMapMatchValid{false};
  int  m_directionDevice{0};
  bool m_directionDeviceValid{false};
  int  m_directionMapMatch{0};
  bool m_directionMapMatchValid{false};
  float m_horizontalAccuracy{0};
  bool m_horizontalAccuracyValid{false};
  int m_mapMatchingMode{0};
  bool m_ready{false};
  float m_speed{0};
  bool m_speedValid{false};
  bool m_stickyDirection{false};
  QString m_streetName;
  float m_streetSpeedLimit{-1};
  QGeoCoordinate m_testingCoordinate;
  bool m_testingMode{false};
  QDateTime m_timestamp;
  int m_updateInterval{0};

  // internal
  QGeoPositionInfoSource *m_source{nullptr};
  bool m_directionCalculate{false};
  QGeoCoordinate m_directionLastPositionValid;
  QList<QGeoCoordinate> m_history;

  QNetworkAccessManager m_networkManager;

  QTime m_directionTimestamp;
  QTimer m_timer;

  OSMScoutMapMatch *m_mapmatch{nullptr};
  bool m_mapMatchingActive{false};
  bool m_mapMatchingAvailable{false};
  QTimer m_mapMatchingActivateTimer;
  bool m_mapMatchingCallInProgress{false};
};

#endif // POSITIONSOURCEEXTENDED_H
