Poor Maps 0.25
==============

* [ ] Fix padding, spacing, icon sizes and font sizes to work better
      across different size and different pixel density screens
* [ ] Use [Mapbox's navigation icons][0.25b]
* [x] Include scale in all tile source names, including @1x
* [x] Remove MapQuest Open tile source as tiles are [no longer available][0.25a]
* [x] Add @2x variants of OpenCycleMap and Thunderforest Transport
* [x] Remove Nominatim geocoders
* [x] Add [OpenCage](https://geocoder.opencagedata.com/) and
      [Photon](http://photon.komoot.de/) geocoders and make OpenCage the default
* [x] Handle initial centering and zoom level better on first startup
      if positioning data not available
* [x] Raise API connection timeout to 15 seconds

[0.25a]: http://devblog.mapquest.com/2016/06/15/modernization-of-mapquest-results-in-changes-to-open-tile-access/
[0.25b]: https://www.mapbox.com/blog/directions-icons/
