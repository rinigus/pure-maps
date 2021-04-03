file(GLOB GEOMAG_SRC LIST_DIRECTORIES false geomag/geomag/*.py)
install(FILES ${GEOMAG_SRC} DESTINATION ${DATADIR}/poor/geomag)
install(FILES geomag/geomag/model_data/WMM.COF
    DESTINATION ${DATADIR}/poor/geomag/model_data)

if(USE_BUNDLED_GPXPY)
    file(GLOB GPXPY_SRC LIST_DIRECTORIES false gpxpy/gpxpy/*.py)
    install(FILES ${GPXPY_SRC} DESTINATION ${DATADIR}/poor/gpxpy)
endif()
