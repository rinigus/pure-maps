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
    -DAPP_VERSION="${PM_VERSION}"
    -DDEFAULT_DATA_PREFIX="${DATADIR_RUNNING}/"
    -DDEFAULT_FONTPROVIDER="${DEFAULT_FONTPROVIDER}"
    -DQT_DEPRECATED_WARNINGS)

if(CMAKE_BUILD_TYPE STREQUAL "release")
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

if(QML_IMPORT_PATH)
    add_definitions(-DQML_IMPORT_PATH=${QML_IMPORT_PATH})
endif()

if(USE_BUNDLED_GEOCLUE2)
    add_definitions(-DUSE_BUNDLED_GEOCLUE2)

    list(APPEND PM_SRC ${GCLUE2_SRC})
    list(APPEND PM_HEADERS ${GCLUE2_HEADERS})

    set_source_files_properties(${GCLUE2_XML}
                                PROPERTIES INCLUDE geoclue2/geocluetypes.h NO_NAMESPACE ON)
    qt5_add_dbus_interfaces(PM_SRC ${GCLUE2_XML})
endif()

add_executable(${APP_NAME} ${PM_SRC} ${PM_HEADERS})

if(FLAVOR STREQUAL "silica")
    target_include_directories(${APP_NAME} PRIVATE
        $<BUILD_INTERFACE:
        ${SAILFISH_INCLUDE_DIRS}
        >)
endif()

target_link_libraries(${APP_NAME}
    Qt5::Gui
    Qt5::Qml
    Qt5::Quick
    Qt5::Positioning
    Qt5::DBus
    s2)

set(LINKING_FLAVORS
    "kirigami"
    "qtcontrols"
    "uuitk")
if(FLAVOR IN_LIST LINKING_FLAVORS)
    target_link_libraries(${APP_NAME}
        Qt5::Widgets
        Qt5::QuickControls2)
endif()

if(FLAVOR STREQUAL "silica")
    target_link_libraries(${APP_NAME}
        ${SAILFISH_LDFLAGS}
        )
endif()

install(TARGETS ${APP_NAME}
    DESTINATION ${CMAKE_INSTALL_BINDIR})
