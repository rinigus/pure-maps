Poor Maps 0.22
==============

* [x] Only show one Nominatim geocoder, which will use either MapQuest
      or OpenStreetMap Nominatim behind the scenes (#4)
* [x] Move preferences and about to a pulldown menu
* [x] Move basemaps and overlays under a single menu item
* [x] Make navigation narrative block a bit bigger
* [x] Bump font sizes of the scalebar and meters
* [ ] Handle lack of positioning better, e.g. AGPS off (#6)
* [x] Update Sputnik tile source definition and add Sputnik @2x tiles

?

* Add a begin and end navigation buttons
    - Or an instructive label shown for five seconds
* Have begin navigation turn on auto-rotate

Poor Maps 1.0
=============

* Adapt to QtLocation >= 5.5 API
  [changes](http://doc.qt.io/qt-5/qtlocation-changes.html)
    - Switch to the OSM plugin along with 5.5
      (see Qt bug [#32937](http://bugreports.qt.io/browse/QTBUG-32937))
    - Move menu button to the center?
* Use `short_name` for stops once Reittiopas API 1.2.0 is stable?
* Use a userhash once Reittiopas API 1.2.1 is stable?
* Add user interface translations (#1)
* Allow saving POIs for future use (#3)
* Add support for non-SI units (miles, etc.)
