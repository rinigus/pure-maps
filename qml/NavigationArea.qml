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

Rectangle {
    id: navigationArea
    anchors.left: parent.left
    anchors.top: parent.top
    color: "#bb000000"
    height: destDist ? Math.max(
        iconImage.height, manLabel.height +
            narrativeLabel.height + Theme.paddingMedium/2) : 0
    width: parent.width
    z: 900
    property string destDist: ""
    property string destTime: ""
    property string icon: ""
    property string manDist: ""
    property string manTime: ""
    property string narrative: ""
    property bool notify: icon || narrative
    BackgroundItem {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        // Ensure a sufficiently large tap target.
        height: navigationArea.destDist ?
            Math.max(parent.height, Theme.itemSizeSmall) : 0
        highlightedColor: "#00000000"
        Image {
            id: iconImage
            anchors.left: parent.left
            fillMode: Image.Pad
            height: navigationArea.icon ? Math.max(
                implicitHeight + Theme.paddingLarge*2,
                manLabel.height + narrativeLabel.height + Theme.paddingMedium/2): 0
            horizontalAlignment: Image.AlignHCenter
            source: navigationArea.icon ?
                "icons/" + navigationArea.icon + ".png" :
                "icons/alert.png"
            verticalAlignment: Image.AlignVCenter
            width: navigationArea.icon ?
                implicitWidth + 2*Theme.paddingLarge :
                Theme.paddingMedium
        }
        Label {
            id: manLabel
            anchors.left: iconImage.right
            color: navigationArea.notify ? Theme.highlightColor : "white"
            font.family: navigationArea.notify ? Theme.fontFamilyHeading : Theme.fontFamily
            font.pixelSize: navigationArea.notify ?
                Theme.fontSizeExtraLarge : Theme.fontSizeExtraSmall
            height: navigationArea.destDist ? implicitHeight : 0
            text: navigationArea.manDist
            verticalAlignment: Text.AlignBottom
        }
        Label {
            id: destLabel
            anchors.baseline: manLabel.baseline
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingMedium
            color: "white"
            font.pixelSize: Theme.fontSizeExtraSmall
            height: manLabel.height
            text: navigationArea.destTime ?
                navigationArea.destDist + "  ·  " + navigationArea.destTime :
                navigationArea.destDist
        }
        Label {
            id: narrativeLabel
            anchors.left: iconImage.right
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingMedium
            anchors.top: manLabel.bottom
            color: "white"
            font.pixelSize: Theme.fontSizeSmall
            height: navigationArea.narrative ?
                implicitHeight + 0.75*Theme.paddingMedium : 0
            text: navigationArea.narrative
            verticalAlignment: Text.AlignTop
            wrapMode: Text.WordWrap
        }
        MouseArea {
            // Use the maneuver icon as a "begin" button.
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: manLabel.left
            anchors.top: parent.top
            onClicked: {
                map.autoCenter = true;
                map.centerOnPosition();
                map.zoomLevel < 16 && map.setZoomLevel(16);
            }
        }
        MouseArea {
            anchors.bottom: parent.bottom
            anchors.left: manLabel.left
            anchors.right: parent.right
            anchors.top: parent.top
            onClicked: app.showMenu("NarrativePage.qml");
        }
    }
}
