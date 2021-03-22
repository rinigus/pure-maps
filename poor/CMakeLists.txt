file(GLOB_RECURSE POOR *.py)
list(FILTER POOR EXCLUDE REGEX "__pycache__|test")
install(FILES ${POOR} DESTINATION ${DATADIR}/poor)
# The following _should_ work and would be better than the above GLOB_RECURSE, but for some reason it installs broken symlinks as well instead of just Python files
#install(DIRECTORY poor
#	DESTINATION ${DATADIR}
#	FILES_MATCHING
#	PATTERN "*.py")

add_custom_command(OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/config.py"
	COMMAND sed -e \'s|pure-maps|${APP_NAME}|g\' ${CMAKE_CURRENT_SOURCE_DIR}/paths.py > ${CMAKE_CURRENT_BINARY_DIR}/paths.py
	COMMAND sed -e \'s|_default_basemap *=.*|_default_basemap = \"${DEFAULT_BASEMAP}\"|g\' ${CMAKE_CURRENT_SOURCE_DIR}/config.py > ${CMAKE_CURRENT_BINARY_DIR}/config.py
	COMMAND sed -i -e \'s|_default_geocoder *=.*|_default_geocoder = \"${DEFAULT_GEOCODER}\"|g\' ${CMAKE_CURRENT_BINARY_DIR}/config.py
	COMMAND sed -i -e \'s|_default_guide *=.*|_default_guide = \"${DEFAULT_GUIDE}\"|g\' ${CMAKE_CURRENT_BINARY_DIR}/config.py
	COMMAND sed -i -e \'s|_default_router *=.*|_default_router = \"${DEFAULT_ROUTER}\"|g\' ${CMAKE_CURRENT_BINARY_DIR}/config.py)
add_custom_target(sed_default_providers ALL
	DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/config.py")

add_custom_command(OUTPUT "${CMAKE_CURRENT_BINARY_DIR}/keystore.py"
	COMMAND cp ${CMAKE_CURRENT_SOURCE_DIR}/keystore.py ${CMAKE_CURRENT_BINARY_DIR}/keystore.py
	COMMAND ${PYTHON_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/../tools/manage-keys inject ${CMAKE_CURRENT_BINARY_DIR})
add_custom_target(inject_keys ALL
	DEPENDS "${CMAKE_CURRENT_BINARY_DIR}/keystore.py")

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/paths.py
	DESTINATION ${DATADIR}/poor)
install(FILES
	${CMAKE_CURRENT_BINARY_DIR}/config.py
	${CMAKE_CURRENT_BINARY_DIR}/keystore.py
	DESTINATION ${DATADIR}/poor)

install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/../thirdparty/astral/astral.py
	DESTINATION ${DATADIR}/poor/astral)

install(FILES ${CMAKE_CURRENT_SOURCE_DIR}/../thirdparty/open-location-code/openlocationcode.py
	DESTINATION ${DATADIR}/poor/openlocationcode)
