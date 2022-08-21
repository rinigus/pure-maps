2022-05-01: Pure Maps 3.1.0
===========================

* Redesign no-signal and low-signal icons [eLtMosen]
* Reduce basemap icons size [eLtMosen]
* Improve cmake build scripts
* Update translations
* [sfos] Distinguish between Chum and Jolla Store versions and warn users of limitations
* [sfos] SailJail permissions for Jolla Store version
* [ubuntu touch] Use MapLibre in Ubuntu packaging [jonnius]
* [3.1.1] Adjust route width
* [3.1.1, kirigami] Workaround Kirigami scrollable page bugs


2022-03-16: Pure Maps 3.0.0
============================

* Switch over to Maplibre Native GL based plugin
* Show traffic impact on route
* Update route traffic info while routing
* Switch to SVG based map icons
* Notify the changes in positioning precision during navigation
* Update build scripts [pabloyoyoista]
* Update Ubuntu Touch build scripts [jonnius]

2021-11-22: Pure Maps 2.9.0
===========================

* Add support for HERE through dedicated profile
* Add support for licenses
* Add support for MapTiler
* Add and fix Geoclue2 plugin [fix by tpikonen]
* Set center of the map as a reference point for geocoders
* Disable plugins with missing API keys or licenses
* Indicate when routing has failed
* Fix direction calculations used by positioning source
* Allow to use system-wide Geomag [tpikonen]
* Update Ubuntu Touch packaging [jonnius]
* Try to activate map matching if requested
* Allow to specify accuracy of positioning
* Revise API keys handling
* Update translations
* Bugfixes
* [2.9.2, sfos] Add Chum section to SPEC
* [2.9.2, sfos] Fix My Backup configuration [Karry]

2021-10-17: Pure Maps 2.8.0
===========================

* Add app-specific PositionSource
* Add missing icons for navigation instructions [Lolek]
* Add support for large number of languages by Valhalla
* Drop support for Thunderforest maps
* Adjust dependencies
* Bugfixes and small enhancements
* Update translations

2021-05-22: Pure Maps 2.7.5
===========================

* Allow to specify default font provider
* Require QtPositioning 5.4 and use Qt calculated direction
* Update translations
* [sfos] Adjust packaging for Jolla Store


2021-04-09: Pure Maps 2.7
=========================

* Transition to CMake build system [PureTryOut]
* Update Ubuntu Touch build scripts [jonnius]


2021-03-30: Pure Maps 2.6.5
===========================

* Fix crash induced by absent location coordinates
* Add OpenSlopeMap tiles provider [henning-schild]
* Use DBus API introduced in 2.0 of OSM Scout Server
* [ubuntu touch] Remove tmp in cache workaround [jonnius]
* [ubuntu touch] Packaging improvements [jonnius]
* Update license identifier [Newbyte]
* Bugfixes
* Update translations


2021-02-20: Pure Maps 2.6
=========================

* Route manipulation through selection of point of interest on map
* Use scrollable panel when showing data regarding points of interest
* Show remaining distance and time to the upcoming waypoint on the main screen
* Keep track on arrivals to intermediate waypoints
* Bugfixes
* Update translations

2021-02-03: Pure Maps 2.5
=========================

* Allow to edit route
* Quick route calculation through selection of point of interest
* Better handling of some corner cases in routing
* Refactor page stack implementation
* Add support to Sailfish Harbour MyBackup [atlochowski]
* Show waypoints and destinations using dedicated icons
* Explicitly invoke python3 in check-json [Newbyte]
* Bugfixes
* Update translations

2021-01-05: Pure Maps 2.4
=========================

* Add support for routing waypoints order optimization
* Allow to see more routes from history
* Adjust basemap selector
* Handle type and name separately in nearby search
* Switch default online geocoder to Photon
* Improve MapQuest nearby search support
* Navigation overview page adjustments
* [2.4.0,2.4.1] Update translations
* [2.4.1] Fix GPX routers

2020-12-31: Pure Maps 2.3
=========================

* Add support for intermediate destinations and waypoints
* Adjust naming of Ubuntu Touch platform [jonnius]
* Adjust desktop and appdata to support PureOS Store [dos1]
* Drop support for Digitransit router
* Use text color to indicate interactive elements
* Update translations

2020-12-16: Pure Maps 2.2
=========================

* Show close consecutive maneuvers
* Show roundabout exit number for supported routers
* Fix maneuver icons for OSRM
* Autohide buttons by default for new users
* Reduce vertical requirements of navigation overview bar
* Handle arrival to destination by switching to dedicated mode
* Change DBus registration order
* Rewrite imlpementation determining mode of the application
* Update translations
* Bugfixes, optimizations, and visual adjustments

2020-11-26: Pure Maps 2.1
=========================

* Rewrite navigation guidance
* Navigation direction is preferred for orienting the map
* Switch off navigation mode on reaching destination
* [kirigami,qtcontrols] Support inhibition of screensaver
* Support for external control by DBus
* [2.1.0,2.1.1] Update translations
* Updated packaging for UBPorts [jonnius]
* Matrix channel added

2020-10-31: Pure Maps 2.0
=========================

* Switch to C++ main
* Prevent voice navigation stopping other audio [research by Karry]
* Allow to reverse GPX track
* Refactor command line and DBus handling
* Allow to specify default service providers
* Update packaging scripts for new build system [ubports by jonnius]
* [kirigami,qtcontrols] Add build-in clipboard support
* Update translations

2020-08-24: Pure Maps 1.29
==========================

* Show route using casing to reduce interference with traffic
* Use Audio.NotificationRole for instructions
* [ubports] Fix text update in POIs
* [ubports] Add slim builds [jonnius]
* [ubports] Update docs [jonnius]
* [1.29.0, 1.29.1, 1.29.2] Update translations
* [1.29.2] Update Photon URL

2020-07-02: Pure Maps 1.28
==========================

* Distance formatted according to locale
* Fix race condition while loading multi-language map styles
* Fit to view route and found POIs, rearrange for margins changes
* Rearrange properties and methods to improve code organization
* Require Mapbox GL QML 1.7.0 or higher
* [ubports] Switch to Mapbox GL Native upstream [jonnius]
* [1.28.1] [ubports] fix pasting into search field [StefWe]
* Bugfixes, smaller adjustments
* [1.28.0,1.28.1] Update translations

2020-05-27: Pure Maps 1.27
==========================

* Add support for compass
* Correct for magnetic declination when using compass
* Add support for navigation without screen
* Rearrange preferences page
* [ubports] Add support for GPX loading [StefWe]
* [ubports] Update build config [jonnius]
* [ubports] Packaging and documentation updates [jonnius]
* [kirigami] Move main menu drawer to the right
* [kirigami] Add support for dark themes
* [kirigami,qtcontrols] Make slider touchscreen friendly
* [kirigami] Disable wide layout in forms
* [silica] Switch to KeepAlive 1.2
* Bugfixes, smaller adjustments
* [1.27.0, 1.27.1] Update translations
* [1.27.2] Prepare for the update of Mapbox GL

2019-10-04: Pure Maps 1.26
==========================

* Update Navigation and Follow Me mode GUI
* Link to UBPorts documentation [jonnius]
* Add transportation icons [mosen]
* [silica] Keep text field focus after pressing clear button
* [1.26.0, 1.26.1, 1.26.2] Update translations
* [1.26.2] [kirigami] Update implementation to work with the latest Kirigami
* Bugfixes


2019-09-14: Pure Maps 1.25
==========================

* Optional DBus activation [based on xXSparkeyy's work]
* Search function has current location bias (online providers)
* [silica] Fixing geo handler [based on xXSparkeyy's work]
* [qtcontrols,kirigami] Add clipboard support for location sharing
* [ubports] Fixes in packaging scripts [jonnius]
* Attribution button redesign
* [qtcontrols,kirigami] Improve fallback icons loading
* [1.25.0, 1.25.1] Update translations
* [1.25.0, 1.25.1, 1.25.2] Bugfixes

2019-08-26: Pure Maps 1.24
==========================

* Add UBPorts platform
* Package and bugfixes for UBPorts [jonnius, myii, mateosalta]
* [silica] Use image instead of iconbutton
* Update translations
* Bugfixes

2019-08-25: Pure Maps 1.23
==========================

* Allow to enable/disable smooth position animation
* Add basemap icons [Mosen]
* Stop keepalive, GPS, and timers on shutdown
* [silica] Add cover actions for navigation
* Allow to specify platform-specific mechanism for sending SMS
* Update translations
* Update documentation
* Bugfixes


2019-07-29: Pure Maps 1.22
==========================

* Group maps by provider
* Allow to auto-select specific map based on task
* Allow to auto-select light and dark maps based on sunset/sunrise
* Add support for preferred map language
* Support large selection of HERE maps types
* List recent routes on navigation page
* Move traffic layer above route on Mapbox preview maps
* [kirigami] Stack pages on the right of the map in wide mode
* [kirigami] Highlight selection in list views
* [kirigami] GUI improvements
* [qtcontrols,kirigami] Use system palette
* Update translations

2019-07-01: Pure Maps 1.21
==========================

* Add CS translation [CS translators team]
* Calculate route automatically as soon as possible
* Smooth transition only for high-precision positions
* Add an online map from OpenTopoMap.org [jktjkt]
* QML platform support updates
* [qtcontrols,kirigami] Port Digitransit support
* Smaller GUI changes and fixes
* Packaging updates for Linux
* Update translations
* Bugfixes

2019-05-19: Pure Maps 1.20
==========================

* Add voice prompt at the beginning of navigation
* Make transitions during navigation smooth
* Update voice prompt cache code
* Update translations
* Bugfixes

2019-03-30: Pure Maps 1.19
==========================

* Update icons [mosen]
* Simplify main menu
* Use indicators to show auto-centering, -zoom, and -rotation
* Show current search results on map
* Update translations
* Bugfixes and corrections of strings

2019-03-21: Pure Maps 1.18
==========================

* Redesign of icons and banner [mosen and Fellfrosch]
* Map controls shown as buttons
* Add drag indicator to panels
* Add command line support
* Add DBus interface
* Select closest POI when clicking on a map
* [kirigami] Set map as an expanding page
* [flatpak] Update packaging scripts
* [silica] workaround to show combobox in landscape
* Update translations
* Bugfixes and smaller adjustments

2019-02-25: Pure Maps 1.17
==========================

* Provide feedback on map loading error
* Add automatic zoom
* Add support for full Open Location Code
* Change some icons on information bar
* Notify on missing TTS engine
* Add clear text buttons in text fields
* [kirigami] Updates of multiple controls
* [kirigami,qtcontrols] Redesign preferences page
* [kirigami,qtcontrols] Support hiDPI monitors
* [kirigami] Protect against accidental clicks on map controls
* [silica] Add description to slider control
* [flatpak] Use Kirigami by default
* Update translations
* Bugfixes

2019-02-16: Pure Maps 1.16
==========================

* Add Kirigami platform
* Make Kirigami default platform for Linux Desktop
* Update Mapbox map styles
* Adjust overall information route layout
* [kirigami, qtcontrols] Load icons using Qt icon
* [kirigami, qtcontrols] Add support for translations
* Bugfixes, code cleanup
* [1.16.0, 1.16.1] Update translations


2019-02-02: Pure Maps 1.15
==========================

* Introduce minimal and full controls mode for maps view
* Rearrange buttons on the map view
* Increase position icon contrast [mosen]
* Update translations

2019-01-13: Pure Maps 1.14
==========================

* Rename POIs to bookmarks
* Show overall navigation information on top of the map before navigating
* Adjust main menu
* Update translations
* qtcontrols: Adjust style
* qtcontrols: Add support to geolocation when packaged as Flatpak
* Bugfixes

2019-01-06: Pure Maps 1.13
==========================

* Refactor search functionality
* Provide search functionality while entering locations in navigation and nearby search
* Update translations
* Internal restructuring of POI handling
* qtcontrols: revise search field
* Bugfix: restore ability to see all search results
* Bugfix: remove temporary POIs while browsing them

2018-12-28: Pure Maps 1.12
==========================

* Keep non-bookmarked POIs only until current operation is finished
* Refactor POI panel into generic info panel
* Show current state (such as map selection, search) on info panel
* Allow to finish navigation by swiping navigation bar out
* Update translations
* Bugfix: Fill reverse geocoding result properly

2018-12-13: Pure Maps 1.11
==========================

* Add reverse geocoding
* Move geocoder, guide, and router selection into menus
* Redesign Search page
* Follow Me and Navigation are switched through menus
* Update translations

2018-12-04: Pure Maps 1.10
==========================

* Add support for online and offline profiles
* Add position uncertainty indicator
* Add facility for TTS testing in Preferences
* [1.10.1] Update translations
* [1.10.1] Small bugfix

2018-11-20: Pure Maps 1.9
=========================

* Fix navigation icon in cover (accumulator)
* Replace explicit event handlers with property binding (accumulator)
* Add platform and SDK download instructions to flatpak docs (M4rtinK)
* Add support for personal API keys
* Add shortlisted POIs for fast selection in navigation
* [silica] Add support for light ambiences
* Update POIs in the list on its changes
* Update translations
* Prepare for Flathub release

2018-10-28: Pure Maps 1.8
=========================

* Separate QML code into platform-dependent and platform-independent parts
* Add support for Qt Quick Controls 2
* Add support for packaging using Flatpak
* Fix page stack wrapper bug
* Updated translations

2018-10-04: Pure Maps 1.7
=========================

* Add "follow me" mode
* Add support for routing along GPX (raw and processed)
* Consolidate navigation and other settings in Preferences
* Allow navigation and nearby search to duplicate POIs
* Update translations
* Bugfixes

2018-09-23: Pure Maps 1.6
=========================

* Reworked page stack implementation
* Specify font provider for raster maps
* Update translations
* Other changes
* [1.6.1] Bugfix: Starting operations from PoiInfoPage

2018-09-16: Pure Maps 1.5
=========================

* Switch share link to openstreetmaps.org
* Prepare for adding public transport by Valhalla
* Show full address in POI list
* Allow disabling autocomplete
* Make map rotation optional on start of navigation
* Show route and markers in yellow for osm scout night styles
* Update OSM Scout geocoder data parsing
* Update translations
* Add HERE Maps: traffic and satellite
* Other changes
* [1.5.1] Bugfix: Sharing position
* [1.5.1] Allow selecting maps service on sharing
* [1.5.1] Add support for public transport routing by Valhalla routers

2018-09-03: Pure Maps 1.4
=========================

* Support for storing and editing POIs
* POI details are shown by panel and info page
* Extend data stored for each POI
* Updated scripts for geocoders and guides
* POI information text is in plain text only
* Allow only one POI per location
* List POIs on dedicated page
* Allow using POIs as routing points and nearby reference
* Updated translations
* Bugfix: restore map scale if navigation is stopped via clearing the map
* [1.4.2] Allow to view, edit, and delete POIs from their list
* [1.4.2] Added Greek translation
* [1.4.2] Handle HTTP connections in dedicated threads

2018-08-26: Pure Maps 1.3
=========================

* Show routing options only after destination and origin are available
* Support for Valhalla's options
* Set Stadia Maps router as a default
* Adjust route layer on Mapbox Traffic styles
* Update translations
* Other small changes

2018-08-23: Pure Maps 1.2
=========================

* Add support for map matching via OSM Scout Server
* Add support for styling GUI in accordance with the map
* Rearrange controls in navigation mode and add new controls
* Add support for landscape orientation
* If provided by router, show street name of the upcoming maneuver and signs
* Set configuration for map zoom during navigation
* Add support for a search along the current route (OSM Scout Server, Nearby search)
* Add Stadia Maps as an online Valhalla router provider
* New application icon and graphics used for cover page (Fellfrosch / popanz)
* Remove Cartago maps due to the expected shutdown of the service
* Add English Pirate voice instructions for Valhalla routers (OSM Scout Server and Stadia Maps)

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
