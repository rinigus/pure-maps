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

    property var autoCenter: false
    property var changed: true
    property var gps: PositionSource {}
    property var position: map.gps.position
    property var positionMarker: PositionMarker {}
    property var tiles: []
    property var zoomLevelPrev: -1

    AttributionText { id: attribution }
    MapTimer { id: timer }
    MenuButton { id: menuButton }

    Component.onCompleted: {
        // Start periodic tile and position updates.
        map.start();
    }

    gesture.onPinchFinished: {
        // Round piched zoom level to avoid fuzziness.
        if (map.zoomLevel < map.zoomLevelPrev) {
            map.zoomLevel % 1 < 0.75 ?
                map.zoomLevel = Math.floor(map.zoomLevel) :
                map.zoomLevel = Math.ceil(map.zoomLevel);
        } else if (map.zoomLevel > map.zoomLevelPrev) {
            map.zoomLevel % 1 > 0.25 ?
                map.zoomLevel = Math.ceil(map.zoomLevel) :
                map.zoomLevel = Math.floor(map.zoomLevel);
        } else {
            return;
        }
        for (var i = 0; i < map.tiles.length; i++)
            map.tiles[i].z = Math.max(0, map.tiles[i].z-1);
        map.zoomLevelPrev = map.zoomLevel;
        map.changed = true;
    }

    Keys.onPressed: {
        // Allow zooming with plus and minus keys on the emulator.
        (event.key == Qt.Key_Plus) && map.zoomLevel++;
        (event.key == Qt.Key_Minus) && map.zoomLevel--;
        for (var i = 0; i < map.tiles.length; i++)
            map.tiles[i].z = Math.max(0, map.tiles[i].z-1);
        map.zoomLevelPrev = map.zoomLevel;
        map.changed = true;
    }

    onCenterChanged: {
        // Ensure that tiles are updated after panning.
        // This gets fired ridiculously often, so keep simple.
        // gesture.onPanFinished would be better, but seems unreliable.
        map.changed = true;
    }

    onPositionChanged: {
        // Update position marker to match new position.
        map.positionMarker.coordinate = map.position.coordinate;
        map.autoCenter && (map.center = map.position.coordinate);
    }

    function addTile(uid, x, y, zoom, uri) {
        // Add new tile from local image file to map.
        var component = Qt.createComponent("Tile.qml");
        var tile = component.createObject(map);
        tile.coordinate = QtPositioning.coordinate(y, x);
        tile.uid = uid;
        tile.uri = uri;
        tile.zoomLevel = zoom;
        tile.z = 10;
        if (zoom != Math.floor(map.zoomLevel))
            tile.z--;
        map.tiles.push(tile);
        map.addMapItem(tile);
    }

    function renderTile(uid, x, y, zoom, uri) {
        // Render tile from local image file.
        for (var i = 0; i < map.tiles.length; i++) {
            if (map.tiles[i].uid != uid) continue;
            map.tiles[i].coordinate.longitude = x;
            map.tiles[i].coordinate.latitude = y;
            map.tiles[i].uri = uri;
            map.tiles[i].zoomLevel = zoom;
            map.tiles[i].z = 10;
            if (zoom != Math.floor(map.zoomLevel))
                map.tiles[i].z--;
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
        map.center.longitude = x;
        map.center.latitude = y;
    }

    function setZoomLevel(zoom) {
        // Set the current zoom level.
        map.zoomLevel = zoom;
    }

    function showTile(uid) {
        // Show tile with given uid.
        for (var i = 0; i < map.tiles.length; i++) {
            if (map.tiles[i].uid != uid) continue;
            map.tiles[i].z = 10;
            if (map.tiles[i].zoom != Math.floor(map.zoomLevel))
                map.tiles[i].z--;
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
        py.call_sync("poor.conf.write", []);
        map.gps.stop();
        timer.stop();
    }

    function updateTiles() {
        // Ask the Python backend to download missing tiles.
        if (!py.ready) return;
        if (map.width <= 0 || map.height <= 0) return;
        if (map.gesture.isPinchActive) return;
        var nw = map.toCoordinate(Qt.point(0, 0));
        var se = map.toCoordinate(Qt.point(map.width, map.height));
        py.call_sync("poor.app.update_tiles", [nw.longitude,
                                               se.longitude,
                                               se.latitude,
                                               nw.latitude,
                                               Math.floor(map.zoomLevel)]);

        map.changed = false;
    }
}
