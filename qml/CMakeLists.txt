install(FILES ${QML_SRC} DESTINATION ${DATADIR}/qml)
install(FILES ${QML_JS} DESTINATION ${DATADIR}/qml/js)
install(DIRECTORY icons DESTINATION ${DATADIR}/qml)

# We can't just install entire directories, as the kirigami flavor includes symlinked files
# To remedy this we dereference them first
file(GLOB_RECURSE _PLATFORM_FILES platform.${FLAVOR}/*)
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

install(FILES ${_RESOLVED_FILES}
    DESTINATION ${DATADIR}/qml/platform)
