Poor Maps 0.20
==============

 * [X] Add option to auto-rotate map to match bearing
 * [ ] Add a north arrow visible when auto-rotate is on
 * [X] Allow landscape orientation (requires Sailfish OS 1.1.4
       "Äijänpäivänjärvi" to work correctly)
 * [ ] Add nearby buttons to POI bubbles
 * [X] Add GPS accuracy and speed display
 * [X] Color matching parts of search history items
 * [X] Use long tap instead of plain tap to add POIs
 * [X] Hide POI bubbles on plain tap outside bubble
 * [X] Fix error resetting HTTP connection
 * [X] Ensure that blocking HTTP connection pool operations terminate
       immediately and gracefully on application exit
 * [X] Write configuration to file only once on application exit
 * [X] Don't install %doc files (COPYING, README, etc.)
 * [X] Remove python3-base from RPM dependencies
 * [X] Prevent provides in RPM package

Poor Maps 1.0
=============

 * Use `short_name` for stops once HSL Reittiopas API 1.2.0 is stable?
 * Switch to the QtLocation OSM plugin (need to wait for Qt 5.5)
   - <http://bugreports.qt.io/browse/QTBUG-32937>
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
