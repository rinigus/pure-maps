Poor Maps 1.0
=============

* Use `short_name` for stops once HSL Reittiopas API 1.2.0 is stable?
* Use a userhash once HSL Reittiopas API 1.2.1 is stable?
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
