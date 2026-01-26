function(make_paths_relative output_var)
    set(result)
    foreach(file ${ARGN})
        file(RELATIVE_PATH rel_file ${CMAKE_CURRENT_SOURCE_DIR} ${file})
        list(APPEND result ${rel_file})
    endforeach()
    set(${output_var} ${result} PARENT_SCOPE)
endfunction()

# We can't just install entire directories, as platforms include symlinked files
# To remedy this we dereference them first
file(GLOB_RECURSE _PLATFORM_FILES platform.${FLAVOR}/*.qml)
set(_RESOLVED_FILES "")
foreach(_FILE ${_PLATFORM_FILES})
    # Get filename and set resulting file location
    get_filename_component(_FILENAME ${_FILE} NAME)
    set(_RESULT ${CMAKE_CURRENT_BINARY_DIR}/platform/${_FILENAME})

    # Copy and dereference the file
    add_custom_command(OUTPUT ${_RESULT}
        COMMAND mkdir -p ${CMAKE_CURRENT_BINARY_DIR}/platform
        COMMAND cp -L -v ${_FILE} ${_RESULT})
    add_custom_target(install_${_FILENAME} ALL
        DEPENDS ${_RESULT})

    # Add dereferenced file to list of to be installed files
    list(APPEND _RESOLVED_FILES ${_RESULT})
endforeach()

# Generate qmldir file for module pm and pm.platform
set(GENERATE_QMLDIR_SCRIPT "${CMAKE_SOURCE_DIR}/tools/generate-qmldir.sh")

add_custom_command(
    OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/qmldir
    COMMAND ${GENERATE_QMLDIR_SCRIPT} ${CMAKE_CURRENT_SOURCE_DIR} pm
    DEPENDS ${GENERATE_QMLDIR_SCRIPT} ${QML_SRC}
    COMMENT "Generating qmldir for module pm"
)

add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/platform/qmldir
    COMMAND ${GENERATE_QMLDIR_SCRIPT} ${CMAKE_CURRENT_BINARY_DIR}/platform pm.platform
    DEPENDS ${GENERATE_QMLDIR_SCRIPT} ${_PLATFORM_FILES} 
    COMMENT "Generating qmldir for module pm.platform"
)

add_custom_target(generate_qmldir ALL
    DEPENDS
    ${CMAKE_CURRENT_SOURCE_DIR}/qmldir 
    ${CMAKE_CURRENT_BINARY_DIR}/platform/qmldir)

# no installation is needed if we run from source dir
if (RUN_FROM_SOURCE)
    return()
endif()

# load QML files from filesystem with Qt 5
if(QT_VERSION_MAJOR EQUAL 5)
    install(FILES ${QML_SRC} DESTINATION ${DATADIR}/pm)
    install(FILES ${QML_JS} DESTINATION ${DATADIR}/pm/js)
    install(DIRECTORY icons DESTINATION ${DATADIR}/pm)
    install(FILES ${_RESOLVED_FILES}
        DESTINATION ${DATADIR}/pm/platform)
    install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/qmldir
        DESTINATION ${DATADIR}/pm)
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/platform/qmldir
        DESTINATION ${DATADIR}/pm/platform)
else()
    # include QML into executable
    make_paths_relative(QML_SRC_REL ${QML_SRC})
    make_paths_relative(QML_JS_REL ${QML_JS})

    # find all icons
    file(GLOB_RECURSE _ICON_FILES icons/*)
    make_paths_relative(_ICON_FILES_REL ${_ICON_FILES})

    add_library(PureMapsQml STATIC)
    qt_add_qml_module(
        PureMapsQml
        URI pm
        QML_FILES
            ${QML_SRC_REL}
        RESOURCES
            ${QML_JS_REL}
            ${_ICON_FILES_REL}
        OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/pm
    )

    # create platform submodule
    add_library(PureMapsPlatformQml STATIC)

    # Make platform files relative to build dir
    set(_PLATFORM_FILES_REL "")
    foreach(_FILE ${_RESOLVED_FILES})
        get_filename_component(_FILENAME ${_FILE} NAME)
        list(APPEND _PLATFORM_FILES_REL ${_FILENAME})
    endforeach()

    qt_add_qml_module(
        PureMapsPlatformQml
        URI pm.platform
        OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/pm/platform
    )

    foreach(_FILE ${_RESOLVED_FILES})
        get_filename_component(_FILENAME ${_FILE} NAME)
        set_source_files_properties(
            ${_FILE}
            PROPERTIES
            QT_RESOURCE_ALIAS ${_FILENAME}
        )
        qt_target_qml_sources(
            PureMapsPlatformQml
            QML_FILES
                ${_FILE}
        )
    endforeach()
endif()
