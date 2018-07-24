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
import "."

import "js/util.js" as Util

PositionSourceMapMatched {
    id: gps

    // If application is no longer active, turn positioning off immediately
    // if we already have a lock, otherwise keep trying for a couple minutes
    // and give up if we still don't gain that lock.
    active: app.running || (coordHistory.length === 0 && timePosition - timeActivate < 180000)

    mapMatchingMode: {
        if (app.mapMatchingMode == "none") return 0;
        else if (app.mapMatchingMode == "car") return 2;
        else if (app.mapMatchingMode == "bicycle") return 3;
        else if (app.mapMatchingMode == "foot") return 5;
        return 0;
    }

    property var coordHistory: []
    property bool directionCalculated: false
    property var directionHistory: []
    property var ready: false
    property var timeActivate:  Date.now()
    property var timeDirection: Date.now()
    property var timePosition:  Date.now()

    onActiveChanged: {
        // Keep track of when positioning was (re)activated.
        if (gps.active) gps.timeActivate = Date.now();
    }

    onPositionChanged: {
        // proceed only if map matching does not provide direction
        if (directionValid) return;
        // Calculate direction as a median of individual direction values
        // calculated after significant changes in position. This should be
        // more stable than any direct value and usable with map.autoRotate.
        gps.ready = gps.position.latitudeValid &&
            gps.position.longitudeValid &&
            gps.position.coordinate.latitude &&
            gps.position.coordinate.longitude;
        gps.timePosition = Date.now();
        var threshold = gps.position.horizontalAccuracy || 15;
        if (threshold < 0 || threshold > 40) return;
        var coord = gps.position.coordinate;
        if (gps.coordHistory.length === 0)
            gps.coordHistory.push(QtPositioning.coordinate(
                coord.latitude, coord.longitude));
        var coordPrev = gps.coordHistory[gps.coordHistory.length-1];
        if (coordPrev.distanceTo(coord) > threshold) {
            gps.coordHistory.push(QtPositioning.coordinate(
                coord.latitude, coord.longitude));
            gps.coordHistory = gps.coordHistory.slice(-3);
            // XXX: Direction is missing from gps.position.
            // https://bugreports.qt.io/browse/QTBUG-36298
            var direction = coordPrev.azimuthTo(coord);
            gps.directionHistory.push(direction);
            gps.directionHistory = gps.directionHistory.slice(-3);
            if (gps.directionHistory.length >= 3) {
                gps.direction = Util.median(gps.directionHistory);
                gps.timeDirection = Date.now();
                gps.directionCalculated = true;
            }
        } else if (gps.direction && Date.now() - gps.timeDirection > 300000) {
            // Clear direction if we have not seen any valid updates in a while.
            gps.coordHistory = [];
            gps.directionCalculated = false;
            gps.directionHistory = [];
        }
    }

    onDirectionValidChanged: {
        // Clear direction if we switchid to map matched directions
        if (!directionValid) return;
        gps.coordHistory = [];
        gps.directionCalculated = false;
        gps.directionHistory = [];
    }
}
