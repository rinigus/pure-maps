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
 * Construct a dummy page by duplicating tiles from the actual map.
 * This exact resemblance will allow smooth transitions.
 */

Page {
    id: page
    allowedOrientations: Orientation.Portrait
    clip: true
    property var tiles: []
    Rectangle {
        // Matches the default QtLocation Map background.
        anchors.fill: parent
        color: "#e6e6e6"
    }
    onStatusChanged: {
        if (page.status == PageStatus.Active) {
            // Clear and hide menu if navigated backwards to this page.
            // This gets fired on application startup as well!
            app.clearMenu();
        }
    }
    function addTile() {
        // Add a new blank tile to the end of collection.
        var component = Qt.createComponent("CoverTile.qml");
        page.tiles.push(component.createObject(page));
    }
    function updateTiles() {
        // Update cover map tiles from map equivalents.
        for (var i = 0; i < map.tiles.length; i++) {
            if (page.tiles.length <= i) page.addTile();
            page.tiles[i].source = map.tiles[i].uri;
            page.tiles[i].x = map.tiles[i].x;
            page.tiles[i].y = map.tiles[i].y;
            page.tiles[i].z = map.tiles[i].z;
        }
        for (var i = map.tiles.length; i < page.tiles.length; i++)
            // Hide remaining tiles if map.tiles has been shrunk.
            page.tiles[i].z = -1;
    }
}
