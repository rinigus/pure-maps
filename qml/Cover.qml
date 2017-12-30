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
    property bool showNarrative: map.hasRoute && app.showNarrative

    onShowNarrativeChanged: {
        /* for (var i = 0; i < cover.tiles.length; i++) */
        /*     cover.tiles[i].visible = !cover.showNarrative; */
    }

//    Timer {
//        interval: 1000
//        repeat: true
//        running: !cover.ready ||
//            cover.status === Cover.Activating ||
//            cover.status === Cover.Active
//        triggeredOnStart: true
//        onTriggered: {
//            if (app.inMenu) return;
//            cover.updatePositionMarker();
//        }
//    }

    /*
     * Default map cover
     */

    Image {
        anchors.centerIn: parent
//        height: width/sourceSize.width * sourceSize.height
//        opacity: 0.1
        smooth: true
        source: "icons/cover.png"
//        width: 1.5 * parent.width
        fillMode: Image.PreserveAspectFit
        width: parent.width*3/4
        visible: !cover.showNarrative
    }

    /*
     * Navigation narrative cover
     */

    Image {
        // Maneuver icon
        anchors.bottom: parent.verticalCenter
        anchors.bottomMargin: Theme.paddingMedium
        anchors.horizontalCenter: parent.horizontalCenter
        opacity: 0.9
        smooth: true
        source: "icons/navigation/%1.svg".arg(app.navigationBlock.icon || "flag")
        sourceSize.height: cover.width / 2
        sourceSize.width: cover.width / 2
        visible: cover.showNarrative
    }

    Label {
        // Distance remaining to next maneuver
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.verticalCenter
        font.family: Theme.fontFamilyHeading
        font.pixelSize: Theme.fontSizeExtraLarge
        text: app.navigationBlock.manDist
        visible: cover.showNarrative
    }

    Label {
        // Distance remaining to destination
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
        // Time remaining to destination
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.paddingLarge
        anchors.right: parent.right
        anchors.rightMargin: Theme.paddingLarge
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeExtraSmall
        text: app.navigationBlock.destTime
        visible: cover.showNarrative
    }
}
