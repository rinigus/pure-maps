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

    property bool active: status === Cover.Active
    property bool ready: false
    property bool showNarrative: map.hasRoute && map.showNarrative
    property var  tiles: []

    onShowNarrativeChanged: {
        for (var i = 0; i < cover.tiles.length; i++)
            cover.tiles[i].visible = !cover.showNarrative;
    }

    Timer {
        interval: 1000
        repeat: true
        running: !ready ||
            cover.status === Cover.Activating ||
            cover.status === Cover.Active
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
        smooth: true
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
            smooth: true
            source: app.getIcon("icons/position-direction")
            visible: map.direction || false
        }

        Image {
            id: stillImage
            anchors.centerIn: movingImage
            smooth: false
            source: app.getIcon("icons/position")
            visible: !movingImage.visible
        }

    }

    /*
     * Navigation narrative cover.
     */

    Image {
        anchors.bottom: parent.verticalCenter
        anchors.bottomMargin: Theme.paddingMedium
        anchors.horizontalCenter: parent.horizontalCenter
        opacity: 0.9
        smooth: true
        source: app.navigationBlock.icon ?
            "icons/navigation/%1.svg".arg(app.navigationBlock.icon) :
            "icons/navigation/flag.svg"
        sourceSize.height: cover.width/2
        sourceSize.width: cover.width/2
        visible: cover.showNarrative
    }

    Label {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.verticalCenter
        font.family: Theme.fontFamilyHeading
        font.pixelSize: Theme.fontSizeExtraLarge
        text: app.navigationBlock.manDist
        visible: cover.showNarrative
    }

    Label {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.paddingLarge
        anchors.left: parent.left
        anchors.leftMargin: Theme.paddingLarge
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeExtraSmall
        text: app.navigationBlock.destDist
        visible: cover.showNarrative
    }

    Label {
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.paddingLarge
        anchors.right: parent.right
        anchors.rightMargin: Theme.paddingLarge
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeExtraSmall
        text: app.navigationBlock.destTime
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
            if (map.tiles[i].type !== "basemap") continue;
            if (map.tiles[i].z !== 10) continue;
            while (cover.tiles.length <= j) cover.addTile();
            cover.tiles[j].smooth = map.tiles[i].smooth;
            cover.tiles[j].source = map.tiles[i].uri;
            cover.tiles[j].x = cover.mapXToCoverX(map.tiles[i].x);
            cover.tiles[j].y = cover.mapYToCoverY(map.tiles[i].y);
            cover.tiles[j].z = map.tiles[i].z;
            cover.tiles[j].visible = !cover.showNarrative;
            var width = map.tiles[i].image.width;
            var height = map.tiles[i].image.height;
            if (width && width > 0) cover.tiles[j].width = width;
            if (height && height > 0) cover.tiles[j].height = height;
            j++;
        }
        cover.ready = cover.tiles.length > 4;
    }

}
