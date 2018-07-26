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
    color: "#e6000000"
    height: {
        if (!destDist) return 0;
        var h1 = iconImage.height + 2 * Theme.paddingLarge;
        var h2 = manLabel.height + Theme.paddingSmall + narrativeLabel.height;
        // If far off route, manLabel defines the height of the block,
        // but we need padding to make a sufficiently large tap target.
        var h3 = 1.3 * manLabel.height;
        return Math.max(h1, h2, h3);
    }
    z: 500

    property string destDist:  app.navigationStatus.destDist
    property string destEta:   app.navigationStatus.destEta
    property string destTime:  app.navigationStatus.destTime
    property string icon:      app.navigationStatus.icon
    property string manDist:   app.navigationStatus.manDist
    property string manTime:   app.navigationStatus.manTime
    property string narrative: app.navigationStatus.narrative
    property bool   notify:    app.navigationStatus.notify

    Label {
        // Distance remaining to the next maneuver
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
        // Estimated time of arrival
        id: destLabel
        anchors.baseline: manLabel.baseline
        anchors.right: parent.right
        anchors.rightMargin: Theme.paddingLarge
        color: Theme.primaryColor
        font.pixelSize: Theme.fontSizeLarge
        height: manLabel.height
        text: block.notify ? block.destEta : block.destTime
    }

    Label {
        // Estimated time of arrival: ETA label
        id: destEta
        anchors.baseline: manLabel.baseline
        anchors.right: destLabel.left
        anchors.rightMargin: Theme.paddingSmall
        color: Theme.secondaryColor
        font.pixelSize: Theme.fontSizeMedium
        height: manLabel.height
        text: app.tr("ETA")
        visible: block.notify
    }

    Label {
        // Instruction text for the next maneuver
        id: narrativeLabel
        anchors.left: iconImage.right
        anchors.leftMargin: iconImage.width > 0 ? Theme.paddingLarge : 0
        anchors.right: parent.right
        anchors.rightMargin: Theme.paddingLarge
        anchors.top: manLabel.bottom
        anchors.topMargin: Theme.paddingSmall
        color: Theme.primaryColor
        font.pixelSize: Theme.fontSizeMedium
        height: text ? implicitHeight + 0.3 * manLabel.height : 0
        text: app.navigationPageSeen ?
            (block.notify ? block.narrative : "") :
            (block.notify ? app.tr("Tap to review maneuvers or begin navigating") : "")
        verticalAlignment: Text.AlignTop
        wrapMode: Text.WordWrap
    }

    Image {
        // Icon for the next maneuver
        id: iconImage
        anchors.left: parent.left
        anchors.leftMargin: Theme.paddingLarge
        anchors.top: parent.top
        anchors.topMargin: Theme.paddingLarge
        fillMode: Image.Pad
        height: block.notify ? sourceSize.height : 0
        opacity: 0.9
        smooth: true
        source: block.notify ? "icons/navigation/%1.svg".arg(block.icon || "flag") : ""
        sourceSize.height: (Screen.sizeCategory >= Screen.Large ? 1.7 : 1) * Theme.iconSizeLarge
        sourceSize.width: (Screen.sizeCategory >= Screen.Large ? 1.7 : 1) * Theme.iconSizeLarge
        width: block.notify ? sourceSize.width : 0
    }

    MouseArea {
        anchors.fill: parent
        onClicked: app.showNavigationPages();
    }

}
