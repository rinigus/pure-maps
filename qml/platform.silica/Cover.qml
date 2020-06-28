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

// Cover is Sailfish OS specific and, as a result,
// is implemented here.

CoverBackground {
    id: cover

    property bool active: status === Cover.Active
    property bool showNarrative: app.initialized && app.conf.showNarrative && app.navigator.hasRoute

    Image {
        // Background icon
        anchors.centerIn: parent
        height: width/sourceSize.width * sourceSize.height
        opacity: 0.1
        smooth: true
        source: "../icons/cover.png"
        visible: !cover.showNarrative
        width: 1.5 * parent.width
    }

    /*
     * Default cover
     */

    Label {
        // Title
        anchors.centerIn: parent
        color: Theme.primaryColor
        font.pixelSize: Theme.fontSizeLarge
        horizontalAlignment: Text.AlignHCenter
        lineHeight: 1.25
        text: "Pure\nMaps"
        visible: !cover.showNarrative
    }

    /*
     * Navigation narrative cover
     */

    CoverActionList {
        enabled: app.initialized && app.conf.showNarrative && app.navigator.hasRoute

        CoverAction {
            iconSource: app.mode === modes.navigate ? "image://theme/icon-cover-pause" :
                                                      "image://theme/icon-cover-play"
            onTriggered: {
                app.hideNavigationPages();
                if (app.mode === modes.navigate) app.setModeExploreRoute();
                else app.setModeNavigate();
            }
        }

        CoverAction {
            iconSource: "image://theme/icon-cover-cancel"
            onTriggered: {
                app.setModeExplore();
                navigator.clearRoute();
                app.showMap();
            }
        }
    }

    Image {
        // Maneuver icon
        anchors.bottom: parent.verticalCenter
        anchors.bottomMargin: Theme.paddingMedium
        anchors.horizontalCenter: parent.horizontalCenter
        opacity: 0.9
        smooth: true
        source: "../icons/navigation/%1-%2.svg".arg(app.navigator.icon || "flag").arg(styler.navigationIconsVariant)
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
        text: app.navigator.manDist
        visible: cover.showNarrative
    }

    Label {
        // Distance remaining to destination
        anchors.bottom: parent.coverActionArea.top
        anchors.bottomMargin: Theme.paddingLarge
        anchors.left: parent.left
        anchors.leftMargin: Theme.paddingLarge
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeExtraSmall
        text: app.navigator.destDist
        visible: cover.showNarrative
    }

    Label {
        // Time remaining to destination
        anchors.bottom: parent.coverActionArea.top
        anchors.bottomMargin: Theme.paddingLarge
        anchors.right: parent.right
        anchors.rightMargin: Theme.paddingLarge
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeExtraSmall
        text: app.navigator.destTime
        visible: cover.showNarrative
    }
}
