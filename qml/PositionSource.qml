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
import QtPositioning 5.4
import "."

import "js/util.js" as Util

PositionSourceMapMatched {
    id: gps

    // If application is no longer active, turn positioning off immediately
    // if we already have a lock, otherwise keep trying for a couple minutes
    // and give up if we still don't gain that lock.
    active: app.running || (!accurate && timePosition - timeActivate < 180000)

    mapMatchingMode: {
        if (app.mapMatchingMode == "none") return 0;
        else if (app.mapMatchingMode == "car") return 1;
        else if (app.mapMatchingMode == "bicycle") return 3;
        else if (app.mapMatchingMode == "foot") return 5;
        return 0;
    }

    testingCoordinate: app.conf.developmentCoordinateCenter ? map.center : undefined

    property bool accurate: ready &&
                            position.horizontalAccuracyValid &&
                            position.horizontalAccuracy > 0 &&
                            position.horizontalAccuracy < 25
    property var  ready: false
    property var  timeActivate:  Date.now()
    property var  timePosition:  Date.now()

    Component.onCompleted: checkReady()

    onActiveChanged: {
        // Keep track of when positioning was (re)activated.
        if (active) timeActivate = Date.now();
        checkReady();
    }

    onPositionChanged: {
        timePosition = Date.now();
        checkReady();
    }

    function checkReady() {
        ready = position.latitudeValid &&
                position.longitudeValid &&
                position.coordinate.latitude &&
                position.coordinate.longitude;
    }
}
