Poor Maps 0.14
==============

 * [X] Add option to auto-remove old map tiles after specified amount
       of days has passed since the tile download (see the preferences
       page, defaults to never removing tiles)
 * [X] Allow tile source definition files to specify a "max_age" field,
       which, if lower, will override the above global threshold
 * [ ] Use Mapzen instead of project-osrm.org for OSRM routing (adds
       bicycle and pedestrian in addition to previous car routing)
       - <https://mapzen.com/blog/osrm-services>

Poor Maps 1.0
=============

 * Add [Photon](http://photon.komoot.de/) geocoder?
 * Add a QtSensors Compass arrow that shows which way one is facing
 * Add a cover that shows narrative when navigating
 * Add ability to import a route from file
 * Add a no-download mode? (see annoying popup
   <http://together.jolla.com/question/53124>)
 * Allow landscape for the map when gestures work right
 * Allow layered tilesources (traffic, hillshade, etc.)
 * Add user interface translations
   - Strings in QML: mark with `qStr`, run `lupdate`
   - Strings in Python and JSON: ???
   - Selected API calls: send language parameter based on system default
 * Add support for non-SI units (miles, etc.)
   - <http://stackoverflow.com/a/14044413>
