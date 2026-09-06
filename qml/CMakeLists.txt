file(GLOB_RECURSE _PLATFORM_FILES platform.${FLAVOR}/*.qml)
set(_RESOLVED_FILES "")
foreach(_FILE ${_PLATFORM_FILES})
    get_filename_component(_FILENAME ${_FILE} NAME)
    if(RUN_FROM_SOURCE)
        set(_RESULT ${DATADIR}/pm/platform/${_FILENAME})
        add_custom_command(OUTPUT ${_RESULT}
            COMMAND mkdir -p ${DATADIR}/pm/platform
            COMMAND ln -s -r ${_FILE} ${_RESULT}
            DEPENDS ${_FILE} ${_RUNTIME_DATA_STAMP})
    else()
        # We can't just install entire directories, as platforms include symlinked files.
        set(_RESULT ${CMAKE_CURRENT_BINARY_DIR}/platform/${_FILENAME})
        add_custom_command(OUTPUT ${_RESULT}
            COMMAND mkdir -p ${CMAKE_CURRENT_BINARY_DIR}/platform
            COMMAND cp -L -v ${_FILE} ${_RESULT})
        add_custom_target(install_${_FILENAME} ALL DEPENDS ${_RESULT})
    endif()
    list(APPEND _RESOLVED_FILES ${_RESULT})
endforeach()

set(GENERATE_QMLDIR_SCRIPT "${CMAKE_SOURCE_DIR}/tools/generate-qmldir.sh")

if(RUN_FROM_SOURCE)
    set(_PM_DIR ${DATADIR}/pm)
    set(_RUNTIME_QML_FILES "")
    foreach(_FILE ${QML_SRC})
        get_filename_component(_FILENAME ${_FILE} NAME)
        set(_RESULT ${_PM_DIR}/${_FILENAME})
        add_custom_command(OUTPUT ${_RESULT}
            COMMAND mkdir -p ${_PM_DIR}
            COMMAND ln -s -r ${_FILE} ${_RESULT}
            DEPENDS ${_FILE} ${_RUNTIME_DATA_STAMP})
        list(APPEND _RUNTIME_QML_FILES ${_RESULT})
    endforeach()
    add_custom_command(OUTPUT ${_PM_DIR}/js
        COMMAND mkdir -p ${_PM_DIR}
        COMMAND ln -s -r ${CMAKE_CURRENT_SOURCE_DIR}/js ${_PM_DIR}/js
        DEPENDS ${QML_JS} ${_RUNTIME_DATA_STAMP})
    add_custom_command(OUTPUT ${_PM_DIR}/icons
        COMMAND mkdir -p ${_PM_DIR}
        COMMAND ln -s -r ${CMAKE_CURRENT_SOURCE_DIR}/icons ${_PM_DIR}/icons
        DEPENDS ${_RUNTIME_DATA_STAMP})
    list(APPEND _RUNTIME_QML_FILES ${_PM_DIR}/js ${_PM_DIR}/icons)
    set(_QMLDIR ${_PM_DIR}/qmldir)
    set(_PLATFORM_QMLDIR ${_PM_DIR}/platform/qmldir)
    set(_QMLDIR_SOURCE ${_PM_DIR})
    set(_PLATFORM_QMLDIR_SOURCE ${_PM_DIR}/platform)
else()
    set(_QMLDIR ${CMAKE_CURRENT_SOURCE_DIR}/qmldir)
    set(_PLATFORM_QMLDIR ${CMAKE_CURRENT_BINARY_DIR}/platform/qmldir)
    set(_QMLDIR_SOURCE ${CMAKE_CURRENT_SOURCE_DIR})
    set(_PLATFORM_QMLDIR_SOURCE ${CMAKE_CURRENT_BINARY_DIR}/platform)
endif()

add_custom_command(
    OUTPUT ${_QMLDIR}
    COMMAND ${GENERATE_QMLDIR_SCRIPT} ${_QMLDIR_SOURCE} pm
    DEPENDS ${GENERATE_QMLDIR_SCRIPT} ${QML_SRC} ${_RUNTIME_QML_FILES}
    COMMENT "Generating qmldir for module pm"
)

add_custom_command(
    OUTPUT ${_PLATFORM_QMLDIR}
    COMMAND ${GENERATE_QMLDIR_SCRIPT} ${_PLATFORM_QMLDIR_SOURCE} pm.platform
    DEPENDS ${GENERATE_QMLDIR_SCRIPT} ${_RESOLVED_FILES}
    COMMENT "Generating qmldir for module pm.platform"
)

add_custom_target(generate_qmldir ALL
    DEPENDS
    ${_QMLDIR}
    ${_PLATFORM_QMLDIR})

if(RUN_FROM_SOURCE)
    add_dependencies(generate_qmldir runtime_data)
endif()

# no installation is needed if we run from source dir
if (RUN_FROM_SOURCE)
    return()
endif()

# Load QML files from the filesystem
install(FILES ${QML_SRC} DESTINATION ${DATADIR}/pm)
install(FILES ${QML_JS} DESTINATION ${DATADIR}/pm/js)
install(DIRECTORY icons DESTINATION ${DATADIR}/pm)
install(FILES ${_RESOLVED_FILES}
    DESTINATION ${DATADIR}/pm/platform)
install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/qmldir
    DESTINATION ${DATADIR}/pm)
install(FILES ${CMAKE_CURRENT_BINARY_DIR}/platform/qmldir
    DESTINATION ${DATADIR}/pm/platform)
