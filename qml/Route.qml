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
    renderStrategy: Canvas.Cooperative
    width: parent.width
    z: 200

    property bool initDone: false
    property var  paintX: 0
    property var  paintY: 0
    property var  path: {"x": [], "y": []}
    property var  simplePaths: {"0": {"x": [], "y": []}}

    onPaint: {
        // Clear the whole canvas and redraw entire route.
        // This gets called continuously as the map is panned!
        if (canvas.path.x.length == 0) return;
        canvas.context.clearRect(0, 0, canvas.width, canvas.height);
        var zoom = Math.min(18, Math.floor(map.zoomLevel));
        var key = zoom.toString();
        if (!canvas.simplePaths.hasOwnProperty(key)) {
            if (map.gesture.isPinchActive) return;
            // Prevent calling simplify multiple times.
            canvas.simplePaths[key] = {"x": [], "y": []};
            return canvas.simplify(zoom);
        }
        var spath = canvas.simplePaths[key];
        canvas.initDone || canvas.initContextProperties();
        canvas.context.beginPath();
        var bbox = map.getBoundingBox();
        var prev = false;
        for (var i = 0; i < spath.x.length; i++) {
            // Render also first nodes outside the bbox.
            // in order to render segments that cross the bbox.
            var x = spath.x[i];
            var y = spath.y[i];
            var inbb = (x >= bbox[0] && x <= bbox[1] &&
                        y >= bbox[2] && y <= bbox[3]);

            if (inbb && !prev && i > 0) {
                var xp = spath.x[i-1];
                var yp = spath.y[i-1];
                canvas.context.lineTo(
                    Util.xcoord2xpos(xp, bbox[0], bbox[1], map.width),
                    Util.ycoord2ypos(yp, bbox[2], bbox[3], map.height));

            }
            if (inbb || prev)
                canvas.context.lineTo(
                    Util.xcoord2xpos(x, bbox[0], bbox[1], map.width),
                    Util.ycoord2ypos(y, bbox[2], bbox[3], map.height));

            prev = inbb;
        }
        canvas.paintX = map.center.longitude;
        canvas.paintY = map.center.latitude;
        canvas.context.stroke();
    }

    onPathChanged: {
        // Update canvas in conjunction with panning the map
        // only when we actually have a route to display.
        if (path.x.length > 0) {
            canvas.x = Qt.binding(function() {
                return (this.paintX - map.center.longitude) * map.scaleX;
            });
            canvas.y = Qt.binding(function() {
                return (map.center.latitude - this.paintY) * map.scaleY;
            });
        } else {
            canvas.x = 0;
            canvas.y = 0;
        }
    }

    function clear() {
        // Clear path from the canvas.
        canvas.path = {"x": [], "y": []};
        canvas.simplePaths = {"0": {"x": [], "y": []}};
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

    function setPath(x, y) {
        // Set route path from coordinates.
        canvas.path = {"x": x, "y": y};
        canvas.simplePaths = {"0": {"x": [], "y": []}};
        canvas.context.clearRect(0, 0, canvas.width, canvas.height);
        canvas.requestPaint();
    }

    function simplify(zoom) {
        // Simplify path for display at zoom level using Douglas-Peucker.
        var tol = Math.pow(2, 18-zoom) / 83250;
        py.call("poor.polysimp.simplify_qml",
                [canvas.path.x, canvas.path.y, tol, false, 2000],
                function(path) {
                    Object.defineProperty(canvas.simplePaths,
                                          zoom.toString(),
                                          {value: {"x": path.x, "y": path.y},
                                           writable: true});

                    canvas.requestPaint();
                });

    }
}
