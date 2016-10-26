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
    anchors.right: parent.right
    anchors.top: parent.top
    color: "#d0000000"
    height: destDist ? Math.max(
        iconImage.height + 2*Theme.paddingLarge,
        manLabel.height + Theme.paddingSmall + narrativeLabel.height,
        // If far off route, manLabel defines the height of the block,
        // but we need padding to make a sufficiently large tap target.
        1.3*manLabel.height) : 0

    z: 500
    property string destDist: ""
    property string destTime: ""
    property string icon: ""
    property string manDist: ""
    property string manTime: ""
    property string narrative: ""
    property bool narrativePageSeen: false
    property bool notify: icon || narrative
    Label {
        id: manLabel
        anchors.left: iconImage.right
        anchors.leftMargin: iconImage.width > 0 ? Theme.paddingLarge : 0
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
        anchors.leftMargin: iconImage.width > 0 ? Theme.paddingLarge : 0
        anchors.right: parent.right
        anchors.rightMargin: Theme.paddingLarge
        anchors.top: manLabel.bottom
        anchors.topMargin: Theme.paddingSmall
        color: Theme.primaryColor
        font.pixelSize: Theme.fontSizeMedium
        height: text ? implicitHeight + 0.3*manLabel.height : 0
        text: block.narrativePageSeen ? block.narrative :
            (block.notify ? "Tap to review maneuvers or begin navigating" : "")
        verticalAlignment: Text.AlignTop
        wrapMode: Text.WordWrap
    }
    Image {
        id: iconImage
        anchors.left: parent.left
        anchors.leftMargin: Theme.paddingLarge
        anchors.top: parent.top
        anchors.topMargin: Theme.paddingLarge
        fillMode: Image.Pad
        height: block.notify ? sourceSize.height : 0
        opacity: 0.9
        smooth: true
        source: "icons/navigation/%1.svg".arg(block.icon || "flag")
        sourceSize.height: Screen.sizeCategory >= Screen.Large ?
            1.7*Theme.iconSizeLarge : Theme.iconSizeLarge
        sourceSize.width: Screen.sizeCategory >= Screen.Large ?
            1.7*Theme.iconSizeLarge : Theme.iconSizeLarge
        width: block.notify ? sourceSize.width : 0
    }
    MouseArea {
        anchors.fill: parent
        onClicked: {
            block.narrativePageSeen = true;
            app.showMenu("NarrativePage.qml");
        }
    }
}
