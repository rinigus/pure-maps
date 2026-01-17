#ifndef SCREENSAVERINHIBITOR_H
#define SCREENSAVERINHIBITOR_H

#ifdef INTERNAL_SCREENSAVERINH

#include <QQuickItem>

#include <QObject>
#include <QString>
#include <deque>

class QDBusInterface;
class QDBusPendingCallWatcher;

class ScreenSaverInhibitor : public QQuickItem {
    Q_OBJECT
    Q_PROPERTY(bool active READ active WRITE setActive NOTIFY activeChanged)

public:
    explicit ScreenSaverInhibitor(QQuickItem *parent=nullptr);
    ~ScreenSaverInhibitor() override;

    bool active() const { return m_active; }
    void setActive(bool active);

signals:
    void activeChanged();
    void errorOccurred(const QString &message);

private slots:
    void onInhibitFinished(QDBusPendingCallWatcher *watcher);
    void onUninhibitFinished(QDBusPendingCallWatcher *watcher);

private:
    void inhibit();
    void uninhibit();
    void update();

    QDBusInterface *m_interface;
    std::deque<bool> m_active_queue;
    bool m_active;
    uint m_cookie;
    bool m_hasError;
    bool m_pendingOp;
};

#endif // INTERNAL_SCREENSAVERINH

#endif // SCREENSAVERINHIBITOR_H
