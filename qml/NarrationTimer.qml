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

TimerExt {
    id: timer
    interval: app.mode === modes.navigate ? 1000 : 3000
    repeat: true
    running: app.running && map.hasRoute
    triggeredOnStart: true

    property var coordPrev: QtPositioning.coordinate()
    property var timePrev: 0

    property bool _callRunning: false

    onRunningChanged: {
        // Always update after changing timer state.
        timer.coordPrev.longitude = 0;
        timer.coordPrev.latitude = 0;
    }

    onTriggered: {
        // Query maneuver narrative from Python and update status.
        if (_callRunning) return;
        var coord = map.position.coordinate;
        var now = Date.now() / 1000;
        // avoid updating with invalid coordinate or too soon unless we don't have total data
        if (app.navigationStatus.totalDist) {
            if (now - timePrev < 60 &&
                    ( (timer.coordPrev !== QtPositioning.coordinate() && coord.distanceTo(timer.coordPrev) < 10) ||
                      coord === QtPositioning.coordinate() )) return;
        }
        _callRunning = true;
        var accuracy = map.position.horizontalAccuracyValid ?
                    map.position.horizontalAccuracy : null;
        var args = [coord.longitude, coord.latitude, accuracy, app.mode === modes.navigate];
        py.call("poor.app.narrative.get_display", args, function(status) {
            app.updateNavigationStatus(status);
            timer.coordPrev.longitude = coord.longitude;
            timer.coordPrev.latitude = coord.latitude;
            timer.timePrev = now;
            _callRunning = false;
        });
    }

}
