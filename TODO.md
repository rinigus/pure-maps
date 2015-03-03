Poor Maps 0.19
==============

 * [X] Add ability to share one's position or a location by sending
       sms, email, etc. with properly formatted links with coordinates
       (see the main menu and point of interest bubbles)
 * [X] Add Mapbox Streets basemaps (both normal size and retina)
 * [X] Add Mapbox Emerald basemaps (both normal size and retina)
 * [X] Animate position and bearing changes
 * [X] Keep positioning on for three minutes if Poor Maps has been
       minimized and cover is not active, but there's no GPS lock yet
 * [X] Fix tiles partially overlapping navigation cover
 * [X] Check that downloaded tiles are actually images
 * [X] Change default basemap for new users to Mapbox Streets
 * [X] Move about menu item from the main menu to the preferences page

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
