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
import Sailfish.Silica 1.0
import "."

/*
 * Construct the default map cover by duplicating tiles and a position marker
 * from the center part of the map. This is achieved by simply mapping
 * the pixel coordinates of individual tiles and markers to a smaller cover
 * considered to be centered on the map.
 */

Cover {
    id: cover
    property bool ready: false
    property var tiles: []
    Timer {
        interval: 1000
        repeat: true
        running: !ready ||
            cover.status == Cover.Activating ||
            cover.status == Cover.Active
        triggeredOnStart: true
        onTriggered: {
            if (app.inMenu) return;
            cover.updateTiles();
            cover.updatePositionMarker();
        }
    }
    Rectangle {
        // Matches the default QtLocation Map background.
        anchors.fill: parent
        color: "#e6e6e6"
    }
    Item {
        id: positionMarker
        height: movingImage.height
        width: movingImage.width
        z: 100
        Image {
            id: movingImage
            rotation: map.direction || 0
            source: "icons/position-direction.png"
            visible: map.direction || false
        }
        Image {
            id: stillImage
            anchors.centerIn: movingImage
            source: "icons/position.png"
            visible: !movingImage.visible
        }
    }
    function addTile() {
        // Add a new blank tile to the end of collection.
        var component = Qt.createComponent("CoverTile.qml");
        cover.tiles.push(component.createObject(cover));
    }
    function mapXToCoverX(x) {
        // Convert map pixel X-coordinate to cover equivalent.
        return x - (map.width - cover.width) / 2;
    }
    function mapYToCoverY(y) {
        // Convert map pixel Y-coordinate to cover equivalent.
        return y - (map.height - cover.height) / 2;
    }
    function updatePositionMarker() {
        // Update position marker from map equivalent.
        positionMarker.x = cover.mapXToCoverX(map.positionMarker.x);
        positionMarker.y = cover.mapYToCoverY(map.positionMarker.y);
    }
    function updateTiles() {
        // Update cover map tiles from map equivalents.
        for (var i = 0; i < map.tiles.length; i++) {
            if (cover.tiles.length <= i) cover.addTile();
            cover.tiles[i].source = map.tiles[i].uri;
            cover.tiles[i].x = cover.mapXToCoverX(map.tiles[i].x);
            cover.tiles[i].y = cover.mapYToCoverY(map.tiles[i].y);
            cover.tiles[i].z = map.tiles[i].z;
            cover.tiles[i].smooth = map.tiles[i].smooth;
            var width = map.tiles[i].width;
            var height = map.tiles[i].height;
            width && width > 0 && (cover.tiles[i].width = width);
            height && height > 0 && (cover.tiles[i].height = height);
        }
        for (var i = map.tiles.length; i < cover.tiles.length; i++)
            // Hide remaining tiles if map.tiles has been shrunk.
            cover.tiles[i].z = -1;
        cover.ready = cover.tiles.length > 4;
    }
}
