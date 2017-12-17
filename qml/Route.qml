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

/*
 * XXX: The intended way to draw a route on a QtLocation map would be to use
 * QtLocation's MapPolyline. MapPolyline, however, renders awfully ugly.
 * To work around this, let's use a Canvas and Context2D drawing primitives
 * to draw our route. This looks nice, but might be horribly inefficient.
 *
 * http://bugreports.qt.io/browse/QTBUG-38459
 */

Canvas {
    id: canvas
    contextType: "2d"
    height: parent.height
    renderStrategy: Canvas.Cooperative
    width: parent.width
    x: parent.x
    y: parent.y
    z: 200

    property string attribution: ""
    property bool   changed: false
    property bool   hasPath: false
    property string language: "en"
    property string mode: "car"
    property var    path: {"x": [], "y": []}
    property var    simplePaths: {}

    // Needed as separate properties for bindings.
    property real paintX: 0
    property real paintY: 0

    Timer {
        // Use a timer to ensure updates if map panned.
        interval: 500
        repeat: true
        running: app.running && canvas.hasPath
        onTriggered: {
            if (canvas.context) {
                canvas.changed && canvas.requestPaint();
            } else if (app.applicationActive && canvas.hasPath && canvas.available) {
                // When Poor Maps is minimized, the context seems to be lost,
                // with its value being null. Calling getContext after application
                // is active again and the canvas available again, will reinitialize
                // the context and via onContextChanged trigger a repaint.
                canvas.getContext("2d");
            }
        }
    }

    onContextChanged: {
        // Initialize context paint properties.
        if (!canvas.context) return;
        canvas.context.globalAlpha = 0.5;
        canvas.context.lineCap = "round";
        canvas.context.lineJoin = "round";
        canvas.context.lineWidth = Math.floor(Theme.pixelRatio * 12);
        canvas.context.strokeStyle = "#0540ff";
        canvas.context.clearRect(0, 0, canvas.width, canvas.height);
        canvas.redraw();
    }

    onPaint: {
        // Clear the whole canvas and redraw entire route.
        // This gets called continuously as the map is panned!
        if (!canvas.hasPath) return;
        if (!canvas.changed) return;
        if (!canvas.context) return;
        canvas.context.clearRect(0, 0, canvas.width, canvas.height);
        var zoom = Math.floor(map.zoomLevel);
        if (canvas.simplePaths.hasOwnProperty(zoom)) {
            // Use a simplified path to avoid the slowness of
            // plotting too many polyline segments on screen.
            var spath = canvas.simplePaths[zoom];
        } else {
            if (map.gesture.isPinchActive) return;
            canvas.simplePaths[zoom] = {"x": [], "y": []};
            return canvas.simplify(zoom);
        }
        canvas.context.beginPath();
        var bbox = map.getBoundingBox();
        var cbox = canvas.getClipBox(bbox);
        var prev, x, y, xpos, ypos;
        for (var i = 0; i < spath.x.length; i++) {
            x = spath.x[i];
            y = spath.y[i];
            if (x >= cbox[0] && x <= cbox[1] && y >= cbox[2] && y <= cbox[3]) {
                xpos = Util.xcoord2xpos(x, bbox[0], bbox[1], map.width);
                ypos = Util.ycoord2ypos(y, bbox[2], bbox[3], map.height);
                canvas.context.lineTo(xpos, ypos);
                prev = true;
            } else if (prev) {
                // Break path when going outside the clipbox.
                canvas.context.stroke();
                canvas.context.beginPath();
                prev = false;
            }
        }
        canvas.paintX = map.center.longitude;
        canvas.paintY = map.center.latitude;
        canvas.changed = false;
        canvas.context.stroke();
    }

    onPathChanged: {
        // Update canvas in conjunction with panning the map
        // only when we actually have a route to display.
        canvas.context && canvas.context.clearRect(
            0, 0, canvas.width, canvas.height);
        canvas.simplePaths = {};
        canvas.hasPath = canvas.path.x.length > 0;
        if (canvas.hasPath) {
            canvas.x = Qt.binding(function() {
                // Return canvas pixel X deviation to match panned map;
                // for use until a redraw pulls X back to zero.
                return (this.paintX - map.center.longitude) * map.scaleX;
            });
            canvas.y = Qt.binding(function() {
                // Return canvas pixel Y deviation to match panned map;
                // for use until a redraw pulls Y back to zero.
                return (map.center.latitude - this.paintY) * map.scaleY;
            });
        } else {
            canvas.x = 0;
            canvas.y = 0;
        }
    }

    onXChanged: canvas.changed = true;
    onYChanged: canvas.changed = true;

    function clear() {
        // Clear path from the canvas.
        canvas.path = {"x": [], "y": []};
        canvas.redraw();
    }

    function getClipBox(bbox) {
        // Return [xmin, xmax, ymin, ymax] to clip polyline to.
        var maxLength = Math.min(map.widthCoords, map.heightCoords);
        var xmin = bbox[0] - 1.5 * maxLength;
        var xmax = bbox[1] + 1.5 * maxLength;
        var ymin = bbox[2] - 1.5 * maxLength;
        var ymax = bbox[3] + 1.5 * maxLength;
        return [xmin, xmax, ymin, ymax];
    }

    function getDestination() {
        // Return coordinates [x,y] of the route destination.
        return [canvas.path.x[canvas.path.x.length - 1],
                canvas.path.y[canvas.path.y.length - 1]];

    }

    function redraw() {
        // Clear canvas and redraw entire route.
        canvas.changed = true;
        canvas.requestPaint();
    }

    function setPath(x, y) {
        // Set route path from coordinates.
        canvas.path = {"x": x, "y": y};
        canvas.redraw();
    }

    function simplify(zoom) {
        // Simplify path for display at zoom level using Douglas-Peucker.
        if (zoom < 14) {
            var tol = Math.pow(2, 18 - zoom) / 83250;
        } else {
            // Don't try simplification at high zoom levels as
            // we approach Douglas-Peucker's worst case O(n^2).
            var tol = null;
        }
        var maxLength = Math.min(map.widthCoords, map.heightCoords);
        var args = [canvas.path.x, canvas.path.y, tol, false, maxLength, 2000];
        py.call("poor.polysimp.simplify_qml", args, function(path) {
            Object.defineProperty(canvas.simplePaths, zoom.toString(), {
                "value": path, "writable": true
            });
            canvas.redraw();
        });
    }

}
