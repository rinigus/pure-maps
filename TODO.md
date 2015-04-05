Poor Maps 0.19.1
================

 * [X] Color matching parts of search history items
 * [ ] Allow searching nearby venues around the center of screen
 * [X] Don't install %doc files (COPYING, README, etc.)
 * [X] Remove python3-base from RPM dependencies
 * [X] Prevent provides in RPM package

Poor Maps 1.0
=============

 * Allow landscape for the map page (need to wait for Qt 5.4.1)
   - <http://bugreports.qt.io/browse/QTBUG-40799>
 * Add user interface translations
   - Strings in QML: mark with `qsTr`, run `lupdate`
   - Strings in Python: mark with `tr`, run `pylupdate`
   - Strings in JSON: ???
   - Selected API calls: send language parameter based on system default
 * Add support for non-SI units (miles, etc.)
   - <http://stackoverflow.com/a/14044413>
 * Move menu button to the center or provide a separate left hand mode
 * Add a QtSensors Compass arrow that shows which way one is facing?
 * Add ability to import POIS or routes from file?
 * Add voice guidance to navigation (espeak?)
