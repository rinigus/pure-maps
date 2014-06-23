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
import QtPositioning 5.0
import "."

Map {
    id: map
    anchors.fill: parent
    center: QtPositioning.coordinate(60.169, 24.941)
    focus: true
    gesture.enabled: true
    minimumZoomLevel: 3
    plugin: MapPlugin {}

    property bool autoCenter: false
    property bool changed: true
    property var  gps: PositionSource {}
    property real heightCoords: 0
    property var  maneuvers: []
    property var  pois: []
    property var  position: map.gps.position
    property var  positionMarker: PositionMarker {}
    property real scaleX: 0
    property real scaleY: 0
    property var  tiles: []
    property real widthCoords: 0
    property real zoomLevelPrev: 8

    AttributionText { id: attribution }
    MapTimer { id: timer }
    MenuButton { id: menuButton }
    Route { id: route }

    Component.onCompleted: {
        // Load default values and start periodic updates.
        py.onReadyChanged.connect(function() {
            map.setAttribution(py.evaluate("poor.app.tilesource.attribution"));
            map.setAutoCenter(py.evaluate("poor.conf.auto_center"));
            var center = py.evaluate("poor.conf.center");
            map.setCenter(center[0], center[1]);
            map.setZoomLevel(py.evaluate("poor.conf.zoom"));
        });
        map.start();
        map.zoomLevelPrev = map.zoomLevel;
    }

    gesture.onPinchFinished: {
        // Round piched zoom level to avoid fuzziness.
        if (map.zoomLevel < map.zoomLevelPrev) {
            map.zoomLevel % 1 < 0.75 ?
                map.setZoomLevel(Math.floor(map.zoomLevel)):
                map.setZoomLevel(Math.ceil(map.zoomLevel));
        } else if (map.zoomLevel > map.zoomLevelPrev) {
            map.zoomLevel % 1 > 0.25 ?
                map.setZoomLevel(Math.ceil(map.zoomLevel)):
                map.setZoomLevel(Math.floor(map.zoomLevel));
        }
    }

    Keys.onPressed: {
        // Allow zooming with plus and minus keys on the emulator.
        (event.key == Qt.Key_Plus)  && map.setZoomLevel(map.zoomLevel+1);
        (event.key == Qt.Key_Minus) && map.setZoomLevel(map.zoomLevel-1);
    }

    onCenterChanged: {
        // Ensure that tiles are updated after panning.
        // This gets fired ridiculously often, so keep simple.
        map.changed = true;
    }

    onPositionChanged: {
        // Conditionally center map on position if outside center of screen.
        // map.toScreenPosition returns NaN when outside screen.
        if (!map.autoCenter) return;
        if (map.gesture.isPanActive) return;
        if (map.gesture.isPinchActive) return;
        var pos = map.toScreenPosition(map.position.coordinate);
        if (!pos.x || pos.x < 0.333 * map.width  || pos.x > 0.667 * map.width ||
            !pos.y || pos.y < 0.333 * map.height || pos.y > 0.667 * map.height)
            map.centerOnPosition();
    }

    function addManeuver(props) {
        // Add new maneuver marker to map.
        var component = Qt.createComponent("Maneuver.qml");
        var maneuver = component.createObject(map);
        maneuver.coordinate = QtPositioning.coordinate(props.y, props.x);
        map.maneuvers.push(maneuver);
        map.addMapItem(maneuver);
    }

    function addPoi(x, y) {
        // Add new point of interest marker to map.
        var component = Qt.createComponent("PoiMarker.qml");
        var poi = component.createObject(map);
        poi.coordinate = QtPositioning.coordinate(y, x);
        map.pois.push(poi);
        map.addMapItem(poi);
    }

    function addRoute(x, y) {
        // Add a polyline to represent a route.
        for (var i = 0; i < map.maneuvers.length; i++)
            map.removeMapItem(map.maneuvers[i]);
        map.maneuvers = [];
        route.clear();
        route.setPath(x, y);
        route.redraw();
    }

    function addTile(uid, x, y, zoom, uri) {
        // Add new tile from local image file to map.
        var component = Qt.createComponent("Tile.qml");
        var tile = component.createObject(map);
        tile.uid = uid;
        tile.coordinate = QtPositioning.coordinate(y, x);
        tile.zoomLevel = zoom;
        tile.uri = uri;
        tile.z = (zoom == Math.floor(map.zoomLevel)) ? 10 : 9;
        map.tiles.push(tile);
        map.addMapItem(tile);
    }

    function centerOnPosition() {
        // Center map on the current position.
        map.setCenter(map.position.coordinate.longitude,
                      map.position.coordinate.latitude);

    }

    function clear() {
        // Remove all point and line markers from map.
        for (var i = 0; i < map.pois.length; i++)
            map.removeMapItem(map.pois[i]);
        map.pois = [];
        for (var i = 0; i < map.maneuvers.length; i++)
            map.removeMapItem(map.maneuvers[i]);
        map.maneuvers = [];
        route.clear();
    }

    function fitViewtoCoordinates(coords) {
        // Set center and zoom so that all points are visible.
        if (coords.length == 0) return;
        var cx = 0, cy = 0;
        for (var i = 0; i < coords.length; i++) {
            cx += coords[i].longitude;
            cy += coords[i].latitude;
        }
        cx /= coords.length;
        cy /= coords.length;
        map.setCenter(cx, cy);
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
        // Math.log2 would be useful here!
        var zoom = map.zoomLevel;
        while (offset < 0.5 && zoom < 16) {
            offset *= 2;
            zoom++;
        }
        map.setZoomLevel(zoom);
    }

    function fitViewToPois() {
        // Set center and zoom so that all points of interest are visible.
        var coords = []
        for (var i = 0; i < map.pois.length; i++)
            coords[i] = map.pois[i].coordinate;
        map.fitViewtoCoordinates(coords);
    }

    function fitViewToRoute() {
        // Set center and zoom so that the whole route is visible.
        // For simplicity, let's just check the endpoints.
        var coords = [];
        if (route.path.x.length > 0) {
            var x = route.path.x[0];
            var y = route.path.y[0];
            coords.push(QtPositioning.coordinate(y, x));
        }
        var n = route.path.x.length;
        if (n > 1) {
            var x = route.path.x[n-1];
            var y = route.path.y[n-1];
            coords.push(QtPositioning.coordinate(y, x));
        }
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

    function renderTile(uid, x, y, zoom, uri) {
        // Render tile from local image file.
        for (var i = 0; i < map.tiles.length; i++) {
            if (map.tiles[i].uid != uid) continue;
            map.tiles[i].coordinate.longitude = x;
            map.tiles[i].coordinate.latitude = y;
            map.tiles[i].zoomLevel = zoom;
            map.tiles[i].uri = uri;
            map.tiles[i].z = (zoom == Math.floor(map.zoomLevel)) ? 10 : 9;
            return;
        }
        // Add missing tile to collection.
        map.addTile(uid, x, y, zoom, uri);
    }

    function resetTiles() {
        // Hide all map tiles from view.
        for (var i = 0; i < map.tiles.length; i++)
            map.removeMapItem(map.tiles[i]);
        map.tiles = [];
    }

    function setAttribution(text) {
        // Set map copyright etc. attribution text.
        attribution.text = text;
    }

    function setAutoCenter(autoCenter) {
        // Set to keep centering map on GPS position.
        map.autoCenter = autoCenter;
    }

    function setCenter(x, y) {
        // Set the current center position.
        if (!x || !y) return;
        map.center.longitude = x;
        map.center.latitude = y;
        map.changed = true;
    }

    function setZoomLevel(zoom) {
        // Set the current zoom level.
        for (var i = 0; i < map.tiles.length; i++)
            map.tiles[i].z = Math.max(0, map.tiles[i].z-1);
        map.zoomLevel = zoom;
        map.zoomLevelPrev = zoom;
        var bbox = map.getBoundingBox();
        map.widthCoords = bbox[1] - bbox[0];
        map.heightCoords = bbox[3] - bbox[2];
        map.scaleX = map.width / map.widthCoords;
        map.scaleY = map.height / map.heightCoords;
        route.redraw();
        map.changed = true;
    }

    function showTile(uid) {
        // Show tile with given uid.
        for (var i = 0; i < map.tiles.length; i++) {
            if (map.tiles[i].uid != uid) continue;
            map.tiles[i].z = (map.tiles[i].zoomLevel ==
                              Math.floor(map.zoomLevel)) ? 10 : 9;

            break;
        }
    }

    function start() {
        // Start periodic tile and position updates.
        map.gps.start();
        timer.start();
    }

    function stop() {
        // Stop periodic tile and position updates.
        // Write conf, since in case of crash atexit is not run.
        if (py.ready) {
            py.call_sync("poor.conf.write", []);
            py.call_sync("poor.app.history.write", []);
        }
        map.gps.stop();
        timer.stop();
    }

    function updateTiles() {
        // Ask the Python backend to download missing tiles.
        if (!py.ready) return;
        if (map.width <= 0 || map.height <= 0) return;
        if (map.gesture.isPinchActive) return;
        var bbox = map.getBoundingBox();
        py.call("poor.app.update_tiles", [bbox[0], bbox[1], bbox[2], bbox[3],
                                          Math.floor(map.zoomLevel)], null);

        map.widthCoords = bbox[1] - bbox[0];
        map.heightCoords = bbox[3] - bbox[2];
        map.scaleX = map.width / map.widthCoords;
        map.scaleY = map.height / map.heightCoords;
        map.changed = false;
    }
}
