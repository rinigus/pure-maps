if(FLAVOR STREQUAL "silica")
	add_compile_options(-DIS_SAILFISH_OS)
elseif(FLAVOR STREQUAL "qtcontrols" OR FLAVOR STREQUAL "kirigami")
	add_compile_options(
		-DIS_QTCONTROLS_QT
		-DINTERNAL_CLIPBOARD)
	set(CMAKE_AUTOMOC_MOC_OPTIONS -DINTERNAL_CLIPBOARD)
else()
	add_compile_options(
		-DIS_QTCONTROLS_QT
		-DDEFAULT_FALLBACK_STYLE="suru")
endif()

add_compile_options(
	-DAPP_NAME="${APP_NAME}"
	-DAPP_VERSION="${PROJECT_VERSION}"
	-DDEFAULT_DATA_PREFIX="${DATADIR}/"
	-DQT_DEPRECATED_WARNINGS)

set(SRC
	main.cpp
	clipboard.cpp
	cmdlineparser.cpp
	commander.cpp
	config.cpp
	dbusroot.cpp
	dbusservice.cpp
	location.cpp
	locationmodel.cpp
	maneuver.cpp
	maneuvermodel.cpp
	navigator.cpp
	navigatordbusadapter.cpp
	prompt.cpp)
set(HEADERS
	clipboard.h
	cmdlineparser.h
	commander.h
	config.h
	dbusroot.h
	dbusservice.h
	location.h
	locationmodel.h
	maneuver.h
	maneuvermodel.h
	navigator.h
	navigatordbusadapter.h
	prompt.h)

if(CMAKE_BUILD_TYPE STREQUAL "release" OR CMAKE_BUILD_TYPE STREQUAL "debug")
	add_definitions(
		-QT_NO_WARNING_OUTPUT
		-QT_NO_DEBUG_OUTPUT)
endif()

if(S2INCLUDES)
	include_directories(${S2INCLUDES})
endif()

if(S2LIBS)
	link_directories(${S2LIBS})
endif()

add_executable(${APP_NAME} ${SRC} ${HEADERS})

target_link_libraries(${APP_NAME}
	Qt5::Gui
	Qt5::Widgets
	Qt5::Qml
	Qt5::Quick
	Qt5::QuickControls2
	Qt5::Positioning
	Qt5::DBus
	s2)

install(TARGETS ${APP_NAME}
	DESTINATION ${CMAKE_INSTALL_BINDIR})
