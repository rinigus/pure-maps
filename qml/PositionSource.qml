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

PositionSource {
    id: gps
    active: false
    updateInterval: 1000
    property var direction
    property var prevCoordinate
    property int prevTime
    Component.onCompleted: {
        py.onReadyChanged.connect(function() {
            gps.updateInterval = py.evaluate("poor.conf.gps_update_interval");
        });
    }
    onPositionChanged: {
        // Calculate direction, since it's missing from gps.position.
        // http://bugreports.qt-project.org/browse/QTBUG-36298
        var threshold = gps.position.horizontalAccuracy || 15;
        if (threshold > 0 && threshold < 30 && gps.prevCoordinate &&
            gps.prevCoordinate.distanceTo(gps.position.coordinate) > threshold) {
            gps.direction = gps.prevCoordinate.azimuthTo(gps.position.coordinate);
            gps.prevCoordinate = gps.position.coordinate;
            gps.prevTime = Date.now();
        } else if (!gps.prevCoordinate) {
            gps.prevCoordinate = gps.position.coordinate;
        } else if (gps.direction && Date.now() - gps.prevTime > 5*60*1000) {
            gps.direction = undefined;
        }
    }
}
