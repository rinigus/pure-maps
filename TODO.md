Poor Maps 0.23
==============

* [ ] Add support for British and American units, i.e. miles/yards and
      miles/feet (not auto-detected, defaults to metric, changeable in
      the preferences dialog)
    - NearbyPage.qml
        * Only saved temporarily to NearbyPage.radius
* [ ] Update Mapbox basemaps?
* [x] Fix clear navigating to clear a bit more

Poor Maps 1.0
=============

* Adapt to QtLocation >= 5.5 API
  [changes](http://doc.qt.io/qt-5/qtlocation-changes.html)
    - Switch to the OSM plugin along with 5.5
      (see Qt bug [#32937](http://bugreports.qt.io/browse/QTBUG-32937))
    - Move menu button to the center?
* Add user interface translations (#1)
* Allow saving POIs for future use (#3)
