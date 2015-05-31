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

import "js/util.js" as Util

Item {
    id: scaleBar
    anchors.bottom: parent.bottom
    anchors.bottomMargin: 10
    anchors.left: app.menuButton.right
    height: base.height
    opacity: 0.9
    visible: scaleWidth > 0
    width: base.width
    z: 100
    property var coordPrev: QtPositioning.coordinate(0, 0)
    property real scaleWidth: 0
    property string text: ""
    property real zoomLevelPrev: -1
    Rectangle {
        id: base
        color: "black"
        height: 2
        width: scaleBar.scaleWidth
    }
    Rectangle {
        anchors.bottom: base.top
        anchors.left: base.left
        color: "black"
        height: 10
        width: 2
    }
    Rectangle {
        anchors.bottom: base.top
        anchors.right: base.right
        color: "black"
        height: 10
        width: 2
    }
    Text {
        anchors.bottom: base.top
        anchors.bottomMargin: 4
        anchors.left: base.left
        color: "black"
        font.family: "sans-serif"
        font.pixelSize: 15
        font.weight: Font.DemiBold
        horizontalAlignment: Text.AlignHCenter
        text: scaleBar.text
        width: base.width
    }
    function update() {
        // Update scalebar for current zoom level and latitude.
        var x = map.center.longitude;
        var y = map.center.latitude;
        if (map.zoomLevel == scaleBar.zoomLevelPrev &&
            Math.abs(y - scaleBar.coordPrev.latitude) < 0.1) return;
        var bbox = map.getBoundingBox();
        var tail = QtPositioning.coordinate(y, bbox[1]);
        var dist = Util.siground(parent.width/map.width * map.center.distanceTo(tail)/2, 1);
        var tail = map.center.atDistanceAndAzimuth(dist, 45);
        var xend = Util.xcoord2xpos(tail.longitude, bbox[0], bbox[1], map.width);
        var yend = Util.ycoord2ypos(tail.latitude, bbox[2], bbox[3], map.height);
        var xd = Util.xcoord2xpos(x, bbox[0], bbox[1], map.width) - xend;
        var yd = Util.ycoord2ypos(y, bbox[2], bbox[3], map.height) - yend;
        scaleBar.scaleWidth = Math.sqrt(xd*xd + yd*yd);
        scaleBar.text = py.call_sync("poor.util.format_distance", [dist, 1]);
        scaleBar.coordPrev.longitude = map.center.longitude;
        scaleBar.coordPrev.latitude = map.center.latitude;
        scaleBar.zoomLevelPrev = map.zoomLevel;
    }
}
