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

include(../common.pri)

# Adding 'CONFIG += sailfishapp_qml' is enough for the SDK, but we want to build without SDK too.
# if building without SDK, run qmake with QMAKEFEATURES=. environment variable to use the provided feature file.
CONFIG += sailfishapp_qml

DISTFILES += \
    rpm/harbour-pure-maps.yaml \
    harbour-pure-maps.desktop

SAILFISHAPP_ICONS = 86x86 108x108 128x128 172x172

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
