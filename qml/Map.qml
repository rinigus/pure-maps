/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2014 Osmo Salomaa
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
import QtPositioning 5.3
import Sailfish.Silica 1.0
import MapboxMap 1.0
import "."

import "js/util.js" as Util

MapboxMap {
    id: map
    anchors.fill: parent
    cacheDatabaseDefaultPath: true
    cacheDatabaseStoreSettings: false
    center: QtPositioning.coordinate(49, 13)
    pitch: app.navigationActive && format !== "raster" && tiltEnabled ? 60 : 0
    pixelRatio: Theme.pixelRatio * 1.5
    zoomLevel: 4.0

    // Token for Mapbox.com-hosted maps, i.e. sources with mapbox:// URLs.
    accessToken: "pk.eyJ1Ijoib3RzYWxvbWEiLCJhIjoiY2pidTlwMTdhMW9kNzJ4cGMycTh4c216eSJ9._KFWLhzdsKnkTeYwbEHzhg"

    property bool   autoCenter: false
    property bool   autoRotate: false
    property int    counter: 0
    property var    direction: {
        // prefer map matched direction, if available
        if (gps.directionValid) return gps.direction;
        if (app.navigationStatus.direction!==undefined && app.navigationStatus.direction!==null)
            return app.navigationStatus.direction;
        if (gps.directionCalculated) return gps.direction;
        return undefined;
    }
    property string firstLabelLayer: ""
    property string format: ""
    property bool   hasRoute: false
    property var    maneuvers: []
    property var    pois: []
    property var    position: gps.position
    property bool   ready: false
    property var    route: {}
    property bool   tiltEnabled: false

    readonly property var images: QtObject {
        readonly property string pixel: "whogo-image-pixel"
    }

    readonly property var layers: QtObject {
        readonly property string dummies:   "whogo-layer-dummies"
        readonly property string maneuvers: "whogo-layer-maneuvers-active"
        readonly property string nodes:     "whogo-layer-maneuvers-passive"
        readonly property string pois:      "whogo-layer-pois"
        readonly property string route:     "whogo-layer-route"
    }

    readonly property var sources: QtObject {
        readonly property string maneuvers: "whogo-source-maneuvers"
        readonly property string pois:      "whogo-source-pois"
        readonly property string route:     "whogo-source-route"
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
            duration: map.ready && !app.navigationActive ? 500 : 0
            easing.type: Easing.InOutQuad
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

    NarrationTimer {}

    PositionMarker { id: positionMarker }

    Connections {
        target: app.menuButton
        onYChanged: map.updateMargins();
    }

    Connections {
        target: app.navigationBlock
        onHeightChanged: map.updateMargins();
    }

    Connections {
        target: app.navigationInfoBlock
        onHeightChanged: map.updateMargins();
    }

    Connections {
        target: app.streetName
        onHeightChanged: map.updateMargins();
    }

    Connections {
        target: app
        onPortraitChanged: map.updateMargins();
    }

    Component.onCompleted: {
        map.initSources();
        map.initLayers();
        map.configureLayers();
        map.initProperties();
        map.updateMargins();
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

    onHeightChanged: {
        map.updateMargins();
    }

    onPositionChanged: {
        map.autoCenter && map.centerOnPosition();
    }

    function _addManeuver(maneuver) {
        // Add new maneuver marker to the map.
        map.maneuvers.push({
            "coordinate": QtPositioning.coordinate(maneuver.y, maneuver.x),
            "duration": maneuver.duration || 0,
            "icon": maneuver.icon || "flag",
            // Needed to have separate layers via filters.
            "name": maneuver.passive ? "passive" : "active",
            "narrative": maneuver.narrative || "",
            "passive": maneuver.passive || false,
            "sign": maneuver.sign || undefined,
            "street": maneuver.street|| undefined,
            "verbal_alert": maneuver.verbal_alert || "",
            "verbal_post": maneuver.verbal_post || "",
            "verbal_pre": maneuver.verbal_pre || "",
        });
    }

    function addManeuvers(maneuvers) {
        // Add new maneuver markers to the map.
        maneuvers.map(map._addManeuver);
        py.call("poor.app.narrative.set_maneuvers", [maneuvers], null);
        map.updateManeuvers();
        map.saveManeuvers();
    }

    function _addPoi(poi) {
        // Add new POI marker to the map.
        map.pois.push({
            "coordinate": QtPositioning.coordinate(poi.y, poi.x),
            "link": poi.link || "",
            "provider": poi.provider || "",
            "text": poi.text || "",
            "title": poi.title || "",
            "type": poi.type || "",
        });
    }

    function addPois(pois) {
        // Add new POI markers to the map.
        pois.map(map._addPoi);
        map.updatePois();
        map.savePois();
    }

    function addRoute(route, amend) {
        // Add new route polyline to the map.
        amend || map.endNavigating();
        map.clearRoute();
        route.coordinates = route.x.map(function(value, i) {
            return QtPositioning.coordinate(route.y[i], route.x[i]);
        });
        map.route = {
            "coordinates": route.coordinates || [],
            "language": route.language || "en",
            "mode": route.mode || "car",
            "provider": route.provider || "",
            "x": route.x,
            "y": route.y
        };
        py.call("poor.app.narrative.set_mode", [route.mode || "car"], null);
        py.call("poor.app.narrative.set_route", [route.x, route.y], function() {
            map.hasRoute = true;
        });
        map.updateRoute();
        map.saveRoute();
        map.saveManeuvers();
        app.navigationStarted = !!amend;
    }

    function beginNavigating() {
        // Set UI to navigation mode.
        var scale = app.conf.get("map_scale_navigation_" + route.mode);
        var zoom = 15 - (scale > 1 ? Math.log(scale)*Math.LOG2E : 0);
        map.setScale(scale);
        map.zoomLevel < zoom && map.setZoomLevel(zoom);
        map.centerOnPosition();
        map.autoCenter = true;
        map.autoRotate = true;
        map.tiltEnabled = app.conf.get("tilt_when_navigating");
        map.initVoiceNavigation();
        app.navigationActive = true;
        app.navigationPageSeen = true;
        app.navigationStarted = true;
        app.rerouteConsecutiveErrors = 0;
        app.reroutePreviousTime = -1;
        app.rerouteTotalCalls = 0;
    }

    function centerOnPosition() {
        // Center on the current position.
        map.setCenter(
            map.position.coordinate.longitude,
            map.position.coordinate.latitude);
    }

    function clear() {
        // Remove all markers from the map.
        app.navigationActive = false;
        map.clearPois();
        map.clearRoute();
    }

    function clearPois() {
        // Remove all POI markers from the map.
        hidePoiBubbles();
        map.pois = [];
        map.updatePois();
        map.savePois();
    }

    function clearRoute() {
        // Remove route polyline from the map.
        map.maneuvers = [];
        map.route = {};
        py.call("poor.app.narrative.unset", [], null);
        app.navigationStatus.clear();
        map.hasRoute = false;
        map.updateManeuvers();
        map.updateRoute();
        map.saveManeuvers();
        map.saveRoute();
    }

    function configureLayers() {
        // Configure layer for POI markers.
        map.setPaintProperty(map.layers.pois, "circle-opacity", 0);
        map.setPaintProperty(map.layers.pois, "circle-radius", 32 / map.pixelRatio);
        map.setPaintProperty(map.layers.pois, "circle-stroke-color", app.styler.route);
        map.setPaintProperty(map.layers.pois, "circle-stroke-opacity", app.styler.routeOpacity);
        map.setPaintProperty(map.layers.pois, "circle-stroke-width", 13 / map.pixelRatio);
        // Configure layer for route polyline.
        map.setLayoutProperty(map.layers.route, "line-cap", "round");
        map.setLayoutProperty(map.layers.route, "line-join", "round");
        map.setPaintProperty(map.layers.route, "line-color", app.styler.route);
        map.setPaintProperty(map.layers.route, "line-opacity", app.styler.routeOpacity);
        map.setPaintProperty(map.layers.route, "line-width", 22 / map.pixelRatio);
        // Configure layer for active maneuver markers.
        map.setPaintProperty(map.layers.maneuvers, "circle-color", app.styler.maneuver);
        map.setPaintProperty(map.layers.maneuvers, "circle-pitch-alignment", "map");
        map.setPaintProperty(map.layers.maneuvers, "circle-radius", 11 / map.pixelRatio);
        map.setPaintProperty(map.layers.maneuvers, "circle-stroke-color", app.styler.route);
        map.setPaintProperty(map.layers.maneuvers, "circle-stroke-opacity", app.styler.routeOpacity);
        map.setPaintProperty(map.layers.maneuvers, "circle-stroke-width", 8 / map.pixelRatio);
        // Configure layer for passive maneuver markers.
        map.setPaintProperty(map.layers.nodes, "circle-color", app.styler.maneuver);
        map.setPaintProperty(map.layers.nodes, "circle-pitch-alignment", "map");
        map.setPaintProperty(map.layers.nodes, "circle-radius", 5 / map.pixelRatio);
        map.setPaintProperty(map.layers.nodes, "circle-stroke-color", app.styler.route);
        map.setPaintProperty(map.layers.nodes, "circle-stroke-opacity", app.styler.routeOpacity);
        map.setPaintProperty(map.layers.nodes, "circle-stroke-width", 8 / map.pixelRatio);
        // Configure layer for dummy symbols that knock out road shields etc.
        map.setLayoutProperty(map.layers.dummies, "icon-image", map.images.pixel);
        map.setLayoutProperty(map.layers.dummies, "icon-padding", 20 / map.pixelRatio);
        map.setLayoutProperty(map.layers.dummies, "icon-rotation-alignment", "map");
        map.setLayoutProperty(map.layers.dummies, "visibility", "visible");
    }

    function endNavigating() {
        // Restore UI from navigation mode.
        map.autoCenter = false;
        map.autoRotate = false;
        map.tiltEnabled = app.conf.get("tilt_when_navigating");
        map.zoomLevel > 14 && map.setZoomLevel(14);
        map.setScale(app.conf.get("map_scale"));
        app.navigationActive = false;
    }

    function fitViewToPois(pois) {
        // Set center and zoom so that given POIs are visible.
        map.autoCenter = false;
        map.autoRotate = false;
        map.fitView(pois.map(function(poi) {
            return poi.coordinate || QtPositioning.coordinate(poi.y, poi.x);
        }));
    }

    function fitViewToRoute() {
        // Set center and zoom so that the whole route is visible.
        map.autoCenter = false;
        map.autoRotate = false;
        map.fitView(map.route.coordinates);
    }

    function getDestination() {
        // Return coordinates of the route destination.
        var destination = map.route.coordinates[map.route.coordinates.length - 1];
        return [destination.longitude, destination.latitude];
    }

    function getPoiProviders(type) {
        // Return list of providers for POIs of given type.
        return map.pois.filter(function(poi) {
            return poi.type === type && poi.provider;
        }).map(function(poi) {
            return poi.provider;
        }).filter(function(provider, index, self) {
            return self.indexOf(provider) === index;
        });
    }

    function getPosition() {
        // Return the coordinates of the current position.
        return [map.position.coordinate.longitude, map.position.coordinate.latitude];
    }

    function hidePoiBubble(poi) {
        // Hide the bubble of given POI.
        if (!poi.bubble) return;
        map.removeLocationTracking(poi.bubble.trackerId);
        poi.bubble.destroy();
        poi.bubble = null;
    }

    function hidePoiBubbles() {
        // Hide label bubbles of all POI markers.
        map.pois.map(hidePoiBubble);
    }

    function initLayers() {
        // Initialize layers for POI markers, route polyline and maneuver markers.
        map.addLayer(map.layers.pois, {"type": "circle", "source": map.sources.pois});
        map.addLayer(map.layers.route, {"type": "line", "source": map.sources.route}, map.firstLabelLayer);
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
        map.addImagePath(map.images.pixel, Qt.resolvedUrl("icons/pixel.png"));
        map.addLayer(map.layers.dummies, {"type": "symbol", "source": map.sources.maneuvers});
    }

    function initProperties() {
        // Initialize map properties and restore saved overlays.
        if (!py.ready) return py.onReadyChanged.connect(map.initProperties);
        map.setScale(app.conf.get("map_scale"));
        map.setBasemap();
        map.setZoomLevel(app.conf.get("zoom"));
        map.autoCenter = app.conf.get("auto_center");
        map.autoRotate = app.conf.get("auto_rotate");
        var center = app.conf.get("center");
        map.setCenter(center[0], center[1]);
        map.loadPois();
        map.loadRoute();
        map.loadManeuvers();
        map.ready = true;
    }

    function initSources() {
        // Initialize sources for map overlays.
        map.addSourcePoints(map.sources.pois, []);
        map.addSourceLine(map.sources.route, []);
        map.addSourcePoints(map.sources.maneuvers, []);
    }

    function initVoiceNavigation() {
        // Initialize a TTS engine for the current routing instructions.
        if (app.conf.get("voice_navigation")) {
            var args = [map.route.language, app.conf.get("voice_gender")];
            py.call_sync("poor.app.narrative.set_voice", args);
            app.notification.flash(app.tr("Voice navigation on"));
        } else {
            py.call_sync("poor.app.narrative.set_voice", [null, null]);
        }
    }

    function loadManeuvers() {
        // Restore maneuver markers from JSON file.
        if (!py.ready) return;
        py.call("poor.storage.read_maneuvers", [], function(data) {
            data && data.length > 0 && map.addManeuvers(data);
        });
    }

    function loadPois() {
        // Restore POI markers from JSON file.
        if (!py.ready) return;
        py.call("poor.storage.read_pois", [], function(data) {
            data && data.length > 0 && map.addPois(data);
        });
    }

    function loadRoute() {
        // Restore route polyline from JSON file.
        if (!py.ready) return;
        py.call("poor.storage.read_route", [], function(data) {
            data.x && data.x.length > 0 && map.addRoute(data);
        });
    }

    function saveManeuvers() {
        // Save maneuver markers to JSON file.
        if (!py.ready) return;
        var data = Util.pointsToJson(map.maneuvers);
        py.call_sync("poor.storage.write_maneuvers", [data]);
    }

    function savePois() {
        // Save POI markers to JSON file.
        if (!py.ready) return;
        var data = Util.pointsToJson(map.pois);
        py.call_sync("poor.storage.write_pois", [data]);
    }

    function saveRoute() {
        // Save route polyline to JSON file.
        if (!py.ready) return;
        var data = Util.polylineToJson(map.route);
        py.call_sync("poor.storage.write_route", [data]);
    }

    function setBasemap() {
        // Set the basemap to use and related properties.
        if (!py.ready) return;
        map.firstLabelLayer = py.evaluate("poor.app.basemap.first_label_layer");
        map.format = py.evaluate("poor.app.basemap.format");
        map.urlSuffix = py.evaluate("poor.app.basemap.url_suffix");
        py.evaluate("poor.app.basemap.style_url") ?
            (map.styleUrl  = py.evaluate("poor.app.basemap.style_url")) :
            (map.styleJson = py.evaluate("poor.app.basemap.style_json"));
        app.attributionButton.logo = py.evaluate("poor.app.basemap.logo");
        app.styler.apply(py.evaluate("poor.app.basemap.style_gui"))
        map.initLayers();
        map.configureLayers();
        positionMarker.initIcons();
    }

    function setCenter(x, y) {
        // Center on the given coordinates.
        if (!x || !y) return;
        map.center = QtPositioning.coordinate(y, x);
    }

    function setScale(scale) {
        // Set the map scaling via its pixel ratio.
        map.pixelRatio = Theme.pixelRatio * 1.5 * scale;
        map.configureLayers();
        positionMarker.configureLayers();
    }

    function showPoiBubble(poi) {
        // Show a bubble for the given POI.
        if (poi.bubble) return;
        var component = Qt.createComponent("PoiBubble.qml");
        var bubble = component.createObject(map, {
            "coordinate": poi.coordinate,
            "link": poi.link,
            "text": poi.text,
            "title": poi.title,
            "trackerId": "poi-%1".arg(++map.counter),
        });
        map.trackLocation(bubble.trackerId, bubble.coordinate);
        poi.bubble = bubble;
    }

    function toggleAutoCenter() {
        // Turn auto-center on or off.
        if (map.autoCenter) {
            map.autoCenter = false;
            notification.flash(app.tr("Auto-center off"));
        } else {
            map.autoCenter = true;
            notification.flash(app.tr("Auto-center on"));
            map.centerOnPosition();
        }
    }

    function togglePoiBubble(poi) {
        // Show or hide a bubble for the given POI.
        poi.bubble ? map.hidePoiBubble(poi) : map.showPoiBubble(poi);
    }

    function updateManeuvers() {
        // Update maneuver marker on the map.
        var coords = Util.pluck(map.maneuvers, "coordinate");
        var names  = Util.pluck(map.maneuvers, "name");
        map.updateSourcePoints(map.sources.maneuvers, coords, names);
    }

    function updateMargins() {
        // Calculate new margins and set them for the map.
        var header = app.navigationBlock ? app.navigationBlock.height : 0;
        var footer = app.menuButton ? app.menuButton.height : 0;
        if (app.navigationActive) {
            footer = app.portrait && app.navigationInfoBlock ? app.navigationInfoBlock.height : 0;
            footer += app.streetName ? app.streetName.height : 0
        }
        // If auto-rotate is on, the user is always heading up
        // on the screen and should see more ahead than behind.
        var marginY = map.autoRotate ? footer/map.height : 0.05;
        var marginHeight = map.autoRotate ?
            0.2 * (map.height - header - footer) / map.height :
            0.9 * (map.height - header) / map.height;
        map.margins = Qt.rect(0.05, marginY, 0.9, marginHeight);
    }

    function updatePois() {
        // Update POI markers on the map.
        var coords = Util.pluck(map.pois, "coordinate");
        map.updateSourcePoints(map.sources.pois, coords);
    }

    function updateRoute() {
        // Update route polyline on the map.
        map.updateSourceLine(map.sources.route, map.route.coordinates);
    }

}
