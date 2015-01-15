Poor Maps 0.16
==============

 * [X] Center on position when double-tapping map
 * [ ] Toggle auto-centering on position by tapping the position marker?
 * [X] Make cache purge on startup less likely to block
 * [ ] Add manual cache purge actions of different ages?
 * [X] Bump required QtPositioning version to 5.2

Poor Maps 1.0
=============

 * Add support for scaling and retina tiles
 * Add a cover that shows narrative when navigating
 * Add voice guidance (espeak?)
 * Add a QtSensors Compass arrow that shows which way one is facing
 * Add ability to import a route from file
 * Allow landscape for the map when gestures work right
 * Allow layered tilesources (traffic, hillshade, etc.)
 * Add user interface translations
   - Strings in QML: mark with `qStr`, run `lupdate`
   - Strings in Python and JSON: ???
   - Selected API calls: send language parameter based on system default
 * Add support for non-SI units (miles, etc.)
   - <http://stackoverflow.com/a/14044413>
