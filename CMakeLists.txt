cmake_minimum_required(VERSION 3.5.1) # Latest version as supported by Ubuntu Touch 

project(pure-maps
    VERSION 2.6.5
    DESCRIPTION "Maps and navigation")

# options
set(APP_NAME "" CACHE STRING "Name of the application, specify if custom name is needed")
set(FLAVOR "kirigami" CACHE STRING "Platform to build support for. Supported platforms: kirigami, silica, qtcontrols, uuitk")
set(PROFILE "Online" CACHE STRING "Default profile. Supported profiles: Online, Mixed, Offline")
option(MAPMATCHING_CHECK_RUNTIME "Check map matching availibility at runtime" ON)
option(MAPMATCHING_AVAILABLE "Availibility of map matching if not checked at runtime. If checking is enabled at runtime, this option is ignored" ON)
set(PYTHON_EXE "auto" CACHE STRING "Set python3 executable. If set to 'auto', cmake will try to find it.")
option(RUN_FROM_SOURCE "Run from source, this is mainly intended for easy development" OFF)
set(S2INCLUDES "" CACHE STRING "Custom installed location for s2geometry, includes")
set(S2LIBS "" CACHE STRING "Custom installed location for s2geometry, libs")
option(USE_BUNDLED_GPXPY "Use a bundled version of GPXPY rather than a system-wide version" ON)

# set project version used in About message
if(NOT PM_VERSION)
    set(PM_VERSION ${PROJECT_VERSION})
endif()


# check options
set(VALID_FLAVOR_OPTIONS
    "kirigami"
    "silica"
    "qtcontrols"
    "uuitk")

if(NOT FLAVOR IN_LIST VALID_FLAVOR_OPTIONS)
    message(ERROR " Please specify a valid platform using -DFLAVOR=platform as CMake option!")
    return()
endif()

if(PROFILE STREQUAL "Online" OR PROFILE STREQUAL "Mixed")
    set(DEFAULT_BASEMAP "Mapbox" CACHE STRING "Default basemap")
    set(DEFAULT_GEOCODER "photon" CACHE STRING "Default geocoder")
    set(DEFAULT_GUIDE "foursquare" CACHE STRING "Default guide")
    set(DEFAULT_ROUTER "stadiamaps" CACHE STRING "Default router")
elseif(PROFILE STREQUAL "Offline")
    set(DEFAULT_BASEMAP "OSM Scout" CACHE STRING "Default basemap")
    set(DEFAULT_GEOCODER "osmscout" CACHE STRING "Default geocoder")
    set(DEFAULT_GUIDE "osmscout" CACHE STRING "Default guide")
    set(DEFAULT_ROUTER "osmscout" CACHE STRING "Default router")
else()
    message(ERROR " Please specify a supported profile using -DPROFILE as CMake option!")
    return()
endif()

# set app name
if(NOT APP_NAME)
    if(FLAVOR STREQUAL "silica")
        set(APP_NAME harbour-pure-maps)
    else()
        set(APP_NAME pure-maps)
    endif()
endif()

# requirements
set(QT_MIN_VERSION "5.6.0")
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

include(FeatureSummary)
include(GNUInstallDirs)
include(CMakePrintHelpers)

find_package(Gettext REQUIRED)

# allow to compile on platforms without FindPython3.cmake
if(PYTHON_EXE STREQUAL "auto")
    find_package(Python3 COMPONENTS Interpreter REQUIRED)
else()
    set(PYTHON_EXECUTABLE ${PYTHON_EXE})
endif()

# Qt
find_package(Qt5 ${QT_MIN_VERSION} COMPONENTS Gui Positioning Qml Quick DBus LinguistTools REQUIRED)
if(FLAVOR STREQUAL "kirigami" OR FLAVOR STREQUAL "qtcontrols" OR FLAVOR STREQUAL "uuitk")
    find_package(Qt5 ${QT_MIN_VERSION} COMPONENTS Widgets QuickControls2 REQUIRED)
elseif(FLAVOR STREQUAL "silica")
    include(FindPkgConfig)
    pkg_search_module(SAILFISH sailfishapp REQUIRED)
endif()

# handle request for running from source dir
if(RUN_FROM_SOURCE)
    set(DATADIR ${CMAKE_CURRENT_SOURCE_DIR})
    set(DATADIR_RUNNING ${DATADIR})

    add_custom_command(OUTPUT .platformlink.set.${FLAVOR}
        COMMAND rm -f ${CMAKE_CURRENT_SOURCE_DIR}/qml/platform .platformlink.set.*
        COMMAND ln -s platform.${FLAVOR} ${CMAKE_CURRENT_SOURCE_DIR}/qml/platform
        COMMAND touch .platformlink.set.${FLAVOR})
    add_custom_target(run_from_source ALL
        DEPENDS .platformlink.set.${FLAVOR})
    message(WARNING "Please DO NOT run 'cmake --install' in this build")
else()
    set(DATADIR ${CMAKE_INSTALL_FULL_DATAROOTDIR}/${APP_NAME})
    if(FLAVOR STREQUAL "uuitk")
        set(DATADIR_RUNNING ".")
    else()
        set(DATADIR_RUNNING ${DATADIR})
    endif()
endif()

# define sources and most of install targets

## extension modules
file(GLOB GEOCODERS_SRC geocoders/*.json geocoders/*.md geocoders/*.py)
file(GLOB GEOCODERS_EXTRA LIST_DIRECTORIES false geocoders/test/*)
install(FILES ${GEOCODERS_SRC} DESTINATION ${DATADIR}/geocoders)

file(GLOB GUIDES_SRC guides/*.json guides/*.md guides/*.qml guides/*.py)
file(GLOB GUIDES_EXTRA LIST_DIRECTORIES false guides/test/*)
install(FILES ${GUIDES_SRC} DESTINATION ${DATADIR}/guides)

file(GLOB MAPS_SRC maps/*.json maps/*.md)
install(FILES ${MAPS_SRC} DESTINATION ${DATADIR}/maps)

file(GLOB ROUTERS_SRC routers/*.json routers/*.md routers/*.qml routers/*.py)
file(GLOB ROUTERS_EXTRA LIST_DIRECTORIES false routers/test/*)
install(FILES ${ROUTERS_SRC} DESTINATION ${DATADIR}/routers)

## python sources: installed in subdir
file(GLOB POOR_SRC poor/*.py)

## QML sources: installed in subdir
file(GLOB QML_SRC qml/*.qml)
file(GLOB QML_JS qml/js/*.js)
file(GLOB QML_PLATFORMS qml/platform.*/*.qml)
file(GLOB QML_DOCS qml/*.md qml/platform.*/*.md)

## C++ sources
file(GLOB PM_SRC src/*.cpp)
file(GLOB PM_HEADERS src/*.h)

# custom target for showing all sources in Qt Creator
add_custom_target(Sources SOURCES
    ${GEOCODERS_SRC} ${GEOCODERS_EXTRA}
    ${GUIDES_SRC} ${GUIDES_EXTRA}
    ${MAPS_SRC}
    ${ROUTERS_SRC} ${ROUTERS_EXTRA}
    ${POOR_SRC}
    ${QML_SRC} ${QML_JS} ${QML_PLATFORMS} ${QML_DOCS}
    ${PM_SRC} ${PM_HEADERS}
    )

# process linking and installation in the subdirs where needed
add_subdirectory(src)
add_subdirectory(poor)
add_subdirectory(thirdparty)
add_subdirectory(qml)
add_subdirectory(po)

# appdata
install(FILES packaging/pure-maps.appdata.xml
    DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/metainfo
    RENAME ${APP_NAME}.appdata.xml)

# desktop files
if(NOT FLAVOR STREQUAL "silica")
    configure_file(data/pure-maps.desktop.in ${APP_NAME}.desktop @ONLY)
    configure_file(data/pure-maps-uri-handler.desktop.in ${APP_NAME}-uri-handler.desktop @ONLY)
    set(DESKTOP_SRC
        ${CMAKE_CURRENT_BINARY_DIR}/${APP_NAME}.desktop
        ${CMAKE_CURRENT_BINARY_DIR}/${APP_NAME}-uri-handler.desktop)
else()
    set(DESKTOP_SRC
        data/${APP_NAME}.desktop
        data/${APP_NAME}-uri-handler.desktop)
endif()

install(FILES ${DESKTOP_SRC}
    DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/applications)

# icons
set(ICON_SIZES 108 128 256 86)
foreach(_ISIZE ${ICON_SIZES})
    install(FILES data/pure-maps-${_ISIZE}.png RENAME ${APP_NAME}.png
        DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/icons/hicolor/${_ISIZE}x${_ISIZE}/apps)
endforeach()

# summary
feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)
