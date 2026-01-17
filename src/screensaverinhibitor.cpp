#ifdef INTERNAL_SCREENSAVERINH

#include "screensaverinhibitor.h"

#include <QCoreApplication>
#include <QDBusConnection>
#include <QDBusInterface>
#include <QDBusPendingCallWatcher>
#include <QDBusPendingReply>
#include <QDBusReply>
#include <QDebug>

#define DBUS_SERVICE "org.freedesktop.ScreenSaver"
#define DBUS_PATH "/org/freedesktop/ScreenSaver"
#define DBUS_IFACE "org.freedesktop.ScreenSaver"

ScreenSaverInhibitor::ScreenSaverInhibitor(QQuickItem *parent)
    : QQuickItem(parent), m_interface(nullptr), m_active(false), m_cookie(0),
    m_pendingOp(false), m_hasError(false) {
    m_interface = new QDBusInterface(DBUS_SERVICE, DBUS_PATH, DBUS_IFACE,
                                     QDBusConnection::sessionBus(), this);

    if (!m_interface->isValid()) {
        qWarning() << "Failed to connect to ScreenSaver D-Bus interface:"
                   << m_interface->lastError().message();
        m_hasError = true;
    }
}

ScreenSaverInhibitor::~ScreenSaverInhibitor() {
    if (m_active && m_cookie) {
        // use blocking call in destructor
        QDBusReply<void> reply = m_interface->call("UnInhibit", m_cookie);
        if (!reply.isValid()) {
            qWarning() << "Failed to uninhibit in destructor:"
                       << reply.error().message();
        }
    }
}

void ScreenSaverInhibitor::setActive(bool active) {
    m_active_queue.push_back(active);
    update();
}

void ScreenSaverInhibitor::update() {
    if (m_hasError || !m_interface->isValid()) {
        qWarning() << "Cannot change screen saver inhibition: D-Bus interface not available";
        m_active_queue.clear();
        return;
    }

    if (m_active_queue.empty() || m_pendingOp) {
        // emit signal after all updates are done
        if (!m_pendingOp)
            emit activeChanged();
        return;
    }

    bool active = m_active_queue.front();
    m_active_queue.pop_front();

    if (m_active == active) {
        update();
        return;
    }

    m_active = active;

    if (m_active) {
        inhibit();
    } else {
        uninhibit();
    }
}

void ScreenSaverInhibitor::inhibit() {
    if (m_cookie != 0) {
        update(); // Already inhibited
        return;
    }

    QDBusPendingCall pending = m_interface->asyncCall(
        "Inhibit", QCoreApplication::applicationName(), "Maps inhibition");
    QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(pending, this);
    connect(watcher, SIGNAL(finished(QDBusPendingCallWatcher *)), this,
            SLOT(onInhibitFinished(QDBusPendingCallWatcher *)));
    m_pendingOp = true;
}

void ScreenSaverInhibitor::uninhibit() {
    if (m_cookie == 0) {
        update(); // Not inhibited
        return;
    }

    QDBusPendingCall pending = m_interface->asyncCall("UnInhibit", m_cookie);
    QDBusPendingCallWatcher *watcher = new QDBusPendingCallWatcher(pending, this);
    connect(watcher, SIGNAL(finished(QDBusPendingCallWatcher *)), this,
            SLOT(onUninhibitFinished(QDBusPendingCallWatcher *)));
    m_pendingOp = true;
}

void ScreenSaverInhibitor::onInhibitFinished(QDBusPendingCallWatcher *watcher) {
    QDBusPendingReply<uint> reply = *watcher;
    m_pendingOp = false;
    if (reply.isValid()) {
        m_cookie = reply.value();
        qInfo() << "Screen saver inhibited, cookie:" << m_cookie;
    } else {
        qWarning() << "Failed to inhibit screen saver:" << reply.error().message();
        emit errorOccurred("Failed to inhibit screen saver: " +
                           reply.error().message());
        m_hasError = true;
    }
    watcher->deleteLater();
    update();
}

void ScreenSaverInhibitor::onUninhibitFinished(QDBusPendingCallWatcher *watcher) {
    QDBusPendingReply<void> reply = *watcher;
    m_pendingOp = false;
    if (reply.isValid()) {
        qInfo() << "Screen saver uninhibited, cookie:" << m_cookie;
        m_cookie = 0;
    } else {
        qWarning() << "Failed to uninhibit screen saver:"
                   << reply.error().message();
        emit errorOccurred("Failed to uninhibit screen saver: " +
                           reply.error().message());
        m_hasError = true;
    }
    watcher->deleteLater();
    update();
}

#endif // INTERNAL_SCREENSAVERINH

