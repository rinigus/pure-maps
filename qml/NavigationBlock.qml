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
    // If far off route, manLabel defines the height of the block,
    // but we need padding to make a sufficiently large tap target.
    height: destDist ? Math.max(iconImage.height, manLabel.height + 1.4*Theme.paddingMedium) : 0
    width: parent.width
    z: 500
    property string destDist: ""
    property string destTime: ""
    property string icon: ""
    property string manDist: ""
    property string manTime: ""
    property string narrative: ""
    property bool notify: icon || narrative
    Image {
        id: iconImage
        anchors.left: parent.left
        anchors.top: parent.top
        fillMode: Image.Pad
        // Center icon vertically in the whole block,
        // whose height can be limited by the icon or text,
        // depending on narrative text length and screen orientation.
        height: block.notify ? Math.max(
            sourceSize.height + 2*Theme.paddingLarge,
            manLabel.height + narrativeLabel.anchors.topMargin + narrativeLabel.height
        ) : 0
        horizontalAlignment: Image.AlignRight
        source: block.icon ? "icons/%1.png".arg(block.icon) : "icons/alert.png"
        verticalAlignment: Image.AlignVCenter
        width: block.notify ? sourceSize.width + Theme.paddingLarge : 0
    }
    Label {
        id: manLabel
        anchors.left: iconImage.right
        anchors.leftMargin: Theme.paddingLarge
        anchors.right: parent.right
        anchors.top: parent.top
        color: block.notify ? Theme.highlightColor : "white"
        font.family: block.notify ? Theme.fontFamilyHeading : Theme.fontFamily
        font.pixelSize: block.notify ? Theme.fontSizeHuge : Theme.fontSizeMedium
        height: block.destDist ? implicitHeight + Theme.paddingMedium : 0
        text: block.manDist
        verticalAlignment: Text.AlignBottom
    }
    Label {
        id: destLabel
        anchors.baseline: manLabel.baseline
        anchors.right: parent.right
        anchors.rightMargin: Theme.paddingLarge
        color: Theme.secondaryColor
        font.pixelSize: Theme.fontSizeSmall
        height: manLabel.height
        text: block.destTime ? "%1 · %2".arg(block.destDist).arg(block.destTime) : block.destDist
    }
    Label {
        id: narrativeLabel
        anchors.left: iconImage.right
        anchors.leftMargin: Theme.paddingLarge
        anchors.right: parent.right
        anchors.rightMargin: Theme.paddingLarge
        anchors.top: manLabel.bottom
        anchors.topMargin: Theme.paddingSmall
        color: "white"
        font.pixelSize: Theme.fontSizeMedium
        // manLabel has some extra padding due to the line height
        // of the huge font size. Account vaguely to have visually
        // about equal top and bottom padding in the block.
        height: block.narrative ? implicitHeight + 1.2*Theme.paddingLarge : 0
        text: block.narrative
        verticalAlignment: Text.AlignTop
        wrapMode: Text.WordWrap
    }
    MouseArea {
        anchors.fill: parent
        onClicked: app.showMenu("NarrativePage.qml");
    }
}
