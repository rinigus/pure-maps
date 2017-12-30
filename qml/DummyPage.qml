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
    allowedOrientations: app.defaultAllowedOrientations
    clip: true

    property var tiles: []

    Rectangle {
        // Matches the default QtLocation Map background.
        id: background
        anchors.centerIn: parent
        color: "#e6e6e6"
        height: map.height
        rotation: map.rotation
        width: map.width
    }

    onStatusChanged: {
        // Clear and hide menu if navigated backwards to this page.
        // This gets fired on application startup as well!
        page.status === PageStatus.Active && app.clearMenu();
    }

    function addTile() {
        // Add a new blank tile to the end of collection.
        var component = Qt.createComponent("CoverTile.qml");
        page.tiles.push(component.createObject(background));
    }

    function updateTiles() {
        /* // Update dummy map tiles from map equivalents. */
        /* for (var i = 0; i < page.tiles.length; i++) */
        /*     page.tiles[i].z = -1; */
        /* var j = 0; */
        /* for (var i = 0; i < map.tiles.length; i++) { */
        /*     if (map.tiles[i].type !== "basemap") continue; */
        /*     if (map.tiles[i].z !== 10) continue; */
        /*     if (map.tiles[i].x > page.width) continue; */
        /*     if (map.tiles[i].y > page.height) continue; */
        /*     var width = map.tiles[i].image.width; */
        /*     var height = map.tiles[i].image.height; */
        /*     if (!width || map.tiles[i].x + width < 0) continue; */
        /*     if (!height || map.tiles[i].y + height < 0) continue; */
        /*     while (page.tiles.length <= j) page.addTile(); */
        /*     page.tiles[j].height = height; */
        /*     page.tiles[j].smooth = map.tiles[i].smooth; */
        /*     page.tiles[j].source = map.tiles[i].uri; */
        /*     page.tiles[j].width = width; */
        /*     page.tiles[j].x = map.tiles[i].x; */
        /*     page.tiles[j].y = map.tiles[i].y; */
        /*     page.tiles[j].z = map.tiles[i].z; */
        /*     j++; */
        /* } */
    }

}
