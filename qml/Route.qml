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

import "js/simplify.js" as Simplify
import "js/util.js" as Util

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
        // Clear canvas and redraw entire route.
        // This gets called continuously as the map is panned!
        canvas.context.clearRect(0, 0, canvas.width, canvas.height);
        if (canvas.path.length == 0) return;
        var zoom = Math.min(18, Math.floor(map.zoomLevel));
        var key = zoom.toString();
        if (!canvas.simplePaths.hasOwnProperty(key))
            canvas.simplify(zoom);
        var simplePath = canvas.simplePaths[key];
        canvas.initDone || canvas.initContextProperties();
        canvas.context.beginPath();
        var bbox = map.getBoundingBox();
        var cx = map.center.longitude, cy = map.center.latitude;
        simplePath.forEach(function(p) {
            // We need to include some points outside the visible bbox
            // to include polyline segments that cross the bbox edge.
            if (p.longitude < cx - 1.5 * map.widthCoords   ||
                p.longitude > cx + 1.5 * map.widthCoords   ||
                p.latitude  < cy - 1.5 * map.heightCoords  ||
                p.latitude  > cy + 1.5 * map.heightCoords) return;
            canvas.context.lineTo(
                Util.xcoord2xpos(p.longitude, bbox[0], bbox[1], map.width),
                Util.ycoord2ypos(p.latitude,  bbox[2], bbox[3], map.height));

        })
        // This is not actually corrent for Y, since scaleY varies
        // by latitude, but this is consistent with map.ycoord.
        canvas.paintX = cx - map.widthCoords/2;
        canvas.paintY = cy + map.heightCoords/2;
        canvas.context.stroke();
    }

    function clear() {
        // Clear path from the canvas.
        canvas.path = [];
        canvas.simplePaths = {"0": []};
        canvas.requestPaint();
    }

    function initContextProperties() {
        // Initialize context line appearance properties.
        if (!py.ready) return;
        canvas.context.globalAlpha = py.evaluate("poor.conf.route_alpha");
        canvas.context.lineCap = "round";
        canvas.context.lineJoin = "round";
        canvas.context.lineWidth = py.evaluate("poor.conf.route_width");
        canvas.context.strokeStyle = py.evaluate("poor.conf.route_color");
        canvas.initDone = true;
    }

    function redraw() {
        // Clear canvas and redraw entire route.
        canvas.requestPaint();
    }

    function simplify(zoom) {
        // Simplify path for display at zoom level using Douglas-Peucker.
        var key = zoom.toString();
        var tolerance = Math.pow(2, 18-zoom) / 83250;
        var simplePath = Simplify.simplify(canvas.path, tolerance, false);
        Object.defineProperty(canvas.simplePaths, key,
                              {value: simplePath, writable: true});

    }
}
