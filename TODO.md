Poor Maps 0.17
==============

 * [X] Add a cover that shows narrative when navigating

Poor Maps 1.0
=============

 * Add voice guidance (espeak?)
 * Add a QtSensors Compass arrow that shows which way one is facing
 * Add ability to import a route from file
 * Allow landscape for the map page (need to wait for Qt 5.4.1)
   - <http://bugreports.qt.io/browse/QTBUG-40799>
 * Allow layered tilesources (traffic, hillshade, etc.)
 * Add user interface translations
   - Strings in QML: mark with `qStr`, run `lupdate`
   - Strings in Python and JSON: ???
   - Selected API calls: send language parameter based on system default
 * Add support for non-SI units (miles, etc.)
   - <http://stackoverflow.com/a/14044413>
