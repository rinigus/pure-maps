#ifndef POSITIONSOURCE_H
#define POSITIONSOURCE_H

#include <QObject>

#include <QDateTime>
#include <QGeoCoordinate>
#include <QGeoPositionInfoSource>

class PositionSource: public QObject
{
  Q_OBJECT

  Q_PROPERTY(bool accurate READ accurate NOTIFY accurateChanged)
  Q_PROPERTY(bool active READ active WRITE setActive NOTIFY activeChanged)
  Q_PROPERTY(QGeoCoordinate coordinate READ coordinate NOTIFY coordinateChanged)
  Q_PROPERTY(bool coordinateValid READ coordinateValid NOTIFY coordinateValidChanged)
  Q_PROPERTY(float direction READ direction NOTIFY directionChanged)
  Q_PROPERTY(bool directionValid READ directionValid NOTIFY directionValidChanged)
  Q_PROPERTY(float horizontalAccuracy READ horizontalAccuracy NOTIFY horizontalAccuracyChanged)
  Q_PROPERTY(bool horizontalAccuracyValid READ horizontalAccuracyValid NOTIFY horizontalAccuracyValidChanged)
  Q_PROPERTY(bool ready READ ready NOTIFY readyChanged)
  Q_PROPERTY(float speed READ speed NOTIFY speedChanged)
  Q_PROPERTY(bool speedValid READ speedValid NOTIFY speedValidChanged)
  Q_PROPERTY(bool stickyDirection READ stickyDirection WRITE setStickyDirection NOTIFY stickyDirectionChanged)
  Q_PROPERTY(QDateTime timestamp READ timestamp NOTIFY timestampChanged)
  Q_PROPERTY(int updateInterval READ updateInterval NOTIFY updateIntervalChanged)

public:
  explicit PositionSource(QObject *parent = nullptr);

  // read property values
  bool accurate() const { return m_accurate; }
  bool active() const{ return m_active; }
  QGeoCoordinate coordinate() const { return m_coordinate; }
  bool coordinateValid() const { return m_coordinateValid; }
  float direction() const { return m_direction; }
  bool directionValid() const { return m_directionValid; }
  float horizontalAccuracy() const { return m_horizontalAccuracy; }
  bool horizontalAccuracyValid() const { return m_horizontalAccuracyValid; }
  bool ready() const { return m_ready; }
  float speed() const { return m_speed; }
  bool speedValid() const { return m_speedValid; }
  bool stickyDirection() const { return m_stickyDirection; }
  QDateTime timestamp() const { return m_timestamp; }
  int updateInterval() const { return m_updateInterval; }

  // setters
  void setActive(bool active);
  void setStickyDirection(bool stickyDirection);

signals:
  // properties
  void accurateChanged();
  void activeChanged();
  void coordinateChanged();
  void coordinateValidChanged();
  void directionChanged();
  void directionValidChanged();
  void horizontalAccuracyChanged();
  void horizontalAccuracyValidChanged();
  void readyChanged();
  void speedChanged();
  void speedValidChanged();
  void stickyDirectionChanged();
  void timestampChanged();
  void updateIntervalChanged();

  // other signals
  void positionUpdated();

private:
  void onError(QGeoPositionInfoSource::Error positioningError);
  void onPositionUpdated(const QGeoPositionInfo &info);
  void onUpdateTimeout();

  void setReady(bool ready);

private:
  // properties
  bool m_accurate{false};
  bool m_active{false};
  QGeoCoordinate m_coordinate;
  bool m_coordinateValid{false};
  float m_direction{0};
  bool m_directionValid{false};
  float m_horizontalAccuracy{0};
  bool m_horizontalAccuracyValid;
  bool m_ready{false};
  float m_speed{0};
  bool m_speedValid{false};
  bool m_stickyDirection{false};
  QDateTime m_timestamp;
  int m_updateInterval{0};

  // internal
  QGeoPositionInfoSource *m_source{nullptr};
};

#endif // POSITIONSOURCEEXTENDED_H
