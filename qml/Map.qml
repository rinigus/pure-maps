/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2014 Osmo Salomaa, 2018 Rinigus
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.0
import QtPositioning 5.4
import MapboxMap 1.0
import "."

import "js/util.js" as Util

MapboxMap {
    id: map
    anchors.fill: parent
    cacheDatabaseDefaultPath: true
    cacheDatabaseStoreSettings: false
    center: QtPositioning.coordinate(49, 13)
    metersPerPixelTolerance: Math.max(0.001, metersPerPixel*0.01) // 1 percent from the current value
    pitch: {
        if (app.mode === modes.explore || app.mode === modes.exploreRoute ||
                app.mode === modes.navigatePost ||
                format === "raster" || !map.autoRotate || !app.conf.tiltWhenNavigating) return 0;
        if (app.mode === modes.navigate) return 50;
        if (app.mode === modes.followMe) return 50;
        return 0; // should never get here
    }
    pixelRatio: styler.themePixelRatio * 1.5
    zoomLevel: 4.0

    property int    animationTime: {
        if (!map.ready) return 0;
        if (app.mode === modes.explore || app.mode === modes.exploreRoute)
            return 1000;
        // support smooth animations for position marker
        // and map center only if GPS is accurate and is desired
        return (gps.accurate && app.conf.smoothPositionAnimationWhenNavigating ? gps.timePerUpdate : 0);
    }
    property bool   autoCenter: false
    property bool   autoRotate: false
    property bool   autoZoom: false
    property bool   cleanMode: app.conf.mapModeCleanOnStart
    property int    counter: 0
    property var    direction: {
        // check if we prefer to use compass
        if (app.conf.compassUse && compass.active) {
            if (app.mode === modes.explore || app.mode === modes.exploreRoute)
                return compass.azimuth;
            // navigation would prefer compass at low speed
            // and if it is for bycicle or pedestrian. speed
            // is already checked when activating compass, so
            // only route mode is needed
            if (app.transportMode === "foot" || app.transportMode === "bicycle")
                return compass.azimuth;
        }
        // direction as calculated along the route
        if (app.navigator.direction!==undefined && app.navigator.direction!==null)
            return app.navigator.direction;
        if (gps.directionValid) return gps.direction;
        return undefined;
    }
    property string firstLabelLayer: ""
    property string firstRouteLayer: ""
    property string format: ""
    property string mapType: {
        if (app.mode === modes.exploreRoute) return "preview";
        else if (app.mode === modes.followMe || app.mode === modes.navigate || app.mode === modes.navigatePost)
            return "guidance";
        return "default";
    }
    property bool   ready: false
    property bool   showNavButtons: false

    readonly property var images: QtObject {
        readonly property string locationDest:  "pure-image-location-dest"
        readonly property string locationEnd:   "pure-image-location-end"
        readonly property string locationStart: "pure-image-location-start"
        readonly property string locationWay:   "pure-image-location-way"
        readonly property string pixel:         "pure-image-pixel"
        readonly property string poi:           "pure-image-poi"
        readonly property string poiBookmarked: "pure-image-poi-bookmarked"
    }

    readonly property var layers: QtObject {
        readonly property string dummies:         "pure-layer-dummies"
        readonly property string locations:       "pure-layer-locations"
        readonly property string maneuvers:       "pure-layer-maneuvers-active"
        readonly property string nodes:           "pure-layer-maneuvers-passive"
        readonly property string pois:            "pure-layer-pois"
        readonly property string poisBookmarked:  "pure-layer-pois-bookmarked"
        readonly property string poisSelected:    "pure-layer-pois-selected"
        readonly property string route:           "pure-layer-route"
        readonly property string routeOutline:    "pure-layer-route-outline"
    }

    readonly property var sources: QtObject {
        readonly property string locations:      "pure-source-locations"
        readonly property string maneuvers:      "pure-source-maneuvers"
        readonly property string pois:           "pure-source-pois"
        readonly property string poisBookmarked: "pure-source-pois-bookmarked"
        readonly property string poisSelected:   "pure-source-pois-selected"
        readonly property string route:          "pure-source-route"
    }

    Behavior on bearing {
        RotationAnimation {
            direction: RotationAnimation.Shortest
            duration: map.ready ? 500 : 0
            easing.type: Easing.Linear
        }
    }

    Behavior on center {
        CoordinateAnimation {
            duration: animationTime
            easing.type: app.mode === modes.explore || app.mode === modes.exploreRoute ? Easing.InOutQuad : Easing.Linear
        }
    }

    Behavior on margins {
        PropertyAnimation {
            duration: map.ready ? 500 : 0
            easing.type: Easing.InOutQuad
        }
    }

    Behavior on pitch {
        NumberAnimation {
            duration: map.ready ? 1000 : 0
            easing.type: Easing.Linear
        }
    }

    MapGestureArea {
        id: gestureArea
        integerZoomLevels: map.format === "raster"
        map: map
    }

    PositionMarker { id: positionMarker }

    Timer {
        // map view mode switch timer
        interval: app.conf.mapModeAutoSwitchTime > 0 ? app.conf.mapModeAutoSwitchTime*1000 : 1000
        repeat: true
        running: !cleanMode && app.conf.mapModeAutoSwitchTime > 0
        onTriggered: {
            if (!cleanMode && app.conf.mapModeAutoSwitchTime > 0)
                cleanMode = true;
        }
    }

    Timer {
        // navigation buttons switch timer
        id: navButtonsTimer
        interval: app.conf.mapModeAutoSwitchTime > 0 ? app.conf.mapModeAutoSwitchTime*1000 : 1000
        repeat: true
        running: map.showNavButtons && app.conf.mapModeAutoSwitchTime > 0
        onTriggered: {
            if (map.showNavButtons && app.conf.mapModeAutoSwitchTime > 0)
                map.showNavButtons = false;
        }
        property var conn: Connections {
            target: app
            onModeChanged: {
                if (app.mode === modes.navigate || app.mode === modes.exploreRoute)
                    map.showNavButtons = true;
                else
                    map.showNavButtons = false;

            }
        }
    }

    Timer {
        // auto zoom
        interval: 1000
        repeat: true
        running: map.autoZoom

        // keeping reference metersPerPixel and zoomLevel. Map does
        // update metersPerPixel with some tolerance to avoid too many
        // updates. So, for calculations, we have to keep reference zoom
        // level and metersPerPixel
        property real mpp: map.metersPerPixel
        property real zmref: map.zoomLevel

        onMppChanged: zmref = map.zoomLevel

        onTriggered: {
            if (!gps.position.speedValid) return;
            var dist = mpp * map.height;
            var speed = gps.position.speed;
            var newZoom = zmref;
            var zstep = 0.1;
            if (speed > 0) newZoom -= Math.log(speed*app.conf.mapZoomAutoTime / dist) / Math.log(2);
            else newZoom = app.conf.mapZoomAutoZeroSpeedZ;
            newZoom = Math.round(newZoom / zstep) * zstep;

            if (newZoom > app.conf.mapZoomAutoZeroSpeedZ) {
                if (map.zoomLevel < app.conf.mapZoomAutoZeroSpeedZ)
                    map.setZoomLevel(app.conf.mapZoomAutoZeroSpeedZ);
            } else if (Math.abs(map.zoomLevel - newZoom) > zstep*0.5)
                map.setZoomLevel(newZoom);
        }
    }

    Timer {
        // daytime bias timer
        interval: 1000*60
        repeat: true
        running: app.conf.basemapAutoLight==="sunrise/sunset" && gps.position.latitudeValid && gps.position.longitudeValid //false

        property bool lastLight: false

        Component.onCompleted: update(true)
        onRunningChanged: update(true)
        onTriggered: update()

        function update(force) {
            if (app.conf.basemapAutoLight!=="sunrise/sunset" || !gps.position.latitudeValid || !gps.position.longitudeValid)
                return;
            py.call("poor.app.sun.day", [gps.position.coordinate.latitude,
                                         gps.position.coordinate.longitude],
                    function(light) {
                        if (force || lastLight !== light) {
                            py.call("poor.app.basemap.set_bias", [{'light': light ? 'day' : 'night'}]);
                            lastLight = light;
                        }
                    });
        }
    }

    Connections {
        target: app
        onModeChanged: setMode()
        onPortraitChanged: map.updateMargins()
        onTransportModeChanged: setBias()
    }

    Connections {
        target: gps
        onPositionChanged: {
            map.autoCenter && map.centerOnPosition();
        }
    }

    Connections {
        target: infoPanel
        onHeightChanged: map.updateMargins()
    }

    Connections {
        target: menuButton
        onHeightChanged: map.updateMargins();
    }

    Connections {
        target: app.navigator
        onRouteChanged: {
            updateRoute();
            updateManeuvers();
        }
        onLocationsChanged: updateLocations()
    }

    Connections {
        target: referenceBlockTop
        onHeightChanged: map.updateMargins();
    }

    Connections {
        target: referenceBlockBottom
        onHeightChanged: map.updateMargins();
    }

    Connections {
        target: pois
        onPoiChanged: map.updatePois()
    }

    Connections {
        target: py
        onBasemapChanged: map.setBasemap();
    }

    Connections {
        target: streetName
        onHeightChanged: map.updateMargins();
    }

    Component.onCompleted: {
        map.initSources();
        map.initIcons();
        map.initLayers();
        map.configureLayers();
        map.initProperties();
        map.updatePois();
        map.updateMargins();
        map.updateRoute();
        map.updateManeuvers();
        map.updateLocations();
        map.setMode();
    }

    onAutoRotateChanged: {
        // Update map rotation to match travel direction.
        map.bearing = map.autoRotate && map.direction ? map.direction : 0;
        map.updateMargins();
    }

    onDirectionChanged: {
        // Update map rotation to match travel direction.
        var direction = map.direction || 0;
        if (map.autoRotate && Math.abs(direction - map.bearing) > 10)
            map.bearing = direction;
    }

    onErrorStringChanged: app.openMapErrorMessage(map.errorString)

    onHeightChanged: map.updateMargins();

    onMapTypeChanged: setBias()

    onStyleJsonChanged: {
        py.call("poor.app.basemap.process_style", [styleJson],
                function (style) {
                    if (style) styleJson = style;
                });
    }

    function centerOnPosition() {
        // Center on the current position.
        map.setCenter( gps.position.coordinate.longitude,
                       gps.position.coordinate.latitude );
    }

    function configureLayers() {
        // Configure layer for selected POI markers.
        map.setPaintProperty(map.layers.poisSelected, "circle-opacity", 0);
        map.setPaintProperty(map.layers.poisSelected, "circle-radius", 16 / map.pixelRatio);
        map.setPaintProperty(map.layers.poisSelected, "circle-stroke-color", styler.route);
        map.setPaintProperty(map.layers.poisSelected, "circle-stroke-opacity", styler.routeOpacity);
        map.setPaintProperty(map.layers.poisSelected, "circle-stroke-width", 13 / map.pixelRatio);
        // Configure layer for non-bookmarked POI markers.
        map.setLayoutProperty(map.layers.pois, "icon-allow-overlap", true);
        map.setLayoutProperty(map.layers.pois, "icon-anchor", "bottom");
        map.setLayoutProperty(map.layers.pois, "icon-image", map.images.poi);
        map.setLayoutProperty(map.layers.pois, "icon-size", 1.0 / map.pixelRatio);
        map.setLayoutProperty(map.layers.pois, "text-anchor", "top");
        map.setLayoutProperty(map.layers.pois, "text-field", "{name}");
        map.setLayoutProperty(map.layers.pois, "text-optional", true);
        map.setLayoutProperty(map.layers.pois, "text-size", 12);
        map.setPaintProperty(map.layers.pois, "text-color", styler.itemFg);
        map.setPaintProperty(map.layers.pois, "text-halo-color", styler.itemBg);
        map.setPaintProperty(map.layers.pois, "text-halo-width", 2);
        // Configure layer for bookmarked POI markers.
        map.setLayoutProperty(map.layers.poisBookmarked, "icon-allow-overlap", true);
        map.setLayoutProperty(map.layers.poisBookmarked, "icon-anchor", "bottom");
        map.setLayoutProperty(map.layers.poisBookmarked, "icon-image", map.images.poiBookmarked);
        map.setLayoutProperty(map.layers.poisBookmarked, "icon-size", 1.0 / map.pixelRatio);
        map.setLayoutProperty(map.layers.poisBookmarked, "text-anchor", "top");
        map.setLayoutProperty(map.layers.poisBookmarked, "text-field", "{name}");
        map.setLayoutProperty(map.layers.poisBookmarked, "text-optional", true);
        map.setLayoutProperty(map.layers.poisBookmarked, "text-size", 12);
        map.setPaintProperty(map.layers.poisBookmarked, "text-color", styler.itemFg);
        map.setPaintProperty(map.layers.poisBookmarked, "text-halo-color", styler.itemBg);
        map.setPaintProperty(map.layers.poisBookmarked, "text-halo-width", 2);
        // Configure layer for route polyline.
        map.setLayoutProperty(map.layers.route, "line-cap", "round");
        map.setLayoutProperty(map.layers.route, "line-join", "round");
        map.setPaintProperty(map.layers.route, "line-color", styler.route);
        map.setPaintProperty(map.layers.route, "line-opacity", styler.routeOpacity);
        map.setPaintProperty(map.layers.route, "line-width", 16 / map.pixelRatio);
        // Configure layer for route casing.
        map.setLayoutProperty(map.layers.routeOutline, "line-cap", "round");
        map.setLayoutProperty(map.layers.routeOutline, "line-join", "round");
        map.setPaintProperty(map.layers.routeOutline, "line-color", styler.route);
        map.setPaintProperty(map.layers.routeOutline, "line-gap-width", 16 / map.pixelRatio);
        map.setPaintProperty(map.layers.routeOutline, "line-opacity", 1 - (1-styler.routeOpacity)/2);
        map.setPaintProperty(map.layers.routeOutline, "line-width", 4 / map.pixelRatio);
        // Configure layer for active maneuver markers.
        map.setPaintProperty(map.layers.maneuvers, "circle-color", styler.maneuver);
        map.setPaintProperty(map.layers.maneuvers, "circle-pitch-alignment", "map");
        map.setPaintProperty(map.layers.maneuvers, "circle-radius", 11 / map.pixelRatio);
        map.setPaintProperty(map.layers.maneuvers, "circle-stroke-color", styler.route);
        map.setPaintProperty(map.layers.maneuvers, "circle-stroke-width", 4 / map.pixelRatio);
        // Configure layer for passive maneuver markers.
        map.setPaintProperty(map.layers.nodes, "circle-color", styler.maneuver);
        map.setPaintProperty(map.layers.nodes, "circle-pitch-alignment", "map");
        map.setPaintProperty(map.layers.nodes, "circle-radius", 5 / map.pixelRatio);
        map.setPaintProperty(map.layers.nodes, "circle-stroke-color", styler.route);
        map.setPaintProperty(map.layers.nodes, "circle-stroke-width", 3 / map.pixelRatio);
        // Configure layer for dummy symbols that knock out road shields etc.
        map.setLayoutProperty(map.layers.dummies, "icon-image", map.images.pixel);
        map.setLayoutProperty(map.layers.dummies, "icon-padding", 20 / map.pixelRatio);
        map.setLayoutProperty(map.layers.dummies, "icon-rotation-alignment", "map");
        map.setLayoutProperty(map.layers.dummies, "visibility", "visible");
        // Configure layer for location markers.
        map.setLayoutProperty(map.layers.locations, "icon-allow-overlap", true);
        map.setLayoutProperty(map.layers.locations, "icon-anchor", "bottom");
        map.setLayoutProperty(map.layers.locations, "icon-image", "{symbol}");
        map.setLayoutProperty(map.layers.locations, "icon-size", 1.0 / map.pixelRatio);
        map.setLayoutProperty(map.layers.locations, "text-anchor", "top");
        map.setLayoutProperty(map.layers.locations, "text-field", "{name}");
        map.setLayoutProperty(map.layers.locations, "text-optional", true);
        map.setLayoutProperty(map.layers.locations, "text-size", 12);
        map.setPaintProperty(map.layers.locations, "text-color", styler.itemFg);
        map.setPaintProperty(map.layers.locations, "text-halo-color", styler.itemBg);
        map.setPaintProperty(map.layers.locations, "text-halo-width", 2);
    }

    function fitViewToPois(pois) {
        // Set center and zoom so that given POIs are visible.
        map.autoCenter = false;
        map.autoRotate = false;
        map.fitView(pois.map(function(poi) {
            return poi.coordinate || QtPositioning.coordinate(poi.y, poi.x);
        }), true);
    }

    function fitViewToRoute() {
        // Set center and zoom so that the whole route is visible.
        map.autoCenter = false;
        map.autoRotate = false;
        map.fitView(app.navigator.route, true);
    }

    function initIcons() {
        var suffix = "";
        if (styler.position) suffix = "-" + styler.position;
        map.addImagePath(map.images.locationDest, Qt.resolvedUrl(app.getIconScaled("icons/marker/flag-dest" + suffix, true)));
        map.addImagePath(map.images.locationEnd, Qt.resolvedUrl(app.getIconScaled("icons/marker/flag-end" + suffix, true)));
        map.addImagePath(map.images.locationStart, Qt.resolvedUrl(app.getIconScaled("icons/marker/flag-start" + suffix, true)));
        map.addImagePath(map.images.locationWay, Qt.resolvedUrl(app.getIconScaled("icons/marker/flag-way" + suffix, true)));
        map.addImagePath(map.images.poi, Qt.resolvedUrl(app.getIconScaled("icons/marker/marker-stroked" + suffix, true)));
        map.addImagePath(map.images.poiBookmarked, Qt.resolvedUrl(app.getIconScaled("icons/marker/marker" + suffix, true)));
        map.addImagePath(map.images.pixel, Qt.resolvedUrl("icons/pixel.png"));
    }

    function initLayers() {
        // Initialize layers for POI markers, route polyline and maneuver markers.
        map.addLayer(map.layers.poisSelected, {"type": "circle", "source": map.sources.poisSelected});
        map.addLayer(map.layers.pois, {"type": "symbol", "source": map.sources.pois});
        map.addLayer(map.layers.poisBookmarked, {"type": "symbol", "source": map.sources.poisBookmarked});
        map.addLayer(map.layers.route, {"type": "line", "source": map.sources.route}, map.firstRouteLayer);
        map.addLayer(map.layers.routeOutline, {"type": "line", "source": map.sources.route}, map.firstLabelLayer);
        map.addLayer(map.layers.maneuvers, {
                         "type": "circle",
                         "source": map.sources.maneuvers,
                         "filter": ["==", "name", "active"],
                     }, map.firstLabelLayer);
        map.addLayer(map.layers.nodes, {
                         "type": "circle",
                         "source": map.sources.maneuvers,
                         "filter": ["==", "name", "passive"],
                     }, map.firstLabelLayer);
        // Add transparent 1x1 pixels at maneuver points to knock out road shields etc.
        // that would otherwise overlap with the above maneuver and node circles.
        map.addLayer(map.layers.dummies, {"type": "symbol", "source": map.sources.maneuvers});
        map.addLayer(map.layers.locations, {"type": "symbol", "source": map.sources.locations});
    }

    function initProperties() {
        // Initialize map properties and restore saved overlays.
        map.setBasemap();
        map.setModeExplore();
        map.setZoomLevel(app.conf.get("zoom"));
        map.autoCenter = app.conf.get("auto_center");
        map.autoRotate = app.conf.get("auto_rotate");
        var center = app.conf.get("center");
        map.setCenter(center[0], center[1]);
        map.ready = true;
    }

    function initSources() {
        // Initialize sources for map overlays.
        map.addSourcePoints(map.sources.poisSelected, []);
        map.addSourcePoints(map.sources.pois, []);
        map.addSourcePoints(map.sources.poisBookmarked, []);
        map.addSourceLine(map.sources.route, []);
        //map.addSourcePoints(map.sources.locations, []);
        map.addSourcePoints(map.sources.maneuvers, []);
    }

    function setBasemap() {
        // Set the basemap to use and related properties.
        map.firstLabelLayer = py.evaluate("poor.app.basemap.first_label_layer");
        map.firstRouteLayer = py.evaluate("poor.app.basemap.first_route_layer");
        map.format = py.evaluate("poor.app.basemap.format");
        map.urlSuffix = py.evaluate("poor.app.basemap.url_suffix");
        var processed = py.call_sync("poor.app.basemap.process_style", []);
        if (processed) map.styleJson = processed;
        else {
            var url = py.evaluate("poor.app.basemap.style_url");
            if (url) map.styleUrl  = url;
            else map.styleJson = py.evaluate("poor.app.basemap.style_json");
        }
        attributionButton.logo = py.evaluate("poor.app.basemap.logo");
        styler.apply(py.evaluate("poor.app.basemap.style_gui"))
        map.initIcons();
        map.initLayers();
        map.configureLayers();
        positionMarker.initIcons();
    }

    function setBias() {
        py.call("poor.app.basemap.set_bias", [{'type': map.mapType,
                                                  'vehicle': app.transportMode}]);
    }

    function setCenter(x, y) {
        // Center on the given coordinates.
        if (!x || !y) return;
        map.center = QtPositioning.coordinate(y, x);
    }

    function setMode() {
        if (app.mode === modes.explore) setModeExplore();
        else if (app.mode === modes.exploreRoute) setModeExploreRoute();
        else if (app.mode === modes.followMe) setModeFollowMe();
        else if (app.mode === modes.navigate) setModeNavigate();
        else if (app.mode === modes.navigatePost) setModeNavigatePost();
        else console.log("Something is terribly wrong - unknown mode in Map.setMode: " + app.mode);
    }

    function setModeExplore() {
        // map used to explore it
        if (app.conf.mapZoomAutoWhenNavigating) map.autoZoom = false;
        map.autoCenter = false;
        map.autoRotate = false;
        if (map.zoomLevel > 14) map.setZoomLevel(14);
        map.setScale(app.conf.get("map_scale"));
    }

    function setModeExploreRoute() {
        // map used to explore it
        if (app.conf.mapZoomAutoWhenNavigating) map.autoZoom = false;
        map.autoCenter = false;
        map.autoRotate = false;
        if (map.zoomLevel > 14) map.setZoomLevel(14);
        map.setScale(app.conf.get("map_scale"));
    }

    function setModeFollowMe() {
        // follow me mode
        var scale = app.conf.get("map_scale_navigation_" + (app.transportMode ? app.transportMode : "car") );
        var zoom = 15 - (scale > 1 ? Math.log(scale)*Math.LOG2E : 0);
        if (map.zoomLevel < zoom) map.setZoomLevel(zoom);
        map.setScale(scale);
        map.centerOnPosition();
        map.autoCenter = true;
        map.autoRotate = app.conf.autoRotateWhenNavigating;
        if (app.conf.mapZoomAutoWhenNavigating) map.autoZoom = true;
    }

    function setModeNavigate() {
        // map during navigation
        var scale = app.conf.get("map_scale_navigation_" + app.transportMode);
        var zoom = 15 - (scale > 1 ? Math.log(scale)*Math.LOG2E : 0);
        if (map.zoomLevel < zoom) map.setZoomLevel(zoom);
        map.setScale(scale);
        map.centerOnPosition();
        map.autoCenter = true;
        map.autoRotate = app.conf.autoRotateWhenNavigating;
        if (app.conf.mapZoomAutoWhenNavigating) map.autoZoom = true;
    }

    function setModeNavigatePost() {
        // map after navigation in post mode
        var scale = app.conf.get("map_scale_navigation_" + app.transportMode);
        var zoom = 15 - (scale > 1 ? Math.log(scale)*Math.LOG2E : 0);
        if (map.zoomLevel < zoom) map.setZoomLevel(zoom);
        map.setScale(scale);
        map.centerOnPosition();
        map.autoCenter = true;
        map.autoRotate = app.conf.autoRotateWhenNavigating;
        if (app.conf.mapZoomAutoWhenNavigating) map.autoZoom = true;
    }

    function setScale(scale) {
        // Set the map scaling via its pixel ratio.
        map.pixelRatio = styler.themePixelRatio * 1.5 * scale;
        map.configureLayers();
        positionMarker.configureLayers();
    }

    function setSelectedPoi(coordinate) {
        if (coordinate===undefined)
            map.updateSourcePoints(map.sources.poisSelected, []);
        else {
            map.updateSourcePoints(map.sources.poisSelected, [coordinate]);
            map.fitView([coordinate], true);
        }
    }

    function _updateLocationsAddPoint(l, name, symbol) {
        // helper function for adding location points
        var p = {};
        p.type = "Feature";
        p.geometry = {"type": "Point", "coordinates": [l.x, l.y]};
        p.properties = {"name": name, "symbol": symbol };
        return p;
    }

    function updateLocations() {
        // Update location markers on the map.
        if (!app.navigator) return;
        var data = {};
        data.type = "FeatureCollection";
        data.features = []
        var locations = app.navigator.locations;
        var counter = 0;
        for (var i=0; i < locations.length; ++i) {
            var l = locations[i];
            var symbol;
            if (l.origin)
                symbol = map.images.locationStart;
            else if (l.final)
                symbol = map.images.locationEnd;
            else if (l.destination)
                symbol = map.images.locationDest;
            else
                symbol = map.images.locationWay;

            var name;
            if (l.origin)
                name = app.tr("Origin");
            else if (l.final)
                name = app.tr("Final destination");
            else if (l.arrived)
                name = app.tr("✓");
            else {
                counter = counter + 1;
                name = app.tr("#%1", counter);
            }

            data.features.push(_updateLocationsAddPoint(l, name, symbol));
        }

        map.updateSource(map.sources.locations,
                         { "type": "geojson", "data": data });
    }

    function updateManeuvers() {
        // Update maneuver marker on the map.
        if (!app.navigator) return;
        var coords = app.navigator.maneuvers.coordinates();
        var names  = app.navigator.maneuvers.names();
        map.updateSourcePoints(map.sources.maneuvers, coords, names);
    }

    function updateMargins() {
        // Calculate new margins and set them for the map.
        var header = referenceBlockTop.height > 0 ? referenceBlockTop.height : map.height*0.05;
        var footer = !app.infoPanelOpen && (app.mode === modes.explore || app.mode === modes.exploreRoute) && menuButton ? menuButton.height + menuButton.anchors.bottomMargin : 0;
        footer += !app.infoPanelOpen && (app.mode === modes.navigate || app.mode === modes.navigatePost || app.mode === modes.followMe) && referenceBlockBottom ? referenceBlockBottom.height : 0;
        footer += !app.infoPanelOpen && (app.mode === modes.navigate || app.mode === modes.navigatePost || app.mode === modes.followMe) && streetName ? streetName.height : 0
        footer += app.infoPanelOpen && infoPanel ? infoPanel.height : 0
        footer = Math.min(footer, map.height / 2.0);

        // If auto-rotate is on, the user is always heading up
        // on the screen and should see more ahead than behind.
        var marginY = (footer*1.0)/map.height;
        var marginHeight = (map.autoRotate ? 0.2 : 1.0) * (1.0*(map.height - header - footer)) / map.height;
        map.margins = Qt.rect(0.05, marginY, 0.9, marginHeight);
    }

    function updatePois() {
        // Update POI markers on the map.
        var regCoor = [];
        var regName = [];
        var bookmarkedCoor = [];
        var bookmarkedName = [];
        for (var i = 0; i < pois.pois.length; i++) {
            if (pois.pois[i].bookmarked) {
                bookmarkedCoor.push(pois.pois[i].coordinate);
                bookmarkedName.push(pois.pois[i].title);
            } else {
                regCoor.push(pois.pois[i].coordinate);
                regName.push(pois.pois[i].title);
            }
        }
        map.updateSourcePoints(map.sources.pois, regCoor, regName);
        map.updateSourcePoints(map.sources.poisBookmarked, bookmarkedCoor, bookmarkedName);
    }

    function updateRoute() {
        // Update route polyline on the map.
        if (app.navigator && app.navigator.route)
            map.updateSourceLine(map.sources.route, app.navigator.route);
        else
            map.updateSourceLine(map.sources.route, []);
    }

}
