# set version
isEmpty(VERSION) {
    VERSION = 2.0.0
}

# Find out flavor and add it to CONFIG for simple testing
equals(FLAVOR, "silica") {
    CONFIG += flavor_silica
} else:equals(FLAVOR, "kirigami") {
    CONFIG += flavor_kirigami
} else:equals(FLAVOR, "qtcontrols") {
    CONFIG += flavor_qtcontrols
} else:equals(FLAVOR, "ubports") {
    CONFIG += flavor_ubports
}

############################################
# Below, configuration is set on the basis
# of the options specified above

# The name of the application
isEmpty(APP_NAME) {
    flavor_silica {
        APP_NAME = harbour-pure-maps
    } else {
        APP_NAME = pure-maps
    }
}

TARGET=$${APP_NAME}

# Overall QT options
QT += gui positioning dbus

flavor_kirigami|flavor_qtcontrols|flavor_ubports {
    QT += quick qml widgets quickcontrols2
}

# Overall CONFIG
CONFIG += c++11 object_parallel_to_source
CONFIG += link_pkgconfig
flavor_silica {
    CONFIG += sailfishapp sailfishapp_no_deploy_qml
}

# PREFIX
isEmpty(PREFIX) {
    flavor_silica {
        PREFIX = /usr
    } else {
        PREFIX = /usr/local
    }
}

# PREFIX_RUNNING
isEmpty(PREFIX_RUNNING) {
    PREFIX_RUNNING = $$PREFIX
}

DATADIR    = $$PREFIX/share/$${TARGET}
DESKTOPDIR = $$PREFIX/share/applications
EXEREAL    = $$PREFIX/bin/$${TARGET}
DBUSDIR    = $$PREFIX/share/dbus-1/services

######################################
# Installs
target.path = $$PREFIX/bin
INSTALLS += target

# Installing poor/*.py, processing path, and injecting API keys
py.extra = \
   install -v -m 644 $$PWD/poor/*.py ${INSTALL_ROOT}$$DATADIR/poor; \
   sed -i -e \'s|pure-maps|$${APP_NAME}|g\' ${INSTALL_ROOT}$$DATADIR/poor/paths.py; \
   $$PWD/tools/manage-keys inject ${INSTALL_ROOT}$$DATADIR
py.path = $$DATADIR/poor
INSTALLS += py

install_gpxpy {
    pygpxpy.files = thirdparty/gpxpy/gpxpy/*.py
    pygpxpy.path = $$DATADIR/thirdparty/gpxpy/gpxpy
    INSTALLS += pygpxpy
}

pyolc.files = thirdparty/open-location-code/*.py
pyolc.path = $$DATADIR/poor/openlocationcode

pyastral.files = thirdparty/astral/*.py
pyastral.path = $$DATADIR/poor/astral

pygeomag.files = thirdparty/geomag/geomag/*.py
pygeomag.path = $$DATADIR/poor/geomag
pygeomagdata.files = thirdparty/geomag/geomag/model_data/WMM.COF
pygeomagdata.path = $$DATADIR/poor/geomag/model_data

INSTALLS += pyolc pyastral pygeomag pygeomagdata

geocoders.files = geocoders/*.py geocoders/*.json geocoders/README.md
geocoders.path = $$DATADIR/geocoders

guides.files = guides/*.py guides/*.json guides/*.qml guides/README.md
guides.path = $$DATADIR/guides

maps.files = maps/*.json maps/README.md
maps.path = $$DATADIR/maps

routers.files = routers/*.py routers/*.json routers/*.qml routers/README.md routers/digitransit
routers.path = $$DATADIR/routers

INSTALLS += geocoders guides maps routers

# translations
trans.extra = $$PWD/tools/install-translations $${APP_NAME} $$[QT_HOST_BINS]/lconvert ${INSTALL_ROOT}$$DATADIR
trans.path = $$DATADIR
INSTALLS += trans

flavor_silica {
    qml.files = qml/*.qml
    qml.path = $$DATADIR/qml

    qmlplatform.files = qml/platform.silica/*.qml
    qmlplatform.path = $$DATADIR/platform

    js.files = qml/js/*.js
    js.path = $$DATADIR/qml/js

    icons.files = qml/icons/*.svg qml/icons/*.png qml/icons/*.jpg \
                  qml/icons/attribution qml/icons/basemap qml/icons/marker qml/icons/navigation \
                  qml/icons/navigation qml/icons/position qml/icons/sailfishos
    icons.path = $$DATADIR/qml/icons

    INSTALLS += qmlplatform qml js icons
}

flavor_kirigami|flavor_qtcontrols|flavor_ubports {
    icons108.path = $$PREFIX/share/icons/hicolor/108x108/apps
    icons108.extra = mkdir -p $(INSTALL_ROOT)/$$PREFIX/share/icons/hicolor/108x108/apps && cp $$PWD/data/pure-maps-108.png $(INSTALL_ROOT)/$$PREFIX/share/icons/hicolor/108x108/apps/$${TARGET}.png
    INSTALLS += icons108
    icons128.path = $$PREFIX/share/icons/hicolor/128x128/apps
    icons128.extra = mkdir -p $(INSTALL_ROOT)/$$PREFIX/share/icons/hicolor/128x128/apps && cp $$PWD/data/pure-maps-128.png $(INSTALL_ROOT)/$$PREFIX/share/icons/hicolor/128x128/apps/$${TARGET}.png
    INSTALLS += icons128
    icons256.path = $$PREFIX/share/icons/hicolor/256x256/apps
    icons256.extra = mkdir -p $(INSTALL_ROOT)/$$PREFIX/share/icons/hicolor/256x256/apps && cp $$PWD/data/pure-maps-256.png $(INSTALL_ROOT)/$$PREFIX/share/icons/hicolor/256x256/apps/$${TARGET}.png
    INSTALLS += icons256
    icons86.path = $$PREFIX/share/icons/hicolor/86x86/apps
    icons86.extra = mkdir -p $(INSTALL_ROOT)/$$PREFIX/share/icons/hicolor/86x86/apps && cp $$PWD/data/pure-maps-86.png $(INSTALL_ROOT)/$$PREFIX/share/icons/hicolor/86x86/apps/$${TARGET}.png
    INSTALLS += icons86

    appdata.path =$$PREFIX/share/metainfo
    appdata.files = packaging/pure-maps.appdata.xml
    INSTALLS += appdata
}


desktopfile.path = $$DESKTOPDIR
desktopfile.extra = \
    cp $$PWD/data/$${TARGET}.desktop ${INSTALL_ROOT}$${DESKTOPDIR} || cp $$PWD/data/pure-maps.desktop ${INSTALL_ROOT}$${DESKTOPDIR}/$${TARGET}.desktop || true ; \
    sed -i -e \'s|EXE|$${EXEREAL}|g\' ${INSTALL_ROOT}$${DESKTOPDIR}/$${TARGET}.desktop || true ; \
    sed -i -e \'s|NAME|$${TARGET}|g\' ${INSTALL_ROOT}$${DESKTOPDIR}/$${TARGET}.desktop || true ; \
    cp $$PWD/data/$${TARGET}-*.desktop ${INSTALL_ROOT}$${DESKTOPDIR} || true

INSTALLS += desktopfile

# defines
DEFINES += APP_NAME=\\\"$$APP_NAME\\\"
DEFINES += APP_VERSION=\\\"$$VERSION\\\"
flavor_silica {
    DEFINES += IS_SAILFISH_OS
} else:flavor_qtcontrols|flavor_kirigami {
    DEFINES += IS_QTCONTROLS_QT
} else:flavor_ubports {
    DEFINES += IS_QTCONTROLS_QT IS_UBPORTS
    DEFINES += DEFAULT_FALLBACK_STYLE=\\\"suru\\\"
}

# default prefix for data
DEFINES += DEFAULT_DATA_PREFIX=\\\"$${PREFIX_RUNNING}/share/$${TARGET}/\\\"

# The following define makes your compiler emit warnings if you use
# any feature of Qt which as been marked deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# sources
SOURCES += src/main.cpp

HEADERS +=

OTHER_FILES += rpm/harbour-pure-maps.spec
OTHER_FILES += qml/*.qml qml/js/*.js
OTHER_FILES += qml/platform.generic/*.qml
OTHER_FILES += qml/platform.kirigami/*.qml
OTHER_FILES += qml/platform.qtcontrols/*.qml
OTHER_FILES += qml/platform.ubports/*.qml
OTHER_FILES += qml/platform.silica/*.qml

# debug options
CONFIG(release, debug|release) {
    DEFINES += QT_NO_WARNING_OUTPUT QT_NO_DEBUG_OUTPUT
}


# translations
DISTFILES += $${TARGET}.desktop

flavor_silica {
    DISTFILES += \
        rpm/$${TARGET}.spec
}

flavor_kirigami|flavor_qtcontrols|flavor_ubports {
    RESOURCES += qml_main.qrc
    RESOURCES += icons.qrc
}
flavor_kirigami: RESOURCES += qml_kirigami.qrc
flavor_qtcontrols: RESOURCES += qml_qtcontrols.qrc
flavor_ubports: RESOURCES += qml_ubports.qrc

# misc options
flavor_silica {
    SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256
}
