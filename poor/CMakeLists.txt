install(FILES ${POOR_SRC} DESTINATION ${DATADIR}/poor)

add_custom_command(OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/paths.py"
    COMMAND sed -e \'s|pure-maps|${APP_NAME}|g\' ${CMAKE_CURRENT_SOURCE_DIR}/paths.py > ${CMAKE_CURRENT_BINARY_DIR}/paths.py)
add_custom_target(sed_default_paths ALL
    DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/paths.py")

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/paths.py
    DESTINATION ${DATADIR}/poor)

add_custom_command(OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/config.py"
    COMMAND sed -e \'s|_default_basemap *=.*|_default_basemap = \"${DEFAULT_BASEMAP}\"|g\' ${CMAKE_CURRENT_SOURCE_DIR}/config.py > ${CMAKE_CURRENT_BINARY_DIR}/config.py
    COMMAND sed -i -e \'s|_default_geocoder *=.*|_default_geocoder = \"${DEFAULT_GEOCODER}\"|g\' ${CMAKE_CURRENT_BINARY_DIR}/config.py
    COMMAND sed -i -e \'s|_default_guide *=.*|_default_guide = \"${DEFAULT_GUIDE}\"|g\' ${CMAKE_CURRENT_BINARY_DIR}/config.py
    COMMAND sed -i -e \'s|_default_router *=.*|_default_router = \"${DEFAULT_ROUTER}\"|g\' ${CMAKE_CURRENT_BINARY_DIR}/config.py
    COMMAND sed -i -e \'s|_default_profile *=.*|_default_profile = \"${DEFAULT_PROFILE}\"|g\' ${CMAKE_CURRENT_BINARY_DIR}/config.py)
add_custom_target(sed_default_providers ALL
  DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/config.py")

install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/config.py
    DESTINATION ${DATADIR}/poor)

if (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/../tools/apikeys.py)
  add_custom_command(OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/apikeys.py"
    COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/../tools/apikeys.py ${CMAKE_CURRENT_BINARY_DIR})
  add_custom_target(inject_keys ALL
    DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/apikeys.py")

  install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/apikeys.py
    DESTINATION ${DATADIR}/poor)
endif()


install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/../thirdparty/astral/astral.py
    DESTINATION ${DATADIR}/poor/astral)

install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/../thirdparty/open-location-code/openlocationcode.py
    DESTINATION ${DATADIR}/poor/openlocationcode)
