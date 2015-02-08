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
import QtLocation 5.0
import QtPositioning 5.3
import "."

Map {
    id: map
    anchors.left: app.contentItem.left
    anchors.right: app.contentItem.right
    anchors.top: app.contentItem.bottom
    center: QtPositioning.coordinate(60.169, 24.941)
    gesture.enabled: true
    height: app.bottomMargin
    minimumZoomLevel: 3
    plugin: MapPlugin {}

    property bool autoCenter: false
    property bool centerFound: true
    property bool changed: true
    property var  direction: gps.direction
    property bool hasRoute: false
    property real heightCoords: 0
    property var  maneuvers: []
    property var  menuButton: menuButton
    property var  pois: []
    property var  position: gps.position
    property var  positionMarker: PositionMarker {}
    property bool ready: false
    property var  route: route
    property var  scaleBar: scaleBar
    property real scaleX: 0
    property real scaleY: 0
    property bool showNarrative: true
    property var  statusArea: statusArea
    property var  tiles: []
    property real widthCoords: 0
    property real zoomLevelPrev: 8

    Behavior on center {
        CoordinateAnimation {
            duration: map.ready ? 500 : 0
            easing.type: Easing.InOutQuad
        }
    }

    MapMouseArea {}
    MenuButton { id: menuButton }
    NarrationTimer {}
    Route { id: route }
    ScaleBar { id: scaleBar }
    StatusArea { id: statusArea }

    Timer {
        id: updateTimer
        interval: 500
        repeat: true
        running: app.running
        onTriggered: map.changed && map.updateTiles();
    }

    Timer {
        id: lazyUpdateTimer
        interval: 1000
        repeat: false
        running: false
        onTriggered: map.updateTiles();
    }

    Component.onCompleted: {
        // Load default values and start periodic updates.
        map.initProperties();
    }

    gesture.onPinchFinished: {
        // Round piched zoom level to avoid fuzziness.
        if (map.zoomLevel < map.zoomLevelPrev) {
            map.zoomLevel % 1 < 0.75 ?
                map.setZoomLevel(Math.floor(map.zoomLevel)) :
                map.setZoomLevel(Math.ceil(map.zoomLevel));
        } else if (map.zoomLevel > map.zoomLevelPrev) {
            map.zoomLevel % 1 > 0.25 ?
                map.setZoomLevel(Math.ceil(map.zoomLevel)) :
                map.setZoomLevel(Math.floor(map.zoomLevel));
        }
    }

    onCenterChanged: {
        // Ensure that tiles are updated after panning.
        // This gets fired ridiculously often, so keep simple.
        map.changed = true;
    }

    onHasRouteChanged: {
        // Update keep-alive in case set to 'navigating'.
        app.updateKeepAlive();
    }

    onPositionChanged: {
        if (!map.centerFound) {
            // Center on user's position on first start.
            map.centerFound = true;
            map.centerOnPosition();
        } else if (map.autoCenter && !map.gesture.isPanActive && !map.gesture.isPinchActive) {
            // Center map on position if outside center of screen.
            // map.toScreenPosition returns NaN when outside screen.
            var pos = map.toScreenPosition(map.position.coordinate);
            if (!pos.x || pos.x < 0.333 * map.width  || pos.x > 0.667 * map.width ||
                !pos.y || pos.y < 0.333 * map.height || pos.y > 0.667 * map.height)
                map.centerOnPosition();
        }
    }

    function addManeuvers(maneuvers) {
        /*
         * Add new maneuver markers to map.
         *
         * Expected fields for each item in in maneuvers:
         *  - x: Longitude coordinate of maneuver point
         *  - y: Latitude coordinate of maneuver point
         *  - icon: Name of maneuver icon (optional, defaults to 'alert')
         *  - narrative: Plain text instruction of maneuver
         *  - passive: true if point doesn't require any actual action
         *    (optional, defaults to false)
         *  - duration: Duration (s) of leg following maneuver point
         */
        for (var i = 0; i < maneuvers.length; i++) {
            var component = Qt.createComponent("ManeuverMarker.qml");
            var maneuver = component.createObject(map);
            maneuver.coordinate = QtPositioning.coordinate(maneuvers[i].y, maneuvers[i].x);
            maneuver.icon = maneuvers[i].icon || "alert";
            maneuver.narrative = maneuvers[i].narrative || "";
            maneuver.passive = maneuvers[i].passive || false;
            maneuver.duration = maneuvers[i].duration || 0;
            map.maneuvers.push(maneuver);
            map.addMapItem(maneuver);
        }
        py.call("poor.app.narrative.set_maneuvers", [maneuvers], null);
        map.saveManeuvers();
    }

    function addPois(pois) {
        /*
         * Add new POI markers to map.
         *
         * Expected fields for each item in pois:
         *  - x: Longitude coordinate of point
         *  - y: Latitude coordinate of point
         *  - title: Plain text name by which to refer to point
         *  - text: Text.RichText to show in POI bubble
         *  - link: Hyperlink accessible from POI bubble (optional)
         */
        for (var i = 0; i < pois.length; i++) {
            var component = Qt.createComponent("PoiMarker.qml");
            var poi = component.createObject(map);
            poi.coordinate = QtPositioning.coordinate(pois[i].y, pois[i].x);
            poi.title = pois[i].title || "";
            poi.text  = pois[i].text  || "";
            poi.link  = pois[i].link  || ""
            map.pois.push(poi);
            map.addMapItem(poi);
        }
        map.savePois();
    }

    function addRoute(route) {
        /*
         * Add a polyline to represent a route.
         *
         * Expected fields in route:
         *  - x: Array of route polyline longitude coordinates
         *  - y: Array of route polyline latitude coordinates
         *  - attribution: Plain text router attribution
         *  - mode: Transport mode, "car" or "transit"
         */
        map.clearRoute();
        map.route.setPath(route.x, route.y);
        map.route.attribution = route.attribution || "";
        map.route.mode = route.mode || "car";
        map.route.redraw();
        py.call_sync("poor.app.narrative.set_mode", [route.mode || "car"]);
        py.call("poor.app.narrative.set_route", [route.x, route.y], function() {
            map.hasRoute = true;
        });
        map.saveRoute();
        map.saveManeuvers();
    }

    function centerOnPosition() {
        // Center map on the current position.
        map.setCenter(map.position.coordinate.longitude,
                      map.position.coordinate.latitude);

    }

    function clear() {
        // Remove all point and route markers from the map.
        map.clearPois();
        map.clearRoute();
    }

    function clearPois() {
        // Remove all point of interest from the map.
        for (var i = 0; i < map.pois.length; i++) {
            map.removeMapItem(map.pois[i]);
            map.pois[i].destroy();
        }
        map.pois = [];
        map.savePois();
    }

    function clearRoute() {
        // Remove all route markers from the map.
        for (var i = 0; i < map.maneuvers.length; i++) {
            map.removeMapItem(map.maneuvers[i]);
            map.maneuvers[i].destroy();
        }
        map.maneuvers = [];
        map.route.clear();
        py.call_sync("poor.app.narrative.unset", []);
        map.setRoutingStatus(null);
        map.saveRoute();
        map.saveManeuvers();
        map.hasRoute = false;
    }

    function clearTiles() {
        // Remove all tiles from the map.
        for (var i = 0; i < map.tiles.length; i++) {
            map.removeMapItem(map.tiles[i]);
            map.tiles[i].destroy();
        }
        map.tiles = [];
    }

    function demoteTiles() {
        // Drop basemap tiles to a lower z-level and remove overlays.
        for (var i = map.tiles.length-1; i >= 0; i--) {
            if (map.tiles[i].type == "basemap") {
                map.tiles[i].z = Math.max(1, map.tiles[i].z-1);
            } else {
                map.tiles[i].z = -1;
            }
        }
    }

    function fitViewtoCoordinates(coords) {
        // Set center and zoom so that all points are visible.
        if (coords.length == 0) return;
        var xmin = 360, xmax = -360;
        var ymin = 360, ymax = -360;
        for (var i = 0; i < coords.length; i++) {
            var x = coords[i].longitude;
            var y = coords[i].latitude;
            if (x < xmin) xmin = x;
            if (x > xmax) xmax = x;
            if (y < ymin) ymin = y;
            if (y > ymax) ymax = y;
        }
        map.setCenter((xmin + xmax)/2, (ymin + ymax)/2);
        map.setZoomLevel(map.minimumZoomLevel);
        // Calculate the greatest offset of a single point from the center
        // of the screen and based on that the maximum zoom that will still
        // keep all points visible.
        var xp = 0, yp = 0, offset = 0;
        for (var i = 0; i < coords.length; i++) {
            xp = coords[i].longitude - map.center.longitude;
            yp = coords[i].latitude - map.center.latitude;
            xp = Math.abs(xp / (map.widthCoords/2));
            yp = Math.abs(yp / (map.heightCoords/2));
            if (xp > offset) offset = xp;
            if (yp > offset) offset = yp;
        }
        for (var i = map.zoomLevel; offset < 0.5 && i < 16; i++)
            offset *= 2;
        map.setZoomLevel(i);
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
        if (map.route.path.x.length == 0) return;
        var coords = [];
        for (var i = 0; i < map.route.path.x.length; i = i+10) {
            coords.push(QtPositioning.coordinate(
                map.route.path.y[i], map.route.path.x[i]));
        }
        var x = map.route.path.x[map.route.path.x.length-1];
        var y = map.route.path.y[map.route.path.x.length-1];
        coords.push(QtPositioning.coordinate(y, x));
        map.fitViewtoCoordinates(coords);
    }

    function getBoundingBox() {
        // Return currently visible [xmin, xmax, ymin, ymax].
        var nw = map.toCoordinate(Qt.point(0, 0));
        var se = map.toCoordinate(Qt.point(map.width, map.height));
        return [nw.longitude, se.longitude, se.latitude, nw.latitude];
    }

    function getPosition() {
        // Return the current position as [x,y].
        return [map.position.coordinate.longitude,
                map.position.coordinate.latitude];

    }

    function hidePoiLabels() {
        // Hide label bubble of all POI markers.
        for (var i = 0; i < map.pois.length; i++)
            map.pois[i].labelVisible = false;
    }

    function initProperties() {
        // Load default values and start periodic updates.
        if (!py.ready)
            return py.onReadyChanged.connect(map.initProperties);
        map.autoCenter = app.conf.get("auto_center");
        map.showNarrative = app.conf.get("show_routing_narrative");
        map.setZoomLevel(app.conf.get("zoom"));
        var center = app.conf.get("center");
        if (center[0] == 0.0 && center[1] == 0.0) {
            // Center on user's position on first start.
            map.centerFound = false;
        } else {
            map.centerFound = true;
            map.setCenter(center[0], center[1]);
        }
        map.updateTiles();
        app.updateKeepAlive();
        map.loadPois();
        map.loadRoute();
        map.loadManeuvers();
        map.ready = true;
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

    function renderTile(props) {
        // Render tile from local image file.
        for (var i = 0; i < map.tiles.length; i++) {
            if (map.tiles[i].uid != props.uid) continue;
            map.tiles[i].coordinate.latitude = props.nwy;
            map.tiles[i].coordinate.longitude = props.nwx;
            map.tiles[i].smooth = props.smooth;
            map.tiles[i].type = props.type;
            map.tiles[i].zOffset = props.z;
            map.tiles[i].zoomLevel = props.display_zoom;
            map.tiles[i].uri = props.uri;
            map.tiles[i].setWidth(props);
            map.tiles[i].setHeight(props);
            map.tiles[i].setZ(map.zoomLevel);
            return;
        }
        // Add missing tile to collection.
        var component = Qt.createComponent("Tile.qml");
        var tile = component.createObject(map);
        tile.uid = props.uid;
        map.tiles.push(tile);
        map.addMapItem(tile);
        map.renderTile(props);
    }

    function saveManeuvers() {
        // Save maneuvers to JSON file.
        if (!py.ready) return;
        var data = [];
        for (var i = 0; i < map.maneuvers.length; i++) {
            var maneuver = {};
            maneuver.x = map.maneuvers[i].coordinate.longitude;
            maneuver.y = map.maneuvers[i].coordinate.latitude;
            maneuver.icon = map.maneuvers[i].icon;
            maneuver.narrative = map.maneuvers[i].narrative;
            maneuver.duration = map.maneuvers[i].duration;
            maneuver.passive = map.maneuvers[i].passive;
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
            poi.x = map.pois[i].coordinate.longitude;
            poi.y = map.pois[i].coordinate.latitude;
            poi.title = map.pois[i].title;
            poi.text  = map.pois[i].text;
            poi.link  = map.pois[i].link;
            data.push(poi);
        }
        py.call_sync("poor.storage.write_pois", [data]);
    }

    function saveRoute() {
        // Save route to JSON file.
        if (!py.ready) return;
        if (map.route.path.x && map.route.path.x.length > 0 &&
            map.route.path.y && map.route.path.y.length > 0) {
            var data = {};
            data.x = map.route.path.x;
            data.y = map.route.path.y;
            data.attribution = map.route.attribution;
            data.mode = map.route.mode;
        } else {
            var data = {};
        }
        py.call_sync("poor.storage.write_route", [data]);
    }

    function setCenter(x, y) {
        // Set the current center position.
        if (!x || !y) return;
        // Create a new object to trigger animation and
        // make sure tiles are updated after animation is complete.
        map.center = QtPositioning.coordinate(y, x);
        lazyUpdateTimer.restart();
        map.changed = true;
    }

    function setRoutingStatus(status) {
        // Set values of labels in the navigation status area.
        if (status && map.showNarrative) {
            map.statusArea.destDist  = status.dest_dist || "";
            map.statusArea.destTime  = status.dest_time || "";
            map.statusArea.icon      = status.icon      || "";
            map.statusArea.manDist   = status.man_dist  || "";
            map.statusArea.manTime   = status.man_time  || "";
            map.statusArea.narrative = status.narrative || "";
        } else {
            map.statusArea.destDist  = "";
            map.statusArea.destTime  = "";
            map.statusArea.icon      = "";
            map.statusArea.manDist   = "";
            map.statusArea.manTime   = "";
            map.statusArea.narrative = "";
        }
    }

    function setZoomLevel(zoom) {
        // Set the current zoom level.
        zoom = Math.floor(zoom);
        map.demoteTiles();
        map.zoomLevel = zoom;
        map.zoomLevelPrev = zoom;
        var bbox = map.getBoundingBox();
        map.widthCoords = bbox[1] - bbox[0];
        map.heightCoords = bbox[3] - bbox[2];
        map.scaleX = map.width / map.widthCoords;
        map.scaleY = map.height / map.heightCoords;
        map.route.redraw();
        map.changed = true;
    }

    function showTile(uid) {
        // Show tile with given uid.
        for (var i = 0; i < map.tiles.length; i++) {
            if (map.tiles[i].uid != uid) continue;
            map.tiles[i].setZ(map.zoomLevel);
            break;
        }
    }

    function updateTiles() {
        // Ask the Python backend to download missing tiles.
        if (!py.ready) return;
        if (map.width <= 0 || map.height <= 0) return;
        if (map.gesture.isPinchActive) return;
        var bbox = map.getBoundingBox();
        py.call("poor.app.update_tiles",
                [bbox[0], bbox[1], bbox[2], bbox[3],
                 Math.floor(map.zoomLevel)], null);

        map.widthCoords = bbox[1] - bbox[0];
        map.heightCoords = bbox[3] - bbox[2];
        map.scaleX = map.width / map.widthCoords;
        map.scaleY = map.height / map.heightCoords;
        map.scaleBar.update();
        map.changed = false;
    }
}
