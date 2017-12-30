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
import QtPositioning 5.3
import Sailfish.Silica 1.0

import "js/util.js" as Util

Item {
    id: scaleBar
    anchors.bottom: parent.bottom
    anchors.bottomMargin: Theme.paddingLarge
    anchors.left: parent.left
    anchors.leftMargin: Theme.paddingLarge
    height: base.height + text.height + text.anchors.bottomMargin
    opacity: 0.9
    visible: scaleWidth > 0
    z: 100

    property real   scaleWidth: 0
    property string text: ""

    Rectangle {
        id: base
        anchors.bottom: scaleBar.bottom
        color: "black"
        height: Math.floor(Theme.pixelRatio * 3)
        width: scaleBar.scaleWidth
    }

    Rectangle {
        anchors.bottom: base.top
        anchors.left: base.left
        color: "black"
        height: Math.floor(Theme.pixelRatio * 10)
        width: Math.floor(Theme.pixelRatio * 3)
    }

    Rectangle {
        anchors.bottom: base.top
        anchors.right: base.right
        color: "black"
        height: Math.floor(Theme.pixelRatio * 10)
        width: Math.floor(Theme.pixelRatio * 3)
    }

    Text {
        id: text
        anchors.bottom: base.top
        anchors.bottomMargin: Math.floor(Theme.pixelRatio * 4)
        anchors.horizontalCenter: base.horizontalCenter
        color: "black"
        font.bold: true
        font.family: "sans-serif"
        font.pixelSize: Math.round(Theme.pixelRatio * 18)
        horizontalAlignment: Text.AlignHCenter
        text: scaleBar.text
    }

    function roundedDistace(dist) {
        // Return dist rounded to an even amount of user-visible units,
        // but keeping the value as meters.
        if (app.conf.get("units") === "american")
            // Round to an even amount of miles or feet.
            return dist >= 1609.34 ?
                Util.siground(dist / 1609.34, 1) * 1609.34 :
                Util.siground(dist * 3.28084, 1) / 3.28084;
        if (app.conf.get("units") === "british")
            // Round to an even amount of miles or yards.
            return dist >= 1609.34 ?
                Util.siground(dist / 1609.34, 1) * 1609.34 :
                Util.siground(dist * 1.09361, 1) / 1.09361;
        // Round to an even amount of kilometers or meters.
        return Util.siground(dist, 1);
    }

    function update(force) {
        if (!py.ready) return;

        // Update scalebar for current zoom level and latitude.
        //force = force || false;

        var meters = map.metersPerPixel * map.width / 4;
        var dist = scaleBar.roundedDistace(meters);

        scaleBar.scaleWidth = dist / map.metersPerPixel
        scaleBar.text = py.call_sync("poor.util.format_distance", [dist, 1]);
    }

    Connections {
        target: map
        onMetersPerPixelChanged: scaleBar.update()
        onWidthChanged: scaleBar.update()
    }

    Connections {
        target: py
        onReadyChanged: scaleBar.update()
    }
}
