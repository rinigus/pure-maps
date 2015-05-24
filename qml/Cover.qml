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

CoverBackground {
    id: cover
    property bool active: status == Cover.Active
    property bool ready: false
    property bool showNarrative: map.hasRoute && map.showNarrative
    property var tiles: []
    onShowNarrativeChanged: {
        for (var i = 0; i < cover.tiles.length; i++)
            cover.tiles[i].visible = !cover.showNarrative;
    }
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
    Image {
        anchors.centerIn: parent
        height: width/sourceSize.width * sourceSize.height
        opacity: 0.1
        source: "icons/cover.png"
        width: 1.5 * parent.width
    }
    /*
     * Default map cover.
     */
    Rectangle {
        // Matches the default QtLocation Map background.
        anchors.fill: parent
        color: "#e6e6e6"
        visible: !cover.showNarrative
        z: 1
    }
    Item {
        id: positionMarker
        height: movingImage.height
        visible: !cover.showNarrative
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
    /*
     * Navigation narrative cover.
     */
    Image {
        anchors.bottom: parent.verticalCenter
        anchors.bottomMargin: Theme.paddingLarge
        anchors.horizontalCenter: parent.horizontalCenter
        source: app.navigationArea.icon.length > 0 ?
            "icons/" + app.navigationArea.icon + ".png" :
            "icons/alert.png"
        visible: cover.showNarrative
    }
    Label {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.verticalCenter
        font.family: Theme.fontFamilyHeading
        font.pixelSize: Theme.fontSizeExtraLarge
        text: app.navigationArea.manDist
        visible: cover.showNarrative
    }
    Label {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.paddingLarge
        anchors.left: parent.left
        anchors.leftMargin: Theme.paddingLarge
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeExtraSmall
        text: app.navigationArea.destDist
        visible: cover.showNarrative
    }
    Label {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.paddingLarge
        anchors.right: parent.right
        anchors.rightMargin: Theme.paddingLarge
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeExtraSmall
        text: app.navigationArea.destTime
        visible: cover.showNarrative
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
        for (var i = 0; i < cover.tiles.length; i++)
            cover.tiles[i].z = -1;
        var j = 1;
        for (var i = 0; i < map.tiles.length; i++) {
            if (map.tiles[i].type != "basemap") continue;
            if (map.tiles[i].z != 10) continue;
            while (cover.tiles.length <= j) cover.addTile();
            cover.tiles[j].smooth = map.tiles[i].smooth;
            cover.tiles[j].source = map.tiles[i].uri;
            cover.tiles[j].x = cover.mapXToCoverX(map.tiles[i].x);
            cover.tiles[j].y = cover.mapYToCoverY(map.tiles[i].y);
            cover.tiles[j].z = map.tiles[i].z;
            cover.tiles[j].visible = !cover.showNarrative;
            var width = map.tiles[i].width;
            var height = map.tiles[i].height;
            width && width > 0 && (cover.tiles[j].width = width);
            height && height > 0 && (cover.tiles[j].height = height);
            j++;
        }
        cover.ready = cover.tiles.length > 4;
    }
}
