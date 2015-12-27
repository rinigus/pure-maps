Poor Maps 0.22
==============

* [ ] Bump font size of meters and scalebar
* [ ] Move preferences and about to a pulldown menu
* [ ] Only show one Nominatim geocoder, which will use either MapQuest
      or OpenStreetMap Nominatim behind the scenes (#4)
* [ ] Add a begin navigation button?
* [x] Update Sputnik tile source definition and add Sputnik @2x as
      Sputnik tiles have changed to 512x512 pixels

Poor Maps 1.0
=============

* Enforce destination-driven routing (#5)
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
