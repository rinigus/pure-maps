if(USE_BUNDLED_GEOMAG)
    file(GLOB GEOMAG_SRC LIST_DIRECTORIES false geomag/geomag/*.py)
    install(FILES ${GEOMAG_SRC} DESTINATION ${DATADIR}/poor/geomag)
    install(FILES geomag/geomag/model_data/WMM.COF
        DESTINATION ${DATADIR}/poor/geomag/model_data)
endif()

file(GLOB FLEXPOLYLINE_SRC LIST_DIRECTORIES false flexible-polyline/python/flexpolyline/*.py)
install(FILES ${FLEXPOLYLINE_SRC} DESTINATION ${DATADIR}/poor/flexpolyline)

if(USE_BUNDLED_GPXPY)
    file(GLOB GPXPY_SRC LIST_DIRECTORIES false gpxpy/gpxpy/*.py)
    install(FILES ${GPXPY_SRC} DESTINATION ${DATADIR}/thirdparty/gpxpy/gpxpy)
endif()
