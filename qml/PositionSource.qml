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

PositionSource {
    id: gps
    active: app.running
    updateInterval: 1000
    property var coordPrev: undefined
    property var direction: undefined
    property var timePrev: -1
    Component.onCompleted: gps.initProperties();
    onPositionChanged: {
        // XXX: Calculate direction, since it's missing from gps.position.
        // http://bugreports.qt.io/browse/QTBUG-36298
        var threshold = gps.position.horizontalAccuracy || 15;
        if (threshold < 0 || threshold > 30) return;
        var coord = gps.position.coordinate;
        if (!gps.coordPrev) {
            gps.coordPrev = QtPositioning.coordinate(coord.latitude, coord.longitude);
        } else if (gps.coordPrev.distanceTo(coord) > threshold) {
            gps.direction = gps.coordPrev.azimuthTo(coord);
            gps.coordPrev.longitude = coord.longitude;
            gps.coordPrev.latitude = coord.latitude;
            gps.timePrev = Date.now();
        } else if (gps.direction && Date.now() - gps.timePrev > 5*60*1000) {
            gps.direction = undefined;
        }
    }
    function initProperties() {
        if (!py.ready)
            return py.onReadyChanged.connect(gps.initProperties);
        gps.updateInterval = app.conf.get("gps_update_interval");
    }
}
