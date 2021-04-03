cmake_minimum_required(VERSION 3.5.1) # Latest version as supported by Ubuntu Touch 

project(pure-maps
	VERSION 2.6.5
	DESCRIPTION "Maps and navigation")

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

include(FeatureSummary)
include(GNUInstallDirs)
include(CMakePrintHelpers)

option(USE_BUNDLED_GPXPY "Use a bundled version of GPXPY rather than a system-wide version" ON)
set(FLAVOR "kirigami" CACHE STRING "Platform to build support for. Supported platforms: kirigami, silica, qtcontrols, uuitk")
set(PROFILE "Online" CACHE STRING "Default profile. Supported profiles: Online, Mixed, Offline")
option(RUN_FROM_SOURCE "Run from source, this is mainly intended for easy development" OFF)
set(S2INCLUDES "" CACHE STRING "Custom installed location for s2geometry, includes")
set(S2LIBS "" CACHE STRING "Custom installed location for s2geometry, libs")

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

if(FLAVOR STREQUAL "silica")
	set(APP_NAME harbour-pure-maps)
else()
	set(APP_NAME pure-maps)
endif()

set(QT_MIN_VERSION "5.6.0")
find_package(Python3 COMPONENTS Interpreter REQUIRED)
find_package(Gettext REQUIRED)
find_package(Qt5 ${QT_MIN_VERSION} COMPONENTS Gui Positioning DBus LinguistTools REQUIRED)

if(FLAVOR STREQUAL "kirigami" OR FLAVOR STREQUAL "qtcontrols" OR FLAVOR STREQUAL "uuitk")
	find_package(Qt5 ${QT_MIN_VERSION} COMPONENTS Quick Qml Widgets QuickControls2 REQUIRED)
endif()

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

add_subdirectory(src)
add_subdirectory(poor)
add_subdirectory(thirdparty)
add_subdirectory(qml)
add_subdirectory(po)

install(DIRECTORY geocoders
	DESTINATION ${DATADIR}
	PATTERN "__pycache__" EXCLUDE
	PATTERN "test" EXCLUDE)
install(DIRECTORY guides
	DESTINATION ${DATADIR}
	PATTERN "__pycache__" EXCLUDE
	PATTERN "test" EXCLUDE)
install(DIRECTORY maps
	DESTINATION ${DATADIR}
	PATTERN "__pycache__" EXCLUDE
	PATTERN "test" EXCLUDE)
install(DIRECTORY routers
	DESTINATION ${DATADIR}
	PATTERN "__pycache__" EXCLUDE
	PATTERN "test" EXCLUDE)

install(FILES packaging/pure-maps.appdata.xml
	DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/metainfo
	RENAME ${APP_NAME}.appdata.xml)

if(NOT FLAVOR STREQUAL "silica")
	configure_file(data/${APP_NAME}.desktop.in ${APP_NAME}.desktop @ONLY)
endif()

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${APP_NAME}.desktop
	DESTINATION ${CMAKE_INSTALL_DATAROOTDIR}/applications)

feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)