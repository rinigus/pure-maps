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
    id: block
    anchors.left: parent.left
    anchors.top: parent.top
    color: "#cc000000"
    height: destDist ? Math.max(
        iconImage.height, manLabel.height +
            narrativeLabel.height + Theme.paddingMedium/2) +
        blockContent.anchors.margins*2 : 0
    width: parent.width
    z: 500
    property string destDist: ""
    property string destTime: ""
    property string icon: ""
    property string manDist: ""
    property string manTime: ""
    property string narrative: ""
    property bool notify: icon || narrative
    BackgroundItem {
        id: blockContent
        anchors.left: parent.left
        anchors.margins: Theme.paddingMedium
        anchors.right: parent.right
        anchors.top: parent.top
        // Ensure a sufficiently large tap target.
        height: block.destDist ? Math.max(parent.height, Theme.itemSizeSmall) : 0
        highlightedColor: "#00000000"
        Image {
            id: iconImage
            anchors.left: parent.left
            fillMode: Image.Pad
            height: block.icon ? Math.max(
                implicitHeight + Theme.paddingLarge*2,
                manLabel.height + narrativeLabel.height + Theme.paddingMedium/2): 0
            horizontalAlignment: Image.AlignHCenter
            source: block.icon ?
                "icons/%1.png".arg(block.icon) :
                "icons/alert.png"
            verticalAlignment: Image.AlignVCenter
            width: block.icon ?
                implicitWidth + Theme.paddingLarge*2 :
                Theme.paddingMedium
        }
        Label {
            id: manLabel
            anchors.left: iconImage.right
            color: block.notify ? Theme.highlightColor : "white"
            font.family: block.notify ? Theme.fontFamilyHeading : Theme.fontFamily
            font.pixelSize: block.notify ? Theme.fontSizeHuge : Theme.fontSizeMedium
            height: block.destDist ? implicitHeight : 0
            text: block.manDist
            verticalAlignment: Text.AlignBottom
        }
        Label {
            id: destLabel
            anchors.baseline: manLabel.baseline
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingMedium
            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeSmall
            height: manLabel.height
            text: block.destTime ?
                "%1 · %2".arg(block.destDist).arg(block.destTime) :
                block.destDist
        }
        Label {
            id: narrativeLabel
            anchors.left: iconImage.right
            anchors.right: parent.right
            anchors.rightMargin: Theme.paddingMedium
            anchors.top: manLabel.bottom
            color: "white"
            font.pixelSize: Theme.fontSizeMedium
            height: block.narrative ?
                implicitHeight + 0.75*Theme.paddingMedium : 0
            text: block.narrative
            verticalAlignment: Text.AlignTop
            wrapMode: Text.WordWrap
        }
        MouseArea {
            // Use the maneuver icon to begin navigating.
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
            // Use rest of the block to open the narrative page.
            anchors.bottom: parent.bottom
            anchors.left: manLabel.left
            anchors.right: parent.right
            anchors.top: parent.top
            onClicked: app.showMenu("NarrativePage.qml");
        }
    }
}
