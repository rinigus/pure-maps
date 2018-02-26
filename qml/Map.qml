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
    pixelRatio: Theme.pixelRatio * 1.5
    zoomLevel: 4.0

    // Token for Mapbox maps, i.e. sources with mapbox:// URLs.
    accessToken: "pk.eyJ1Ijoib3RzYWxvbWEiLCJhIjoiY2pidTlwMTdhMW9kNzJ4cGMycTh4c216eSJ9._KFWLhzdsKnkTeYwbEHzhg"

    property bool   autoCenter: false
    property bool   autoRotate: false
    property int    counter: 0
    property var    direction: app.navigationDirection || gps.direction
    property var    directionPrev: 0
    property string firstLabelLayer: ""
    property bool   hasRoute: false
    property var    maneuvers: []
    property var    pois: []
    property var    position: gps.position
    property bool   ready: false
    property var    route: Route {}

    readonly property string layerManeuvers:  "whogo-layer-maneuvers"
    readonly property string layerPois:       "whogo-layer-pois"
    readonly property string layerRoute:      "whogo-layer-route"
    readonly property string sourceManeuvers: "whogo-source-maneuvers"
    readonly property string sourcePois:      "whogo-source-pois"
    readonly property string sourceRoute:     "whogo-source-route"

    Behavior on bearing {
        RotationAnimation {
            direction: RotationAnimation.Shortest
            duration: map.ready ? 500 : 0
            easing.type: Easing.Linear
        }
    }

    Behavior on center {
        CoordinateAnimation {
            duration: map.ready ? 500 : 0
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

    MapGestureArea { map: map }
    NarrationTimer {}
    PositionMarker { id: positionMarker }

    Connections {
        target: app.navigationBlock
        onHeightChanged: map.updateMargins();
    }

    Connections {
        target: app.menuButton
        onYChanged: map.updateMargins();
    }

    Component.onCompleted: {
        map.initSources();
        map.initLayers();
        map.initProperties();
        map.updateMargins();
    }

    onAutoRotateChanged: {
        // Update map rotation to match travel direction.
        map.bearing = map.autoRotate && map.direction ? map.direction : 0;
        updateMargins();
    }

    onDirectionChanged: {
        // Update map rotation to match travel direction.
        if (!map.autoRotate) return;
        var direction = map.direction || 0;
        if (Util.angleDifference(direction, map.directionPrev) > 10) {
            map.bearing = direction;
            map.directionPrev = direction;
        }
    }

    onHasRouteChanged: {
        // Update keep-alive in case set to "navigating".
        app.updateKeepAlive();
    }

    onHeightChanged: {
        map.updateMargins();
    }

    onPositionChanged: {
        // Recenter map so that position is at the center of the screen.
        map.autoCenter && map.centerOnPosition();
    }

    function addManeuvers(maneuvers) {
        // Add new maneuver markers to map.
        for (var i = 0; i < maneuvers.length; i++) {
            map.maneuvers.push({
                "coordinate": QtPositioning.coordinate(maneuvers[i].y, maneuvers[i].x),
                "duration": maneuvers[i].duration || 0,
                "icon": maneuvers[i].icon || "flag",
                "narrative": maneuvers[i].narrative || "",
                "passive": maneuvers[i].passive || false,
                "verbalAlert": maneuvers[i].verbal_alert || "",
                "verbalPost": maneuvers[i].verbal_post || "",
                "verbalPre": maneuvers[i].verbal_pre || ""
            });
        }
        py.call("poor.app.narrative.set_maneuvers", [maneuvers], null);
        map.updateManeuvers();
        map.saveManeuvers();
    }

    function addPois(pois) {
        // Add new POI markers to map.
        for (var i = 0; i < pois.length; i++) {
            map.pois.push({
                "coordinate": QtPositioning.coordinate(pois[i].y, pois[i].x),
                "link": pois[i].link || "",
                "text": pois[i].text || "",
                "title": pois[i].title || ""
            });
        }
        map.updatePois();
        map.savePois();
    }

    function addRoute(route, amend) {
        // Add a polyline to represent a route.
        amend || map.endNavigating();
        map.clearRoute();
        map.route.x = route.x;
        map.route.y = route.y;
        map.route.attribution = route.attribution || "";
        map.route.language = route.language || "en";
        map.route.mode = route.mode || "car";
        py.call_sync("poor.app.narrative.set_mode", [route.mode || "car"]);
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
        map.zoomLevel < 15 && map.setZoomLevel(15);
        map.centerOnPosition();
        map.autoCenter = true;
        map.autoRotate = true;
        map.initVoiceNavigation();
        app.navigationActive = true;
        app.navigationPageSeen = true;
        app.navigationStarted = true;
        app.rerouteConsecutiveErrors = 0;
        app.reroutePreviousTime = -1;
        app.rerouteTotalCalls = 0;
    }

    function centerOnPosition() {
        // Center map on the current position.
        map.setCenter(map.position.coordinate.longitude,
                      map.position.coordinate.latitude);

    }

    function clear() {
        // Remove all POI and route markers from the map.
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
        // Remove all route markers from the map.
        map.maneuvers = [];
        map.route.clear();
        py.call_sync("poor.app.narrative.unset", []);
        app.navigationStatus.clear();
        map.hasRoute = false;
        map.updateManeuvers();
        map.updateRoute();
        map.saveManeuvers();
        map.saveRoute();
    }

    function endNavigating() {
        // Restore UI from navigation mode.
        map.autoCenter = false;
        map.autoRotate = false;
        map.zoomLevel > 14 && map.setZoomLevel(14);
        app.navigationActive = false;
    }

    function fitViewtoCoordinates(coords) {
        // Set center and zoom so that given coordinates are visible.
        map.autoCenter = false;
        map.autoRotate = false;
        map.fitView(coords);
    }

    function fitViewToPois(pois) {
        // Set center and zoom so that given POIs are visible.
        var coords = [];
        for (var i = 0; i < pois.length; i++)
            coords.push(QtPositioning.coordinate(pois[i].y, pois[i].x));
        map.fitViewtoCoordinates(coords);
    }

    function fitViewToRoute() {
        // Set center and zoom so that the whole route is visible.
        // For performance reasons, include only a subset of points.
        if (map.route.x.length === 0) return;
        var coords = [];
        for (var i = 0; i < map.route.x.length; i = i + 10)
            coords.push(QtPositioning.coordinate(
                map.route.y[i], map.route.x[i]));
        var x = map.route.x[map.route.x.length-1];
        var y = map.route.y[map.route.x.length-1];
        coords.push(QtPositioning.coordinate(y, x));
        map.fitViewtoCoordinates(coords);
    }

    function getPosition() {
        // Return the current position as [x, y].
        return [map.position.coordinate.longitude,
                map.position.coordinate.latitude];

    }

    function hidePoiBubble(poi) {
        // Hide label bubble of given POI marker.
        for (var i = 0; i < map.pois.length; i++) {
            if (!map.pois[i].bubble) continue;
            if (map.pois[i].coordinate != poi.coordinate) continue;
            map.removeLocationTracking(map.pois[i].bubble.trackerId);
            map.pois[i].bubble.destroy();
            map.pois[i].bubble = false;
        }
    }

    function hidePoiBubbles() {
        // Hide label bubbles of all POI markers.
        for (var i = 0; i < map.pois.length; i++) {
            if (!map.pois[i].bubble) continue;
            map.removeLocationTracking(map.pois[i].bubble.trackerId);
            map.pois[i].bubble.destroy();
            map.pois[i].bubble = false;
        }
    }

    function initLayers() {
        // Initialize layer for POI markers.
        var params = {"type": "circle", "source": map.sourcePois};
        map.addLayer(map.layerPois, params);
        map.setPaintProperty(map.layerPois, "circle-opacity", 0);
        map.setPaintProperty(map.layerPois, "circle-radius", 12);
        map.setPaintProperty(map.layerPois, "circle-stroke-color", "#0540ff");
        map.setPaintProperty(map.layerPois, "circle-stroke-opacity", 0.5);
        map.setPaintProperty(map.layerPois, "circle-stroke-width", 5);
        // Initialize layer for route polyline.
        var params = {"type": "line", "source": map.sourceRoute};
        map.addLayer(map.layerRoute, params);
        map.setLayoutProperty(map.layerRoute, "line-cap", "round");
        map.setLayoutProperty(map.layerRoute, "line-join", "round");
        map.setPaintProperty(map.layerRoute, "line-color", "#0540ff");
        map.setPaintProperty(map.layerRoute, "line-opacity", 0.5);
        map.setPaintProperty(map.layerRoute, "line-width", 8);
        // Initialize layer for maneuver markers.
        var params = {"type": "circle", "source": map.sourceManeuvers};
        map.addLayer(map.layerManeuvers, params);
        map.setPaintProperty(map.layerManeuvers, "circle-color", "white");
        map.setPaintProperty(map.layerManeuvers, "circle-radius", 4);
        map.setPaintProperty(map.layerManeuvers, "circle-stroke-color", "#0540ff");
        map.setPaintProperty(map.layerManeuvers, "circle-stroke-opacity", 0.5);
        map.setPaintProperty(map.layerManeuvers, "circle-stroke-width", 3);
    }

    function initProperties() {
        // Load default values and saved overlays.
        if (!py.ready)
            return py.onReadyChanged.connect(map.initProperties);
        map.setBasemap();
        map.setZoomLevel(app.conf.get("zoom"));
        map.autoCenter = app.conf.get("auto_center");
        map.autoRotate = app.conf.get("auto_rotate");
        var center = app.conf.get("center");
        map.setCenter(center[0], center[1]);
        app.updateKeepAlive();
        map.loadPois();
        map.loadRoute();
        map.loadManeuvers();
        map.ready = true;
    }

    function initSources() {
        // Initialize map overlay sources with blank data.
        map.addSourcePoints(map.sourcePois, []);
        map.addSourceLine(map.sourceRoute, []);
        map.addSourcePoints(map.sourceManeuvers, []);
    }

    function initVoiceNavigation() {
        // Initialize TTS engine for the current route.
        if (app.conf.get("voice_navigation")) {
            var args = [route.language, app.conf.get("voice_gender")];
            py.call_sync("poor.app.narrative.set_voice", args);
            app.notification.flash(app.tr("Voice navigation on"));
        } else {
            py.call_sync("poor.app.narrative.set_voice", [null, null]);
        }
    }

    function loadManeuvers() {
        // Load maneuvers from JSON file.
        if (!py.ready) return;
        py.call("poor.storage.read_maneuvers", [], function(data) {
            if (data && data.length > 0)
                map.addManeuvers(data);
        });
    }

    function loadPois() {
        // Load POIs from JSON file.
        if (!py.ready) return;
        py.call("poor.storage.read_pois", [], function(data) {
            if (data && data.length > 0)
                map.addPois(data);
        });
    }

    function loadRoute() {
        // Load route from JSON file.
        if (!py.ready) return;
        py.call("poor.storage.read_route", [], function(data) {
            if (data.x && data.x.length > 0 &&
                data.y && data.y.length > 0)
                map.addRoute(data);
        });
    }

    function popPoiBubble(poi) {
        // Show a detail bubble for the given POI.
        if (poi.bubble) return;
        var component = Qt.createComponent("PoiMarker.qml");
        var bubble = component.createObject(map, {
            "coordinate": poi.coordinate,
            "link": poi.link,
            "text": poi.text,
            "title": poi.title,
            "trackerId": "poi-%1".arg(++map.counter)
        });
        map.trackLocation(bubble.trackerId, poi.coordinate);
        poi.bubble = bubble;
    }

    function saveManeuvers() {
        // Save maneuvers to JSON file.
        if (!py.ready) return;
        var data = [];
        for (var i = 0; i < map.maneuvers.length; i++) {
            var maneuver = {};
            maneuver.duration = map.maneuvers[i].duration;
            maneuver.icon = map.maneuvers[i].icon;
            maneuver.narrative = map.maneuvers[i].narrative;
            maneuver.passive = map.maneuvers[i].passive;
            maneuver.verbal_alert = map.maneuvers[i].verbalAlert;
            maneuver.verbal_post = map.maneuvers[i].verbalPost;
            maneuver.verbal_pre = map.maneuvers[i].verbalPre;
            maneuver.x = map.maneuvers[i].coordinate.longitude;
            maneuver.y = map.maneuvers[i].coordinate.latitude;
            data.push(maneuver);
        }
        py.call_sync("poor.storage.write_maneuvers", [data]);
    }

    function savePois() {
        // Save POIs to JSON file.
        if (!py.ready) return;
        var data = [];
        for (var i = 0; i < map.pois.length; i++) {
            var poi = {};
            poi.link = map.pois[i].link;
            poi.text = map.pois[i].text;
            poi.title = map.pois[i].title;
            poi.x = map.pois[i].coordinate.longitude;
            poi.y = map.pois[i].coordinate.latitude;
            data.push(poi);
        }
        py.call_sync("poor.storage.write_pois", [data]);
    }

    function saveRoute() {
        // Save route to JSON file.
        if (!py.ready) return;
        var data = {};
        if (map.route.x && map.route.x.length > 0 &&
            map.route.y && map.route.y.length > 0) {
            data.attribution = map.route.attribution;
            data.language = map.route.language;
            data.mode = map.route.mode;
            data.x = map.route.x;
            data.y = map.route.y;
        }
        py.call_sync("poor.storage.write_route", [data]);
    }

    function setBasemap() {
        // Set basemap to use and related properties.
        if (!py.ready) return;
        map.urlSuffix = py.evaluate("poor.app.basemap.url_suffix");
        map.firstLabelLayer = py.evaluate("poor.app.basemap.first_label_layer");
        py.evaluate("poor.app.basemap.style_url") ?
            (map.styleUrl  = py.evaluate("poor.app.basemap.style_url")) :
            (map.styleJson = py.evaluate("poor.app.basemap.style_json"));
        app.attribution.logo = py.evaluate("poor.app.basemap.logo");
        app.attribution.text = py.evaluate("poor.app.basemap.attribution");
    }

    function setCenter(x, y) {
        // Set the current center position.
        // Create a new object to trigger animation.
        if (!x || !y) return;
        map.center = QtPositioning.coordinate(y, x);
    }

    function toggleAutoCenter() {
        // Toggle auto-center with a visible notification.
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
        // Show or hide a detail bubble for the given POI.
        poi.bubble ? map.hidePoiBubble(poi) : map.popPoiBubble(poi);
    }

    function updateManeuvers() {
        // Update maneuver marker source.
        var maneuvers = [];
        for (var i = 0; i < map.maneuvers.length; i++)
            maneuvers.push(map.maneuvers[i].coordinate);
        map.updateSourcePoints(map.sourceManeuvers, maneuvers);
    }

    function updateMargins() {
        // Calculate new margins and set them for the map.
        var header = app.navigationBlock ? app.navigationBlock.height : 0;
        var footer = app.menuButton ? app.menuButton.height + Theme.paddingSmall : 0;
        var content = map.height - header - footer;
        // If auto-rotate is on, the user is always heading up
        // on the screen and should see more ahead than behind.
        var marginY = (map.autoRotate ? footer/map.height : 0) + 0.05;
        var marginHeight = (map.autoRotate ? 0.2 : 0.9) * content/map.height;
        map.margins = Qt.rect(0.05, marginY, 0.9, marginHeight);
    }

    function updatePois() {
        // Update POI marker source.
        var pois = [];
        for (var i = 0; i < map.pois.length; i++)
            pois.push(map.pois[i].coordinate);
        map.updateSourcePoints(map.sourcePois, pois);
    }

    function updateRoute() {
        // Update route polyline source.
        var route = [];
        for (var i = 0; i < map.route.x.length; i++)
            route.push(QtPositioning.coordinate(map.route.y[i], map.route.x[i]));
        map.updateSourceLine(map.sourceRoute, route);
    }

}
