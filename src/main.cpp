/*
 * This file is part of Pure Maps.
 *
 * SPDX-FileCopyrightText: 2020 Rinigus https://github.com/rinigus
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 *
 */

#include <QDir>
#include <QFileInfo>

#ifdef IS_QTCONTROLS_QT
#include <QApplication>
#endif

#ifdef IS_SAILFISH_OS
#include <QGuiApplication>
#include <sailfishapp.h>
#endif

#include <QDBusConnection>
#include <QDBusInterface>
#include <QDBusReply>
#include <QIcon>
#include <QLoggingCategory>
#include <QStringList>
#include <QScopedPointer>
#include <QTranslator>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#ifdef IS_QTCONTROLS_QT
#include <QQuickStyle>
#endif
#include <QQuickView>
#include <QQuickWindow>

#include <QtGlobal>

#include <iostream>

#include "clipboard.h"
#include "cmdlineparser.h"
#include "commander.h"
#include "dbusservice.h"
#include "navigator.h"
#include "navigatordbusadapter.h"
#include "positionsource.h"


int main(int argc, char *argv[])
{
#ifdef IS_QTCONTROLS_QT
#ifdef DEFAULT_FALLBACK_STYLE
  if (QQuickStyle::name().isEmpty())
    QQuickStyle::setStyle(DEFAULT_FALLBACK_STYLE);
#endif
#endif

#ifdef IS_SAILFISH_OS
  QScopedPointer<QGuiApplication> app(SailfishApp::application(argc, argv));
#endif
#ifdef IS_QTCONTROLS_QT
  QScopedPointer<QApplication> app(new QApplication(argc,argv));
#endif

  app->setApplicationName(APP_NAME);
  app->setOrganizationName(APP_NAME);
  app->setApplicationVersion(APP_VERSION);
#ifdef IS_QTCONTROLS_QT
#if (QT_VERSION >= QT_VERSION_CHECK(5, 7, 0))
  app->setDesktopFileName(APP_NAME ".desktop");
#endif
#endif

  // add translations
  QString transpath;
  QTranslator translator;
  std::cout << "Current locale: " << QLocale().name().toStdString() << "\n";
  if (translator.load(QLocale(), APP_NAME, QLatin1String("-"),
                      QStringLiteral(DEFAULT_DATA_PREFIX "translations")))
    {
      std::cout << "Loaded translation\n";
      app->installTranslator(&translator);
    }
  else
    std::cout << "Translation not found\n";

  // command line
  CmdLineParser *parser = CmdLineParser::instance();
  if (!parser->parse(app->arguments()))
    return 0;

  // check if Pure Maps is running already.
  // forward cmd line arguments if it does
  {
    QDBusInterface iface(DBUS_SERVICE, DBUS_PATH_ROOT, DBUS_INTERFACE_ROOT);
    if (iface.isValid())
      {
        QDBusReply<bool> r = iface.call("CommandLine", app->arguments());
        if (r.isValid() && r.value())
          {
            std::cout << "Command line arguments forwarded to running instance. Closing\n";
            return 0;
          }
      }
  }

  // looks like it is the first instance, setup DBus service
  DBusService::instance()->init();

#if (QT_VERSION >= QT_VERSION_CHECK(5, 11, 0))
  // add fallback icon path
  QString icons_extra_path(QStringLiteral(DEFAULT_DATA_PREFIX "qml/icons/fallback"));
  if (QFileInfo::exists(icons_extra_path))
    {
      std::cout << "Fallback icons at " << icons_extra_path.toStdString() << "\n";
      QIcon::setFallbackSearchPaths(QIcon::fallbackSearchPaths() << icons_extra_path);
    }
#endif

  // Audio setup based on https://github.com/qt/qtmultimedia/commit/1c5ea95
  QByteArray envVar = qgetenv("NEMO_RESOURCE_CLASS_OVERRIDE");
  if (envVar.isEmpty())
    qputenv("NEMO_RESOURCE_CLASS_OVERRIDE", "navigator");

  // ////////////////////////////
  // QML setup

  // disable new QML connection syntax debug messages for as long as
  // older Qt versions (5.12 and older) are supported
  QLoggingCategory::setFilterRules(QStringLiteral("qt.qml.connections=false"));

#ifdef IS_SAILFISH_OS
  QScopedPointer<QQuickView> v;
  v.reset(SailfishApp::createView());
  QQmlContext *rootContext = v->rootContext();
#endif
#ifdef IS_QTCONTROLS_QT
  QQmlApplicationEngine engine;
  QQmlContext *rootContext = engine.rootContext();
#endif

  if (!rootContext)
    {
      std::cerr << "Failed to initialize QML context\n";
      return -2;
    }

#ifdef QML_IMPORT_PATH
  rootContext->engine()->addImportPath(QML_IMPORT_PATH);
#endif

  rootContext->setContextProperty("programName", "Pure Maps");
  rootContext->setContextProperty("programVersion", APP_VERSION);
  rootContext->setContextProperty("defaultFontProvider", DEFAULT_FONTPROVIDER);

  // handle map matching setting
  rootContext->setContextProperty("mapMatchingCheck",
                                #ifdef MAPMATCHING_CHECK_RUNTIME
                                  true
                                #else
                                  false
                                #endif
                                  );
  rootContext->setContextProperty("mapMatchingAvailable",
                                #ifdef MAPMATCHING_AVAILABLE
                                  true
                                #else
                                  false
                                #endif
                                  );

  // ////////////////////////////
  // register QML types
#ifdef INTERNAL_CLIPBOARD
  qmlRegisterType<Clipboard>("org.puremaps", 1, 0, "Clipboard");
#endif
  qmlRegisterType<Navigator>("org.puremaps", 1, 0, "NavigatorBase");
  qmlRegisterType<ManeuverModel>("org.puremaps", 1, 0, "ManeuverList");
  qmlRegisterType<PositionSource>("org.puremaps", 1, 0, "PositionSource");

  qmlRegisterSingletonType<CmdLineParser>("org.puremaps", 1, 0, "CmdLineParser", [](QQmlEngine *, QJSEngine *) -> QObject * {
      return static_cast<QObject *>(CmdLineParser::instance());
  });
  qmlRegisterSingletonType<Commander>("org.puremaps", 1, 0, "Commander", [](QQmlEngine *, QJSEngine *) -> QObject * {
      return static_cast<QObject *>(Commander::instance());
  });


#ifdef IS_SAILFISH_OS
  if (v)
    {
      v->setSource(SailfishApp::pathTo("qml/pure-maps.qml"));
      v->show();
    }
#endif
#ifdef IS_QTCONTROLS_QT
  engine.load(DEFAULT_DATA_PREFIX "qml/pure-maps.qml");
  if (engine.rootObjects().isEmpty())
    {
      std::cerr << "Error loading QML\n";
      return -3;
    }
#endif

  return app->exec();
}
