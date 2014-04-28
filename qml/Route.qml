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
import QtPositioning 5.0

import "js/util.js" as Util

/*
 * The intended way to draw a route on a QtLocation map would be to use
 * QtLocation's MapPolyline. MapPolyline, however, renders awfully ugly.
 * To work around this, let's use a Canvas and Context2D drawing primitives
 * to draw our route. This looks nice, but might be horribly inefficient.
 *
 * http://bugreports.qt-project.org/browse/QTBUG-38459
 */

Canvas {
    id: canvas
    contextType: "2d"
    height: parent.height
    renderStrategy: Canvas.Immediate
    width: parent.width
    x: (paintX - map.xcoord) * map.scaleX
    y: (map.ycoord - paintY) * map.scaleY
    z: 200

    property bool initDone: false
    property real paintX: 0
    property real paintY: 0
    property var  path: []
    property var  simplePaths: {"0": []}

    onPaint: {
        // Clear the whole canvas and redraw entire route.
        // This gets called continuously as the map is panned!
        if (canvas.path.length == 0) return;
        canvas.context.clearRect(0, 0, canvas.width, canvas.height);
        var zoom = Math.min(18, Math.floor(map.zoomLevel));
        var key = zoom.toString();
        if (!canvas.simplePaths.hasOwnProperty(key))
            return canvas.simplify(zoom);
        var spath = canvas.simplePaths[key];
        canvas.initDone || canvas.initContextProperties();
        canvas.context.beginPath();
        var bbox = map.getBoundingBox();
        var xmin = map.center.longitude - 1.5 * map.widthCoords;
        var xmax = map.center.longitude + 1.5 * map.widthCoords;
        var ymin = map.center.latitude  - 1.5 * map.heightCoords;
        var ymax = map.center.latitude  + 1.5 * map.heightCoords;
        for (var i = 0; i < spath.length; i++) {
            var x = spath[i].longitude;
            var y = spath[i].latitude;
            if (x < xmin || x > xmax || y < ymin || y > ymax) continue;
            canvas.context.lineTo(
                Util.xcoord2xpos(x, bbox[0], bbox[1], map.width),
                Util.ycoord2ypos(y, bbox[2], bbox[3], map.height));

        }
        canvas.paintX = map.center.longitude - map.widthCoords/2;
        canvas.paintY = map.center.latitude + map.heightCoords/2;
        canvas.context.stroke();
    }

    function addSimplePath(path, zoom) {
        // Add path simplified for display at zoom level.
        var spath = [];
        for (var i = 0; i < path.x.length; i++)
            spath[i] = QtPositioning.coordinate(path.y[i], path.x[i]);
        Object.defineProperty(canvas.simplePaths,
                              zoom.toString(),
                              {value: spath, writable: true});

        canvas.requestPaint();
    }

    function clear() {
        // Clear path from the canvas.
        canvas.path = [];
        canvas.simplePaths = {"0": []};
        canvas.context.clearRect(0, 0, canvas.width, canvas.height);
        canvas.requestPaint();
    }

    function initContextProperties() {
        // Initialize context line appearance properties.
        if (!py.ready) return;
        canvas.context.globalAlpha = py.evaluate("poor.conf.route_alpha");
        canvas.context.lineWidth = py.evaluate("poor.conf.route_width");
        canvas.context.strokeStyle = py.evaluate("poor.conf.route_color");
        canvas.context.lineCap = "round";
        canvas.context.lineJoin = "round";
        canvas.initDone = true;
    }

    function redraw() {
        // Clear canvas and redraw entire route.
        canvas.requestPaint();
    }

    function simplify(zoom) {
        // Simplify path for display at zoom level using Douglas-Peucker.
        var tol = Math.pow(2, 18-zoom) / 83250;
        var x = [];
        var y = [];
        for (var i = 0; i < canvas.path.length; i++) {
            x[i] = canvas.path[i].longitude;
            y[i] = canvas.path[i].latitude;
        }
        py.call("poor.polysimp.simplify_qml",
                [x, y, tol, false, 1000],
                function(path) {
                    canvas.addSimplePath(path, zoom);
                });

    }
}
