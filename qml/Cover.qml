/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2014 Osmo Salomaa, 2018 Rinigus
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

CoverBackground {
    id: cover

    property bool active: status === Cover.Active
    property bool showNarrative: app.initialized && app.conf.showNarrative && map.hasRoute

    Image {
        // Background icon
        anchors.centerIn: parent
        height: width/sourceSize.width * sourceSize.height
        opacity: 0.1
        smooth: true
        source: "icons/cover.png"
        visible: !cover.showNarrative
        width: 1.5 * parent.width
    }

    /*
     * Default cover
     */

    Label {
        // Title
        anchors.centerIn: parent
        color: Theme.highlightColor
        font.pixelSize: Theme.fontSizeLarge
        horizontalAlignment: Text.AlignHCenter
        lineHeight: 1.25
        text: "Pure\nMaps"
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
        source: "icons/navigation/%1.svg".arg(app.navigationStatus.icon || "flag")
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
        text: app.navigationStatus.manDist
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
        text: app.navigationStatus.destDist
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
        text: app.navigationStatus.destTime
        visible: cover.showNarrative
    }

}
