/*
 * Copyright (C) 2020 Rinigus https://github.com/rinigus
 *
 * This file is part of Pure Maps.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
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

#include <QIcon>
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

#if (QT_VERSION >= QT_VERSION_CHECK(5, 11, 0))
  // add fallback icon path
  QString icons_extra_path(QStringLiteral(DEFAULT_DATA_PREFIX "qml/icons/fallback"));
  if (QFileInfo::exists(icons_extra_path)) {
      std::cout << "Fallback icons at " << icons_extra_path.toStdString() << "\n";
      QIcon::setFallbackSearchPaths(QIcon::fallbackSearchPaths() << icons_extra_path);
    }
#endif

#ifdef IS_SAILFISH_OS
  QScopedPointer<QQuickView> v;
  v.reset(SailfishApp::createView());
  QQmlContext *rootContext = v->rootContext();
#endif
#ifdef IS_QTCONTROLS_QT
  QQmlApplicationEngine engine;
  QQmlContext *rootContext = engine.rootContext();
#endif

#if defined(IS_SAILFISH_OS) || defined(IS_QTCONTROLS_QT)
  if (rootContext)
    {
      rootContext->setContextProperty("programName", "Pure Maps");
      rootContext->setContextProperty("programVersion", APP_VERSION);
    }
#endif

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
