Poor Maps 0.23
==============

* [ ] Add support for British and American units, i.e. miles/yards and
      miles/feet (not auto-detected, defaults to metric, changeable in
      the preferences dialog)
    - poor.util.format_distance
    - Meters.qml
    - ScaleBar.qml
    - PreferencesPage.qml
    - NearbyPage.qml

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
