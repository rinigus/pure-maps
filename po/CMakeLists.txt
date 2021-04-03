find_program(QT_LCONVERT NAMES lconvert-qt5 lconvert)

set(LANGUAGES cs de_DE el es et fi fr fur hu_HU it nb nl nl_BE pl pt_BR ru sk_SK sl_SI sv zh_CN)
foreach(LANG ${LANGUAGES})
    # Using GETTEXT_PROCESS_PO_FILES's INSTALL_DESTINATION leads to the translations being installed
    # as ${LANG}.gmo, not pure-maps.mo, so we install them manually
    # TODO: install to ${CMAKE_INSTALL_LOCALEDIR} instead
    gettext_process_po_files(${LANG} ALL PO_FILES ${LANG}.po)
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${LANG}.gmo
        DESTINATION ${DATADIR}/locale/${LANG}/LC_MESSAGES/
        RENAME pure-maps.mo)

    add_custom_command(OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/${LANG}.qm
        COMMAND ${QT_LCONVERT} -o ${CMAKE_CURRENT_BINARY_DIR}/${LANG}.qm ${CMAKE_CURRENT_SOURCE_DIR}/${LANG}.po)
    add_custom_target(translations-${LANG} ALL
        DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/${LANG}.qm)
    install(FILES ${CMAKE_CURRENT_BINARY_DIR}/${LANG}.qm
        DESTINATION ${DATADIR}/translations/
        RENAME ${APP_NAME}-${LANG}.qm)
endforeach()

