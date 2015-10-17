Poor Maps 0.21
==============

* [ ] Add Mapzen Search geocoder (a.k.a. Pelias)
* [ ] Add Mapzen Turn-by-Turn router (a.k.a Valhalla)
* [X] Adapt MapQuest Nominatim geocoder to work with recent
      [changes][0.21a] in their terms and API
* [X] Use project-osrm.org again for OSRM routing as Mapzen shut down
      their OSRM instance (we lose pedestrian and bicycle routing)
* [X] Add ÖPNVKarte basemap (OpenStreetMap public transportation)
* [X] Use the HiDPI version of Mapbox Streets basemap by default ([#2][])
* [X] Don't smooth tiles if map auto-rotate is on, but angle zero
* [X] Write config file atomically

[0.21a]: http://devblog.mapquest.com/2015/08/17/mapquest-free-open-license-updates-and-changes/
[#2]: https://github.com/otsaloma/poor-maps/issues/2

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
* Allowing saving POIs for future use (#3)
* Add support for non-SI units (miles, etc.)
