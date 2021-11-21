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
import org.puremaps 1.0 as PM

import "js/util.js" as Util

PM.PositionSource {
    id: gps

    // If application is no longer active, turn positioning off immediately
    // if we already have a lock, otherwise keep trying for a couple minutes
    // and give up if we still don't gain that lock.
    active: app.running || (!accurate && waitForLock)
    mapMatchingMode: {
            if (app.mapMatchingMode == "none") return 0;
            else if (app.mapMatchingMode == "car") return 1;
            else if (app.mapMatchingMode == "bicycle") return 3;
            else if (app.mapMatchingMode == "foot") return 5;
            return 0;
        }
    stickyDirection: app.mode === modes.navigate ||
                     app.mode === modes.followMe ||
                     app.mode === modes.navigatePost
    testingMode: app.conf.developmentCoordinateCenter

    property var  coordinate: coordinateMapMatchValid ? coordinateMapMatch : coordinateDeviceValid ? coordinateDevice : QtPositioning.coordinate(0,0)
    property bool coordinateValid: coordinateMapMatchValid || coordinateDeviceValid
    property int  direction: directionMapMatchValid ? directionMapMatch : directionDevice
    property bool directionValid: directionMapMatchValid || directionDeviceValid
    property bool waitForLock: false

    // properties used for implementation details
    property var _timer: Timer {
        interval: 180000
        repeat: false
        running: gps.active && !gps.accurate
        onTriggered: gps.waitForLock = false
        onRunningChanged: {
            if (running) gps.waitForLock = true;
            else gps.waitForLock = false;
        }
    }

    Component.onCompleted: setTestingBinding()
    onTestingModeChanged: setTestingBinding()

    function setTestingBinding() {
        // avoid setting testing coordinate updates for most of the users
        // and set it only if requested
        if (testingMode)
            testingCoordinate = Qt.binding(function() { return map.center; });
        else
            testingCoordinate = map.center; // break binding
    }
}
