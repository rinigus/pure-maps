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

/*
 * The intended way to draw a route on a QtLocation map would be to use
 * QtLocation's MapPolyline. MapPolyline, however, renders awfully ugly.
 * To work around this, let's use a Canvas and Context2D drawing primitives
 * to draw our route. This looks nice, but might be horribly inefficient.
 * See also map.xcoord, map.ycoord, map.scaleX and map.scaleY for potentially
 * slow bound calculations that might not be needed without this.
 *
 * http://bugreports.qt-project.org/browse/QTBUG-38459
 */

Canvas {
    id: canvas
    contextType: "2d"
    height: parent.height
    width: parent.width
    x: (paintX - map.xcoord) * map.scaleX
    y: (map.ycoord - paintY) * map.scaleY
    z: 200

    property bool   changed: false
    property bool   initDone: false
    property real   lineAlpha: 0.5
    property string lineColor: "#FF0000"
    property real   lineWidth: 12
    property real   paintX: 0
    property real   paintY: 0
    property var    path: []

    Timer {
        id: timer
        interval: 500
        repeat: true
        running: canvas.path.length > 0
        onTriggered: canvas.changed && canvas.redraw();
    }

    Component.onCompleted: {
        // Load default appearance from the Python backend.
        py.onReadyChanged.connect(function() {
            canvas.lineAlpha = py.evaluate("poor.conf.route_alpha");
            canvas.lineColor = py.evaluate("poor.conf.route_color");
            canvas.lineWidth = py.evaluate("poor.conf.route_width");
        })
    }

    onPaint: {
        // Ensure that the route is updated after panning.
        // This gets fired ridiculously often, so keep simple.
        changed = true;
    }

    function clear() {
        // Clear path from the canvas.
        canvas.path = [];
        canvas.redraw();
    }

    function initContextProperties() {
        canvas.context.globalAlpha = canvas.lineAlpha;
        canvas.context.lineCap = "round";
        canvas.context.linejoin = "round";
        canvas.context.lineWidth = canvas.lineWidth;
        canvas.context.strokeStyle = canvas.lineColor;
        canvas.initDone = true;
    }

    function redraw() {
        // Clear canvas and redraw entire route.
        canvas.context.clearRect(0, 0, canvas.width, canvas.height);
        if (canvas.path.length == 0) return;
        canvas.initDone || canvas.initContextProperties();
        canvas.context.beginPath();
        canvas.paintX = map.xcoord;
        canvas.paintY = map.ycoord;
        canvas.path.forEach(function(p) {
            // We need to include some points outside the visible bbox
            // to include polyline segments that cross the bbox edge.
            if (p.longitude < canvas.paintX - map.widthCoords    ||
                p.latitude  > canvas.paintY + map.heightCoords   ||
                p.longitude > canvas.paintX + map.widthCoords*2  ||
                p.latitude  < canvas.paintY - map.heightCoords*2)
                return;
            canvas.context.lineTo(map.scaleX*(p.longitude - canvas.paintX),
                                  map.scaleY*(canvas.paintY - p.latitude));

        })
        canvas.context.stroke();
        canvas.changed = false;
    }
}
