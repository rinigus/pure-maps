install(DIRECTORY geomag/geomag
    DESTINATION ${DATADIR}/poor
    FILES_MATCHING PATTERN "*.py")
install(FILES geomag/geomag/model_data/WMM.COF
    DESTINATION ${DATADIR}/poor/geomag/model_data)

if(USE_BUNDLED_GPXPY)
    install(DIRECTORY gpxpy/gpxpy
        DESTINATION ${DATADIR}/thirdparty/gpxpy
        PATTERN "__pycache__" EXCLUDE)
endif()
