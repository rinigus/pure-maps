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
    plugin: MapPlugin {}

    property bool changed: true
    property var gps: PositionSource {}
    property var position: map.gps.position
    property var positionMarker: PositionMarker {}
    property var tiles: []
    property int zoomLevelPrev: -1

    Text {
        id: attribution
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 6
        anchors.right: parent.right
        anchors.rightMargin: 12
        color: "black"
        font.family: "sans"
        font.pixelSize: 13
        font.weight: Font.DemiBold
        opacity: 0.6
        text: ""
        textFormat: Text.PlainText
        z: 100
    }

    Timer {
        id: timer
        interval: 500
        repeat: true
        running: false
        onTriggered: map.changed && map.updateTiles();
    }

    Component.onCompleted: {
        console.log("Map.onCompleted...");
        map.start();
    }

    Keys.onPressed: {
        // Allow zooming with plus and minus keys on the emulator.
        (event.key == Qt.Key_Plus) && map.zoomLevel++;
        (event.key == Qt.Key_Minus) && map.zoomLevel--;
        map.zoomLevelPrev = map.zoomLevel;
    }

    gesture.onPinchFinished: {
        // Round piched zoom level to avoid fuzziness.
        console.log("map.gesture.onPinchFinished: " + map.zoomLevel);
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

    onCenterChanged: map.changed = true;
    onPositionChanged: map.positionMarker.coordinate = map.position.coordinate;

    // Render tile from local image file.
    function renderTile(uid, x, y, zoom, uri) {
        console.log("map.renderTile: " + uid);
        for (var i = 0; i < map.tiles.length; i++) {
            if (map.tiles[i].uid != uid) continue;
            map.tiles[i].coordinate.longitude = x;
            map.tiles[i].coordinate.latitude = y;
            map.tiles[i].uri = uri;
            map.tiles[i].zoomLevel = zoom;
            map.tiles[i].visible = true;
            map.tiles[i].z = 10;
            return;
        }
        console.log("...adding new tile...");
        // Add missing tile to collection.
        var component = Qt.createComponent("Tile.qml");
        var tile = component.createObject(map);
        tile.coordinate = QtPositioning.coordinate(y, x);
        tile.uid = uid;
        tile.uri = uri;
        tile.zoomLevel = zoom;
        tile.z = 10;
        map.tiles.push(tile);
        map.addMapItem(tile);
        console.log("...map.renderTile");
    }

    // Set map copyright etc. attribution text.
    function setAttribution(text) {
        attribution.text = text;
    }

    // Set the current center position.
    function setCenter(x, y) {
        map.center.longitude = x;
        map.center.latitude = y;
    }

    // Set the current zoom level.
    function setZoomLevel(zoom) {
        map.zoomLevel = zoom;
    }

    // Show the tile with given uid.
    function showTile(uid) {
        console.log("map.showTile: " + uid);
        for (var i = 0; i < map.tiles.length; i++) {
            if (map.tiles[i].uid != uid) continue;
            map.tiles[i].visible = true;
            break;
        }
    }

    // Start periodic updates.
    function start() {
        console.log("map.start...");
        map.gps.start();
        timer.start();
    }

    // Stop periodic updates.
    function stop() {
        console.log("map.stop...");
        map.gps.stop();
        timer.stop();
    }

    // Ask the Python backend to download missing tiles.
    function updateTiles() {
        console.log("map.updateTiles...");
        if (!py.ready) return;
        if (map.width <= 0 || map.height <= 0) return;
        if (map.gesture.isPinchActive) return;
        var nw = map.toCoordinate(Qt.point(0, 0));
        var se = map.toCoordinate(Qt.point(map.width, map.height));
        var zoom = Math.floor(map.zoomLevel);
        py.call("poor.app.update_tiles", [nw.longitude,
                                          se.longitude,
                                          se.latitude,
                                          nw.latitude,
                                          zoom], null);

        map.changed = false;
        console.log("...map.updateTiles");
    }
}
