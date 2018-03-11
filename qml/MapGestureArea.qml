/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2018 Osmo Salomaa
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
import MapboxMap 1.0

MapboxMapGestureArea {
    id: area
    activeClickedGeo: true
    activeDoubleClickedGeo: true
    activePressAndHoldGeo: true

    property real degLatPerPixel: 0
    property real degLonPerPixel: 0

    onClickedGeo: {
        // Check clicked coordinates against any markers and
        // activate the associated action.
        area.degLonPerPixel = degLonPerPixel;
        area.degLatPerPixel = degLatPerPixel;
        // Toggle auto-center if position marker clicked.
        if (area.coordinatesMatch(geocoordinate, map.position.coordinate))
            return map.toggleAutoCenter();
        // Show information bubble if POI marker clicked.
        for (var i = 0; i < map.pois.length; i++)
            if (area.coordinatesMatch(geocoordinate, map.pois[i].coordinate))
                return map.togglePoiBubble(map.pois[i]);
        // Hide any POI bubbles if background map clicked.
        map.hidePoiBubbles();
    }

    onDoubleClicked: {
        map.setZoomLevel(map.zoomLevel + 1, Qt.point(mouse.x, mouse.y));
    }

    onPressAndHoldGeo: {
        map.addPois([{
            "text": app.tr("Unnamed point"),
            "title": app.tr("Unnamed point"),
            "x": geocoordinate.longitude,
            "y": geocoordinate.latitude,
        }]);
    }

    function coordinatesMatch(a, b) {
        // Return true if coordinates match given a sufficient tap buffer.
        var epsLon = map.pixelRatio * 30 * area.degLonPerPixel;
        var epsLat = map.pixelRatio * 30 * area.degLatPerPixel;
        return (Math.abs(a.longitude - b.longitude) < epsLon &&
                Math.abs(a.latitude  - b.latitude ) < epsLat);

    }

}
