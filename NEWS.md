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
