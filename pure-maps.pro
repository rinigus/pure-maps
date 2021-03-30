# set version
isEmpty(VERSION) {
    VERSION = 2.6.5
}

# Find out flavor and add it to CONFIG for simple testing
equals(FLAVOR, "silica") {
    CONFIG += flavor_silica
} else:equals(FLAVOR, "kirigami") {
    CONFIG += flavor_kirigami
} else:equals(FLAVOR, "qtcontrols") {
    CONFIG += flavor_qtcontrols
} else:equals(FLAVOR, "uuitk") {
    CONFIG += flavor_uuitk
} else {
    error("Please specify platform using FLAVOR=platform as qmake option. Supported platforms: kirigami, silica, qtcontrols, uuitk.")
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

flavor_kirigami|flavor_qtcontrols|flavor_uuitk {
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
    } else:flavor_uuitk {
        PREFIX = /
    } else {
        PREFIX = /usr/local
    }
}

# PREFIX_RUNNING
isEmpty(PREFIX_RUNNING) {
    flavor_uuitk {
        PREFIX_RUNNING = .
    } else {
        PREFIX_RUNNING = $$PREFIX
    }
}

DATADIR = $$PREFIX/share/$${TARGET}
DATADIR_RUNNING = $$PREFIX_RUNNING/share/$${TARGET}
DESKTOPDIR = $$PREFIX/share/applications
EXEREAL    = $$PREFIX/bin/$${TARGET}
DBUSDIR    = $$PREFIX/share/dbus-1/services

# Local run during development
run_from_source {
    DATADIR=$$PWD
    DATADIR_RUNNING=$$PWD

    platformlink.target = .platformlink.set.$$FLAVOR
    platformlink.commands = \
       rm -f $$PWD/qml/platform .platformlink.set.* || true; \
       ln -s platform.$$FLAVOR $$PWD/qml/platform; \
       touch $$platformlink.target

    QMAKE_EXTRA_TARGETS += platformlink
    PRE_TARGETDEPS += $$platformlink.target

    message(Please DO NOT run 'make install' in this build)
}

######################################
# Installs
target.path = $$PREFIX/bin
INSTALLS += target

# Installing poor/*.py, processing path, default configuration, and injecting API keys
py.extra = \
   install -v -m 644 $$PWD/poor/*.py ${INSTALL_ROOT}$$DATADIR/poor; \
   sed -i -e \'s|pure-maps|$${APP_NAME}|g\' ${INSTALL_ROOT}$$DATADIR/poor/paths.py; \
   [ \"$${DEFAULT_BASEMAP}\" != \"\" ] && sed -i -e \'s|_default_basemap *=.*|_default_basemap = \"$${DEFAULT_BASEMAP}\"|g\' ${INSTALL_ROOT}$$DATADIR/poor/config.py; \
   [ \"$${DEFAULT_GEOCODER}\" != \"\" ] && sed -i -e \'s|_default_geocoder *=.*|_default_geocoder = \"$${DEFAULT_GEOCODER}\"|g\' ${INSTALL_ROOT}$$DATADIR/poor/config.py; \
   [ \"$${DEFAULT_GUIDE}\" != \"\" ] && sed -i -e \'s|_default_guide *=.*|_default_guide = \"$${DEFAULT_GUIDE}\"|g\' ${INSTALL_ROOT}$$DATADIR/poor/config.py; \
   [ \"$${DEFAULT_ROUTER}\" != \"\" ] && sed -i -e \'s|_default_router *=.*|_default_router = \"$${DEFAULT_ROUTER}\"|g\' ${INSTALL_ROOT}$$DATADIR/poor/config.py; \
   python3 $$PWD/tools/manage-keys inject ${INSTALL_ROOT}$$DATADIR
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
trans.extra = sh $$PWD/tools/install-translations $${APP_NAME} $$[QT_HOST_BINS]/lconvert ${INSTALL_ROOT}$$DATADIR
trans.path = $$DATADIR
INSTALLS += trans

qml.files = qml/*.qml
qml.path = $$DATADIR/qml

js.files = qml/js/*.js
js.path = $$DATADIR/qml/js

icons.files = qml/icons/*.svg qml/icons/*.png qml/icons/*.jpg \
              qml/icons/attribution qml/icons/basemap qml/icons/marker qml/icons/navigation \
              qml/icons/navigation qml/icons/position \
              qml/icons/fallback qml/icons/uuitk qml/icons/sailfishos
icons.path = $$DATADIR/qml/icons

qmlplatform.extra = cp -L -v $$PWD/qml/platform.$$FLAVOR/*.qml ${INSTALL_ROOT}$$DATADIR/qml/platform
qmlplatform.path = $$DATADIR/qml/platform

INSTALLS += qmlplatform qml js icons

icons108.path = $$PREFIX/share/icons/hicolor/108x108/apps
icons108.extra = mkdir -p $(INSTALL_ROOT)/$$PREFIX/share/icons/hicolor/108x108/apps && cp $$PWD/data/pure-maps-108.png ${INSTALL_ROOT}$$PREFIX/share/icons/hicolor/108x108/apps/$${TARGET}.png
icons128.path = $$PREFIX/share/icons/hicolor/128x128/apps
icons128.extra = mkdir -p $(INSTALL_ROOT)/$$PREFIX/share/icons/hicolor/128x128/apps && cp $$PWD/data/pure-maps-128.png ${INSTALL_ROOT}$$PREFIX/share/icons/hicolor/128x128/apps/$${TARGET}.png
icons256.path = $$PREFIX/share/icons/hicolor/256x256/apps
icons256.extra = mkdir -p $(INSTALL_ROOT)/$$PREFIX/share/icons/hicolor/256x256/apps && cp $$PWD/data/pure-maps-256.png ${INSTALL_ROOT}$$PREFIX/share/icons/hicolor/256x256/apps/$${TARGET}.png
icons86.path = $$PREFIX/share/icons/hicolor/86x86/apps
icons86.extra = mkdir -p $(INSTALL_ROOT)/$$PREFIX/share/icons/hicolor/86x86/apps && cp $$PWD/data/pure-maps-86.png ${INSTALL_ROOT}$$PREFIX/share/icons/hicolor/86x86/apps/$${TARGET}.png
INSTALLS += icons86 icons108 icons128 icons256

appdata.path =$$PREFIX/share/metainfo
appdata.extra = install -m 644 $$PWD/packaging/pure-maps.appdata.xml ${INSTALL_ROOT}$$appdata.path/$${TARGET}.appdata.xml
INSTALLS += appdata

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
} else:flavor_uuitk {
    DEFINES += IS_QTCONTROLS_QT
    DEFINES += DEFAULT_FALLBACK_STYLE=\\\"suru\\\"
}

flavor_qtcontrols|flavor_kirigami: DEFINES += INTERNAL_CLIPBOARD

# default prefix for data
DEFINES += DEFAULT_DATA_PREFIX=\\\"$${DATADIR_RUNNING}/\\\"

# The following define makes your compiler emit warnings if you use
# any feature of Qt which as been marked deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# sources
SOURCES += src/main.cpp \
    src/clipboard.cpp \
    src/cmdlineparser.cpp \
    src/commander.cpp \
    src/config.cpp \
    src/dbusroot.cpp \
    src/dbusservice.cpp \
    src/location.cpp \
    src/locationmodel.cpp \
    src/maneuver.cpp \
    src/maneuvermodel.cpp \
    src/navigator.cpp \
    src/navigatordbusadapter.cpp \
    src/prompt.cpp

HEADERS += \
    src/clipboard.h \
    src/cmdlineparser.h \
    src/commander.h \
    src/config.h \
    src/dbusroot.h \
    src/dbusservice.h \
    src/location.h \
    src/locationmodel.h \
    src/maneuver.h \
    src/maneuvermodel.h \
    src/navigator.h \
    src/navigatordbusadapter.h \
    src/prompt.h

OTHER_FILES += rpm/harbour-pure-maps.spec
OTHER_FILES += qml/platform.generic/*.qml
OTHER_FILES += qml/platform.kirigami/*.qml
OTHER_FILES += qml/platform.qtcontrols/*.qml
OTHER_FILES += qml/platform.uuitk/*.qml
OTHER_FILES += qml/platform.silica/*.qml
OTHER_FILES += poor/*.py

# debug options
CONFIG(release, debug|release) {
    DEFINES += QT_NO_WARNING_OUTPUT QT_NO_DEBUG_OUTPUT
}

# extra libraries
!isEmpty(S2INCLUDES) {
    INCLUDEPATH += $${S2INCLUDES}
}
!isEmpty(S2LIBS) {
    LIBS += $${S2LIBS}
}

# specify s2 requirement
LIBS += -ls2

# translations
DISTFILES += $${TARGET}.desktop

flavor_silica {
    DISTFILES += \
        rpm/$${TARGET}.spec
}
