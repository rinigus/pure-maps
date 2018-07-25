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
    anchors.bottom: parent.bottom
    color: "#e6000000"
    height: Theme.paddingSmall + speed.height
    visible: app.navigationActive

    z: 500

    property string destDist:  app.navigationStatus.destDist
    property string destTime:  app.navigationStatus.destTime

    Label {
        // speed
        id: speed
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: Theme.paddingMedium
        color: Theme.primaryColor
        font.pixelSize: Theme.fontSizeHuge

        function update() {
            if (!py.ready || !app.navigationActive) return;
            // Update speed and positioning accuracy values in user's preferred units.
            if (!gps.position.speedValid) {
                text = ""
                return;
            }

            if (app.conf.get("units") === "american") {
                text = "%1".arg(Math.round(gps.position.speed * 2.23694))
            } else if (app.conf.get("units") === "british") {
                text = "%1".arg(Math.round(gps.position.speed * 2.23694))
            } else {
                text = "%1".arg(Math.round(gps.position.speed * 3.6))
            }
        }
    }

    Label {
        // speed unit
        id: speedUnit
        anchors.left: speed.right
        anchors.baseline: speed.baseline
        anchors.leftMargin: Theme.paddingSmall
        color: Theme.secondaryColor
        font.pixelSize: Theme.fontSizeMedium

        function update() {
            if (!py.ready || !app.navigationActive) return;
            if (app.conf.get("units") === "american") {
                text = app.tr("mph")
            } else if (app.conf.get("units") === "british") {
                text = app.tr("mph")
            } else {
                text = app.tr("km/h")
            }
        }
    }

    Label {
        // Time remaining to destination
        id: timeDest
        anchors.baseline: speed.baseline
        anchors.horizontalCenter: parent.horizontalCenter
        color: Theme.primaryColor
        font.pixelSize: Theme.fontSizeLarge
        text: block.destTime
    }

    Label {
        // Distance remaining to destination
        id: distSpace
        anchors.baseline: speed.baseline
        anchors.right: parent.right
        anchors.rightMargin: Theme.paddingMedium
        color: Theme.primaryColor
        font.pixelSize: Theme.fontSizeLarge
        text: block.destDist
    }

    MouseArea {
        anchors.fill: parent
        onClicked: app.showMenu();
    }

    function update() {
        speed.update();
        speedUnit.update();
    }

    Component.onCompleted: block.update()

    Connections {
        target: app
        onNavigationActiveChanged: block.update()
    }

    Connections {
        target: gps
        onPositionChanged: block.update()
    }
}
