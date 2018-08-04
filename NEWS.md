2018-08-04: WhoGo Maps 1.1
==========================

* Add autocomplete support to Digitransit geocoder (#2)
* Add autocomplete support to OSM Scout geocoder (#47)
* Add autocomplete support to Foursquare venue types
* Add autocomplete support to OSM Scout venue types (#40)
* Add OSM Scout car styles (#43)
* Remove obsolete OSM Scout router module requirement (#45)
* Fix tilt when navigating setting
* Add Brazilian Portuguese translation
* Update translations

2018-06-18: WhoGo Maps 1.0.1
============================

* Make distance units translatable (#39)
* Update translations

2018-06-12: WhoGo Maps 1.0
==========================

* Add Cartago Car map styles
* Render the route polyline below map labels and symbols
* Raise maximum map scale to 2
* Adapt Foursquare provider to API changes
* Prioritise understandable languages in Foursquare tips (#24)
* Allow toggling voice navigation while navigation is active (#32)
* Fix display of non-metric distances in navigation (#29)
* Fix parsing negative coordinates in search query

2018-03-25: WhoGo Maps 0.92
===========================

* Fix clear in main menu to also end navigating (#25)
* Add German, Spanish, Finnish, French, Italian, Dutch, Polish and
  Swedish translations

2018-03-18: WhoGo Maps 0.91
===========================

* Switch map component from QtLocation to Mapbox GL (rinigus)
* Tilt the map when navigating (only vector maps)
* Remove Mapzen geocoder and router due to shutdown of services
* Zoom in instead of centering on position on double-tap
* Add button to center on position
* Add attribution button and associated page
* Show time, not distance remaining to destination in the top right
  corner of the navigation maneuver block (#6)
* Fix broken share position by SMS button
* Bump PyOtherSide dependency to 1.5.1

2017-12-24: Poor Maps 0.34
==========================

* Add voice navigation (rinigus)
* Make Mapzen the default geocoder
* Improve route polyline rendering on HiDPI screens
* Make black map overlays less transparent
* Add donate button to the about page
* Update translations

2017-10-26: Poor Maps 0.33
==========================

* Add support for @3x tiles (#53)
* Add Cartago Streets basemaps @1x, @2x, @3x, @4x (#33)
* Set default basemap based on screen pixel ratio (#52)
* Allow navigation page button labels (begin, reroute, clear) to
  break across lines for better translatability
* Drop rerouting threshold to 100 meters
* Update translations

2017-08-26: Poor Maps 0.32
==========================

* Add support for rerouting (#26, rinigus)
* Redesign navigation status and narrative pages
* Add OSM Scout car day and night maps (rinigus)
* Allow searching by latitude/longitude coordinates, e.g.
  "60.169 24.941" or "60.169,24.941" (period as decimal, any
  non-alphanumeric separator between latitude and longitude)
* Fix auto-centering in landscape in navigation mode to not have
  the position icon overlap with the menu button (#46)
* Do relative requests to download tiles, fixes HSL map
* Fix string escaping in Python calls from QML (#50, rinigus)
* Add Russian translation
* Update translations

2017-07-09: Poor Maps 0.31
==========================

* Add city bikes to the Digitransit router
* Add ferry icon for navigation instructions
* Add hint texts to search screens
* Hide provider attribution behind long tap
* Update translations

2017-06-27: Poor Maps 0.30
==========================

* Merge OSM Scout routers (libosmscout and Valhalla)
* Fix language parameter for Mapzen/Valhalla routers

2017-06-15: Poor Maps 0.29
==========================

* Add support for OSM Scout Server's Valhalla router

2017-02-27: Poor Maps 0.28.4
============================

* Fix route polyline disappearing after minimizing Poor Maps (#35)
* Fix Digitransit router not returning anything if even one of the
  alternatives was fully a walking trip

2017-02-16: Poor Maps 0.28.3
============================

* Add Italian and Polish translations

2017-02-15: Poor Maps 0.28.2
============================

* Work around PyOtherSide's call_sync being broken in Sailfish OS
  2.1.0.9 "Iijoki"

2017-01-21: Poor Maps 0.28.1
============================

* Fix long routes not visible before moving or zooming the map
* Add German (Germany), Spanish (Spain), French, Dutch and Swedish
  translations

2017-01-04: Poor Maps 0.28
==========================

* Add user interface translations (see the file
  [`po/README.md`][0.28a] for details)

[0.28a]: https://github.com/otsaloma/poor-maps/blob/master/po/README.md

2016-12-13: Poor Maps 0.27
==========================

* Replace HSL geocoder and router with ones that use the new
  [Digitransit API][0.27a] (adds geocoding for whole Finland,
  real-time routing and experimental routing for Waltti and whole
  Finland regions, #19)
* Show route summary in the maneuver list page (#28)
* Don't show time remaining in the navigation instruction block
  to avoid overlapping text

[0.27a]: https://digitransit.fi/en/developers/

2016-11-26: Poor Maps 0.26.205
==============================

* Adapt to Nokia/HERE map plugin changes in Sailfish OS 2.0.5 "Haapajoki"
* Fix initial centering on new route sometimes being wrong

2016-11-01: Poor Maps 0.26
==========================

* Add [OSM Scout Server][0.26a] offline tiles, geocoder, nearby
  search and router – only listed in Poor Maps if you have OSM Scout
  Server installed and will only work if the server is running and
  you have made OpenStreetMap data available for the server (rinigus)
* Increase download thread count to match CPU core count for
  localhost (offline) tile servers
* Increase download timeout for localhost (offline) connections
* When navigating, make centering and auto-centering on position
  center the position on the part of the map visible below the
  navigation narrative, and further, if auto-rotate is on, center
  lower so that more map is shown ahead than behind (#14)
* When navigating, auto-rotate to match the route polyline instead
  of bearing calculated from GPS data, which should make the map
  rotate faster after a turn (#13)
* Fix smoothing of maneuver node icons along the route polyline
* Fix removing an item from search history to not show the removed
  item in the UI after refiltering

[0.26a]: https://openrepos.net/content/rinigus/osm-scout-server

2016-09-04: Poor Maps 0.25
==========================

* Fix padding, spacing, icon sizes and font sizes to work better
  across different size and different pixel density screens
* Move the menu button to the bottom center of screen
* Use [Mapbox's navigation icons][0.25b]
* Add scale filters to a pulldown menu in the basemap page
* Remove MapQuest Open tile source as tiles are [no longer available][0.25a]
* Add @2x variants of OpenCycleMap and Thunderforest Transport
* Include scale in all tile source names, including @1x
* Remove Nominatim geocoders
* Add [OpenCage](https://geocoder.opencagedata.com/) and
  [Photon](http://photon.komoot.de/) geocoders and make OpenCage the default
* Use the latest version of the OSRM router API
* Make Mapzen Turn-by-Turn the default router
* Indicate in lists of providers which is the default one
* New design for HSL Journey Planner results page
* Handle initial centering and zoom level better on first startup
  if positioning data not available
* Raise API connection timeout to 15 seconds

[0.25a]: http://devblog.mapquest.com/2016/06/15/modernization-of-mapquest-results-in-changes-to-open-tile-access/
[0.25b]: https://www.mapbox.com/blog/directions-icons/

Poor Maps 0.24
==============

* Add [Mapbox Streets GL][0.24a] and [Mapbox Outdoors GL][0.24b]
  basemaps (tile renders of the new GL styles; differ significantly
  from the previous non-GL styles, so the old ones are kept too,
  at least for now)
* Change the default basemap for new users to Mapbox Streets GL @2x
* Update URLs of HSL basemaps
* Remove Mapbox Emerald basemaps
* Remove OSM Roads basemap

[0.24a]: https://www.mapbox.com/blog/mapbox-streets-redesign/
[0.24b]: https://www.mapbox.com/blog/mapbox-outdoors-redesign-launch/

Poor Maps 0.23
==============

* Add support for British and American units, i.e. miles/yards and
  miles/feet (not auto-detected, defaults to metric, changeable in
  the preferences dialog)
* Add [Digitransit HSL basemap][0.23a] (Finnish public transport tiles)
* Update Mapbox basemap URLs
* Use the basic version of Mapbox Streets
* Fix clear navigating to clear a bit more
* Fix handling of tiles over 1 MB in size

[0.23a]: http://digitransit.fi/en/developers/service-catalogue/apis/map-api/

Poor Maps 0.22
==============

* Only show one Nominatim geocoder, which will use either MapQuest
  or OpenStreetMap Nominatim behind the scenes ([#4])
* Move preferences and about to a pulldown menu
* Move basemaps and overlays under a single menu item
* Make navigation narrative block a bit bigger
* Add begin, pause and clear navigation buttons to the maneuver list page
* Have begin navigation turn on auto-rotate
* Bump font sizes of the scalebar and meters
* Handle lack of positioning data better ([#6])
* Update Sputnik tile source definition and add Sputnik @2x tiles
* Fix search history filtering

[#4]: https://github.com/otsaloma/poor-maps/issues/4
[#6]: https://github.com/otsaloma/poor-maps/issues/6

Poor Maps 0.21.1
================

* Fix cover tile display
* Update OSM Roads basemap URL
* Update ASTER GDEM & SRTM Hillshade overlay URL

Poor Maps 0.21
==============

* Add Mapzen Search geocoder (a.k.a. Pelias)
* Add Mapzen Turn-by-Turn router (a.k.a. Valhalla)
* Adapt MapQuest Nominatim geocoder to work with recent
  [changes][0.21a] in their terms and API
* Use project-osrm.org again for OSRM routing as Mapzen shut down
  their OSRM instance (we lose pedestrian and bicycle routing)
* Add ÖPNVKarte basemap (OpenStreetMap public transportation)
* Use the HiDPI version of Mapbox Streets basemap by default ([#2])
* Show POI bubble for geocoding results by default
* Don't smooth tiles if map auto-rotate is on, but angle zero
* Write config files atomically to avoid data loss in case of crash
* Add new application icon sizes for tablet and whatever else

[0.21a]: http://devblog.mapquest.com/2015/08/17/mapquest-free-open-license-updates-and-changes/
[#2]: https://github.com/otsaloma/poor-maps/issues/2

Poor Maps 0.20.3
================

* Fix tile display with Sailfish OS 1.1.9 "Eineheminlampi"
* Bump qt5-plugin-geoservices-nokia dependency to version shipped
  with Sailfish OS 1.1.9 "Eineheminlampi"

Poor Maps 0.20.2
================

* If search string is a geo URI, parse those coordinates instead of
  sending the query to a geocoding service
* Fix updating progress labels of search results

Poor Maps 0.20.1
================

* Fix broken tile display when tiles being removed at startup by
  cache purge were already being displayed

Poor Maps 0.20
==============

* Add option to auto-rotate map to match bearing
* Add a north arrow, tapping which toggles auto-rotate
* Allow landscape orientation (requires Sailfish OS 1.1.4
  "Äijänpäivänjärvi" to work correctly)
* Add nearby buttons to POI bubbles
* Add positioning accuracy and speed display
* Color matching parts of search history items
* Use long tap instead of plain tap to add POIs
* Hide POI bubbles on plain tap outside bubble
* Fix error resetting HTTP connection
* Ensure that blocking HTTP connection pool operations terminate
  immediately and gracefully on application exit
* Write configuration to file only once on application exit
* Don't install `%doc` files (`COPYING`, `README`, etc.)
* Remove python3-base from RPM dependencies
* Prevent provides in RPM package

Poor Maps 0.19
==============

* Add ability to share one's position or a location by sending
  sms, email, etc. with properly formatted links with coordinates
  (see the main menu and point of interest bubbles)
* Begin navigating (turn on auto-center, zoom to current position)
  by tapping on the maneuver icon of the navigation statusbar
* Hide POI bubbles by tapping on the label part
* Animate position and bearing changes
* Add Mapbox Streets basemaps (both normal size and retina)
* Add Mapbox Emerald basemaps (both normal size and retina)
* Change default basemap for new users to Mapbox Streets
* Keep positioning on for three minutes if Poor Maps has been
  minimized and cover is not active, but there's no GPS lock yet
* Check that downloaded tiles are actually images
* Fix tiles partially overlapping navigation cover
* Rename and rearrange some menu items

Poor Maps 0.18.1
================

* Fix updating tiles after major recentering of map

Poor Maps 0.18
==============

* Add support for transparent overlay tiles
* Add ASTER GDEM & SRTM Hillshade overlay
* Add OpenSeaMap nautical overlay
* Add Mapbox Outdoors basemaps (both normal size and retina)
* Add Sputnik basemap
* Add Thunderforest Transport basemap
* Change default auto-removal of cached tiles from "never"
  to 30 days (only affects new users, if you have used Poor Maps
  prior to 0.18, your existing setting will stay as-is)
* Show tile count in addition to total size on tile cache page
* Don't retry a tile download after three failed attempts
* Fix a tile display efficiency bug introduced in 0.13
* Destroy dynamically created QML objects when no longer used

Poor Maps 0.17
==============

* Add a cover that shows upcoming maneuver when navigating
* Move "Show routing narrative" toggle from the main menu
  to the preferences page

Poor Maps 0.16
==============

* Center on position by double-tapping map
* Toggle auto-center on position by tapping position marker
* Add point of interest by tapping map
* Use an animation when centering map
* Add manual cache purge actions of different ages
* Add support for "retina" tiles that require scaling for display
  (e.g. 512x512 pixel tiles that cover the same geographic area as
  normal 256x256 pixel tiles)
* Add optional "smooth" field to tile source definition files
  (corresponds to QML Image.smooth, defaults to false)
* Bump required QtPositioning version to 5.2 and use the 5.3 API,
  (probably available since Sailfish OS 1.1.0.38 "Uitukka")

Poor Maps 0.15
==============

* Add a mode in which no tiles are downloaded, only cached tiles
  are used (can be activated in the preferences page)
* Center on user's position on first time startup
* Have cache management follow symlinks

Poor Maps 0.14
==============

* Add option to auto-remove old map tiles after specified amount
  of days has passed since the tile download (see the preferences
  page, defaults to never removing tiles)
* Allow tile source definition files to specify a "max_age" field,
  which, if lower, will override the above global threshold
  (use for tiles that change often, e.g. traffic tiles)
* Use Mapzen instead of project-osrm.org for OSRM routing (adds
  bicycle and pedestrian in addition to previous car routing)
    - <https://mapzen.com/blog/osrm-services>
* Fix application icon rasterization

Poor Maps 0.13
==============

* Add support for custom Mercator tile formats
* Add elliptical Mercator tile format
* Add Quadkey tile format
* Allow tile sources where the image format varies by zoom level
* Add descriptions for geocoders, routers and guides
* Fix search field history list filtering to be faster and smoother
* Fix display of cover tiles when in a menu page

Poor Maps 0.12.1
================

* Fix route polyline style resetting when minimizing and restoring
  application with Sailfish OS 1.1.0.38 "Uitukka"

Poor Maps 0.12
==============

* Return to the last viewed page when showing the menu
* Fix tile loading with Sailfish OS 1.1.0.38 "Uitukka"
* Fix route polyline rendering with Sailfish OS 1.1.0.38 "Uitukka"
* Fix dialog headers with Sailfish OS 1.1.0.38 "Uitukka"
* Fix narrative page scrolling with Sailfish OS 1.1.0.38 "Uitukka"
* Fix disappearing search fields with Sailfish OS 1.1.0.38 "Uitukka"
* Update OSM Roads tile source URL

Poor Maps 0.11
==============

* Add an active mini map cover
* Add option to prevent display blanking either always,
  when navigating or never (see "Preferences" from the main menu)
* Allow landscape only for keyboard pages
* Update Hike & Bike Map tile URL

Poor Maps 0.10
==============

* Add buttons to POI bubbles (geocoding and nearby place results)
  to find route to that location and to open Foursquare links
* Add pulldown menu item in route search page to reverse endpoints
* Make POI marker tap target bigger
* Retry geocoding, routing etc. in case of `BrokenPipeError`

Poor Maps 0.9
=============

* Add framework to list nearby places by type (restaurants, etc.)
* Add Foursquare provider for listing nearby places
* Add Nominatim providers for listing nearby places
* Allow tapping on POI markers to show description bubbles
* Add option for the MapQuest Open router to try to avoid tolls
* Clear existing POIs before using "Show all" to add new POIs
  from geocoding results
* Show an error message when connection times out

Poor Maps 0.8
=============

* Add proper icons for the most common turn types
* Add a page listing all maneuvers of a route (accessible by punching
  the routing status bar at the top of the screen)
* Add a scalebar
* Fix OSRM routing narrative on roundabouts

Poor Maps 0.7
=============

* Make position icon into an arrow that shows bearing
* Show all stops along a route with HSL Journey Planner
* Fix routing narrative to consider the closest segment instead of
  the closest route node
* Improve detection of when a routing maneuver point has been passed
  and try to show and hide the narrative better, handling car and
  public transportation differently
* Fix geocoding to zoom to recent results, not all POIs on map
* Fix a tile loading bug introduced in 0.6.1

Poor Maps 0.6.1
===============

* Retry geocoding or routing in case of http.client.BadStatusLine
  error, which probably implies a broken connection, which seems
  to probably happen when a persistent HTTP connection was made,
  but lost due to the device going to sleep
* Only cache successful geocoding and routing results

Poor Maps 0.6
=============

* Add narration of routing maneuvers
* Default routing "From" field to current position
* Use persistent HTTP connections for geocoding and routing too
  (this should especially speed up routing, which usually consists
  of 2-3 requests: 1-2 geocoding and 1 routing)
* Fix HSL Journey Planner maneuver points to actually be
  on the route polyline

Poor Maps 0.5.1
===============

* Work around an OSRM router bug causing it to sometimes not find
  a route at all (see <http://lists.openstreetmap.org/pipermail/osrm-talk/2014-June/000588.html>)
* Simplify MapQuest Open router paths at high zoom levels as well
* Fix partial display of route polyline at high zoom levels

Poor Maps 0.5
=============

* Show maneuver points along the route polyline
* Keep POIs and routes across sessions
* Allow removing places from history (long tap, context menu)
* Add OpenStreetMap Nominatim geocoder (this is mainly
  for redundancy, in case MapQuest Nominatim's servers are down,
  but also the version of Nominatim in use might differ)
* Use a redundant Nominatim geocoder for MapQuest Open and OSRM routers
* Add U-line switch in HSL Journey Planner
* Use stock icons on menu page
* Don't auto-center when panning or pinching
* Fix partial tile loading after changing tile source
* Change default GPS polling to one second
* Remove viewbox and nmax arguments from geocoders
* Add an about page

Poor Maps 0.4
=============

* Add HSL Journey Planner (Helsinki Region Transport public
  transportation router, reittiopas.fi)
* Add "params" argument to routing functions

Poor Maps 0.3
=============

* Add framework to support pluggable routers
* Add MapQuest Open router (car, bicycle, pedestrian)
* Add OSRM router (car)
* Fix tile display when zooming to view multiple found places
* Add "nmax" argument to geocode functions

Poor Maps 0.2
=============

* Add framework to support pluggable geocoders
* Add MapQuest Nominatim geocoder
* New icon (now matches in-app position icon)
* Load user's own tilesources and geocoders from
  `$HOME/.local/share/harbour-poor-maps` instead of the previous
  `$HOME/.config/harbour-poor-maps`
* Allow landscape for menu pages (the map page remains portrait only
  due to some QtLocation problem rotating gestures)
* Bump required PyOtherSide version to 1.2 (included in Sailfish OS
  1.0.4.20 "Ohijärvi" released 2014-03-17)

Poor Maps 0.1
=============

Initial release.
