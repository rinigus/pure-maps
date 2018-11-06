# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-pure-maps

# Adding 'CONFIG += sailfishapp_qml' is enough for the SDK, but we want to build without SDK too.
# if building without SDK, run qmake with QMAKEFEATURES=. environment variable to use the provided feature file.
CONFIG += sailfishapp_qml

DISTFILES += \
    rpm/harbour-pure-maps.yaml \
    harbour-pure-maps.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

# install section for additional QML sources not in sailfishapp_qml profile
qml-common.files = ../qml
qml-common.path = /usr/share/$${TARGET}
INSTALLS += qml-common

geocoders.files = ../geocoders/[a-z]*.py ../geocoders/*.json
geocoders.path = /usr/share/$${TARGET}/geocoders
INSTALLS += geocoders

guides.files = ../guides/[a-z]*.py ../guides/*.json ../guides/*.qml
guides.path = /usr/share/$${TARGET}/guides
INSTALLS += guides

maps.files = ../maps/*.json
maps.path = /usr/share/$${TARGET}/maps
INSTALLS += maps

poor.files = ../poor/*.py
poor.path = /usr/share/$${TARGET}/poor
poor-gpxpy.files = ../poor/gpxpy/*.py
poor-gpxpy.path = /usr/share/$${TARGET}/poor/gpxpy
INSTALLS += poor poor-gpxpy

routers.files = ../routers/[a-z]*.py ../routers/*.json ../routers/*.qml ../routers/*.graphql
routers.path = /usr/share/$${TARGET}/routers
routers-digitransit.files = ../routers/digitransit/*.png
routers-digitransit.path = /usr/share/$${TARGET}/routers/digitransit
INSTALLS += routers routers-digitransit
# end install section

# for the IDE
OTHER_FILES += \
    ../geocoders/* \
    ../geocoders/test/* \
    ../guides/* \
    ../guides/test/* \
    ../maps/* \
    ../poor/* \
    ../poor/test/* \
    ../routers/* \
    ../routers/digitransit/* \
    ../routers/test/* \

#    translations/*.ts \

# to disable building translations every time, comment out the
# following CONFIG line
#CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
#TRANSLATIONS += translations/pure-maps-de.ts
