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

Map {
    id: map
    anchors.fill: parent
    center: QtPositioning.coordinate(0, 0)
    focus: true
    gesture.enabled: true
    plugin: MapPlugin {}
    zoomLevel: 3
    property bool changed: true
    property var tiles: []

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
        interval: 100
        repeat: true
        onTriggered: map.changed && map.updateTiles();
    }

    Component.onCompleted: {
        // XXX: Is this safe at this point?
        py.call("poor.app.send_defaults", [], null);
        timer.start();
    }

    // Allow zooming with plus and minus keys on the emulator.
    Keys.onPressed: {
        (event.key == Qt.Key_Plus) && map.zoomLevel++;
        (event.key == Qt.Key_Minus) && map.zoomLevel--;
    }

    onCenterChanged: map.changed = true;

    onZoomLevelChanged: {
        for (var i = 0; i < map.tiles.length; i++)
            map.tiles[i].visible = false;
        map.changed = true;
    }

    // Render tile from local image file.
    function renderTile(uid, x, y, uri) {
        for (var i = 0; i < map.tiles.length; i++) {
            if (map.tiles[i].uid != uid) continue;
            map.tiles[i].coordinate.longitude = x;
            map.tiles[i].coordinate.latitude = y;
            map.tiles[i].uri = uri;
            map.tiles[i].visible = true;
            return;
        }
        // Add missing tile to collection.
        var component = Qt.createComponent("Tile.qml");
        var tile = component.createObject(map);
        tile.coordinate = QtPositioning.coordinate(y, x);
        tile.uid = uid;
        tile.uri = uri;
        map.tiles.push(tile);
        map.addMapItem(tile);
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

    // Ask the Python backend to download missing tiles.
    function updateTiles() {
        if (map.width <= 0 || map.height <= 0) return;
        var nw = map.toCoordinate(Qt.point(0, 0));
        var se = map.toCoordinate(Qt.point(map.width, map.height));
        py.call("poor.app.update_tiles", [nw.longitude,
                                          se.longitude,
                                          se.latitude,
                                          nw.latitude,
                                          map.zoomLevel], null);

        map.changed = false;
    }
}
