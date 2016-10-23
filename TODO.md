Poor Maps 0.26
==============

* [x] Add [OSM Scout Server][0.26a] offline tiles, geocoder and nearby
      search – only listed in Poor Maps if you have OSM Scout Server
      installed and will only work if the server is running and you
      have made OpenStreetMap data available for the server (rinigus)
* [x] Increase download thread count to match CPU core count for
      localhost (offline) tile servers
* [x] When navigating, make centering and auto-centering on position
      center the position on the part of the map visible below the
      navigation narrative, and further, if auto-rotate is on, center
      slightly lower so that more map is shown ahead than behind (#14)
* [x] When navigating, auto-rotate to match the route polyline instead
      of bearing calculated from GPS data, which should make the map
      rotate faster after a turn (#13)
* [x] Fix removing an item from search history to not show the removed
      item in the UI after refiltering

[0.26a]: https://openrepos.net/content/rinigus/osm-scout-server
