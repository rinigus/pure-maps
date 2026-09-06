if(FLAVOR STREQUAL "silica")
    add_compile_options(-DIS_SAILFISH_OS)
elseif(FLAVOR STREQUAL "qtcontrols" OR FLAVOR STREQUAL "qtcontrols6" OR FLAVOR STREQUAL "kirigami" OR FLAVOR STREQUAL "kirigami6")
    add_compile_options(
        -DIS_QTCONTROLS_QT
        -DINTERNAL_CLIPBOARD
        -DINTERNAL_SCREENSAVERINH)
    set(CMAKE_AUTOMOC_MOC_OPTIONS -DINTERNAL_CLIPBOARD -DINTERNAL_SCREENSAVERINH)
else()
    add_compile_options(
        -DIS_QTCONTROLS_QT
        -DDEFAULT_FALLBACK_STYLE="suru")
endif()

if(RUN_FROM_SOURCE)
    add_compile_options(-DRUN_FROM_SOURCE)
endif()


add_compile_options(
    -DAPP_NAME="${APP_NAME}"
    -DAPP_REV_NAME="${APP_REV_NAME}"
    -DAPP_ORG="${APP_ORG}"
    -DAPP_VERSION="${PM_VERSION}"
    -DDATA_DIR="${DATADIR}"
    -DDEFAULT_DATA_PREFIX="${DATADIR_RUNNING}/"
    -DDEFAULT_FONTPROVIDER="${DEFAULT_FONTPROVIDER}"
    -DQT_DEPRECATED_WARNINGS)

if(CMAKE_BUILD_TYPE STREQUAL "release")
    add_definitions(
        -QT_NO_WARNING_OUTPUT
        -QT_NO_DEBUG_OUTPUT)
endif()

if (APP_VARIANT_JOLLA_STORE)
   add_compile_options(
       -DAPP_VARIANT_JOLLA_STORE
       )
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
    if(QT_VERSION_MAJOR EQUAL 6)
        qt6_add_dbus_interfaces(PM_SRC ${GCLUE2_XML})
    else()
        qt5_add_dbus_interfaces(PM_SRC ${GCLUE2_XML})
    endif()
endif()

add_executable(${APP_NAME} ${PM_SRC} ${PM_HEADERS})

if(FLAVOR STREQUAL "silica")
    target_include_directories(${APP_NAME} PRIVATE
        $<BUILD_INTERFACE:
        ${SAILFISH_INCLUDE_DIRS}
        >)
endif()

target_link_libraries(${APP_NAME}
    Qt${QT_VERSION_MAJOR}::Gui
    Qt${QT_VERSION_MAJOR}::Qml
    Qt${QT_VERSION_MAJOR}::Quick
    Qt${QT_VERSION_MAJOR}::Positioning
    Qt${QT_VERSION_MAJOR}::DBus
    s2::s2)

set(LINKING_FLAVORS
    "kirigami"
    "kirigami6"
    "qtcontrols"
    "qtcontrols6"
    "uuitk")
if(FLAVOR IN_LIST LINKING_FLAVORS)
    target_link_libraries(${APP_NAME}
        Qt${QT_VERSION_MAJOR}::Widgets
        Qt${QT_VERSION_MAJOR}::QuickControls2)
endif()

if(FLAVOR STREQUAL "silica")
    target_link_libraries(${APP_NAME}
        ${SAILFISH_LDFLAGS}
        )
endif()

if(NOT RUN_FROM_SOURCE AND QT_VERSION_MAJOR EQUAL 6)
    target_link_libraries(${APP_NAME}
        PureMapsQml
        PureMapsQmlplugin
        PureMapsPlatformQml
        PureMapsPlatformQmlplugin
    )
endif()

if (NOT RUN_FROM_SOURCE)
    install(TARGETS ${APP_NAME}
        DESTINATION ${CMAKE_INSTALL_BINDIR})
endif()
