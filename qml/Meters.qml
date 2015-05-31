/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2015 Osmo Salomaa
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

Item {
    id: meters
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 10
    anchors.right: app.northArrow.left
    anchors.rightMargin: 10
    height: labels.implicitHeight
    opacity: 0.9
    width: parent.width
    z: 100
    Text {
        id: values
        anchors.bottom: parent.bottom
        anchors.right: labels.left
        color: "black"
        font.family: "sans-serif"
        font.pixelSize: 15
        font.weight: Font.DemiBold
        horizontalAlignment: Text.AlignRight
        lineHeight: 1.25
    }
    Text {
        id: labels
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        color: "black"
        font.family: "sans-serif"
        font.pixelSize: 15
        font.weight: Font.DemiBold
        horizontalAlignment: Text.AlignLeft
        lineHeight: 1.25
        text: " m\n km/h"
    }
    Timer {
        interval: 3000
        repeat: true
        running: app.running
        triggeredOnStart: true
        onTriggered: meters.update();
    }
    function update() {
        var lines = ["—", "—"];
        if (gps.position.horizontalAccuracyValid)
            lines[0] = Math.round(gps.position.horizontalAccuracy);
        if (gps.position.speedValid)
            lines[1] = Math.round(gps.position.speed*3.6);
        values.text = lines.join("\n");
    }
}
