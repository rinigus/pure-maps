Poor Maps 0.18
==============

 * [X] Add support for transparent overlay tiles
 * [X] Add ASTER GDEM & SRTM Hillshade overlay
 * [X] Add OpenSeaMap nautical overlay
 * [X] Add Sputnik basemap
 * [X] Add Thunderforest Transport basemap
 * [ ] Change default auto-removal of cached tiles from "never" to XXX
 * [ ] Show tile count in addition to size on tile cache page
 * [X] Don't retry a tile download after three failed attempts
 * [X] Fix a tile display efficiency bug introduced in 0.13
 * [ ] Destroy dynamically created QML objects when no longer used

 * Remove tile loading and display related debug printing
 * Check UI changes

Poor Maps 1.0
=============

 * Add a QtSensors Compass arrow that shows which way one is facing
 * Add ability to import a route from file
 * Add voice guidance (espeak?)
 * Allow landscape for the map page (need to wait for Qt 5.4.1)
   - <http://bugreports.qt.io/browse/QTBUG-40799>
 * Add user interface translations
   - Strings in QML: mark with `qStr`, run `lupdate`
   - Strings in Python and JSON: ???
   - Selected API calls: send language parameter based on system default
 * Add support for non-SI units (miles, etc.)
   - <http://stackoverflow.com/a/14044413>
