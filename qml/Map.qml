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
    property var  pois: []
    property var  position: map.gps.position
    property var  positionMarker: PositionMarker {}
    property real scaleX: 0
    property real scaleY: 0
    property var  tiles: []
    property real widthCoords: 0
    property real xcoord: center.longitude - widthCoords/2
    property real ycoord: center.latitude + heightCoords/2
    property real zoomLevelPrev: 8

    AttributionText { id: attribution }
    MapTimer { id: timer }
    MenuButton { id: menuButton }
    Route { id: route }

    Component.onCompleted: {
        // Start periodic tile and position updates.
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
        // gesture.onPanFinished would be better, but seems unreliable.
        map.changed = true;
    }

    onPositionChanged: {
        // Conditionally center map on position if outside center of screen.
        // map.toScreenPosition returns NaN when outside screen.
        if (!map.autoCenter) return;
        var pos = map.toScreenPosition(map.position.coordinate);
        if (!pos.x || pos.x < 0.333 * map.width  || pos.x > 0.667 * map.width ||
            !pos.y || pos.y < 0.333 * map.height || pos.y > 0.667 * map.height)
            map.centerOnPosition();
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
        route.clear();
        route.path = x.map(function(currentValue, index, array) {
            return QtPositioning.coordinate(y[index], x[index]);
        })
        // Queue redraw, don't hang on it.
        route.changed = true;
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
        route.clear();
    }

    function fitViewtoCoordinates(coords) {
        // Set center and zoom so that all points are visible.
        // XXX: This is very slow if there's a lot of points.
        var cx = 0;
        var cy = 0;
        for (var i = 0; i < coords.length; i++) {
            cx += coords[i].longitude;
            cy += coords[i].latitude;
        }
        cx /= coords.length;
        cy /= coords.length;
        map.setCenter(cx, cy);
        while (map.zoomLevel > map.minimumZoomLevel) {
            var allIn = true;
            for (var i = 0; i < coords.length; i++) {
                if (!map.inView(coords[i].longitude,
                                coords[i].latitude)) {
                    allIn = false;
                    break;
                }
            }
            if (allIn) break;
            map.setZoomLevel(map.zoomLevel-1);
        }
    }

    function fitViewToPois() {
        // Set center and zoom so that all points of interest are visible.
        map.fitViewtoCoordinates(map.pois.map(function(x) {
            return x.coordinate;
        }))
    }

    function fitViewToRoute() {
        // Set center and zoom so that the whole route is visible.
        // For simplicity, let's just check the endpoints.
        var coords = [];
        if (route.path.length > 0)
            coords.push(route.path[0]);
        if (route.path.length > 1)
            coords.push(route.path[route.path.length-1]);
        map.fitViewtoCoordinates(coords);
    }

    function getBoundingBox() {
        // Return currently visible [xmin, xmax, ymin, ymax].
        var nw = map.toCoordinate(Qt.point(0, 0));
        var se = map.toCoordinate(Qt.point(map.width, map.height));
        return [nw.longitude, se.longitude, se.latitude, nw.latitude];
    }

    function getCenter() {
        // Return the current center position as [x,y].
        return [map.position.coordinate.longitude,
                map.position.coordinate.latitude];

    }

    function inView(x, y) {
        // Return true if point is in the current view.
        var bbox = map.getBoundingBox();
        return (x >= bbox[0] && x <= bbox[1] &&
                y >= bbox[2] && y <= bbox[3])

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
            map.tiles[i].z = -1
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
        map.changed = true;
        var bbox = map.getBoundingBox();
        map.widthCoords = bbox[1] - bbox[0];
        map.heightCoords = bbox[3] - bbox[2];
        map.scaleX = map.width / map.widthCoords;
        map.scaleY = map.height / map.heightCoords;
        route.redraw();
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
