/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2014-2017 Osmo Salomaa, 2018-2020 Rinigus
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

Item {
    id: navigator

    property string destDist:  ""
    property string destEta:  ""
    property string destTime:  ""
    property var    direction: undefined
    property string icon:      ""
    property string manDist:   ""
    property string manTime:   ""
    property string narrative: ""
    property bool   notify:    app.conf.showNarrative && app.mode === modes.navigate && (icon || narrative)
    property real   progress:  0
    property bool   reroute:   false
    property var    sign:      undefined
    property var    street:    undefined
    property string totalDist: ""
    property string totalTime: ""
    property string voiceUri:  ""

    Timer {
        // timer for updating navigation instructions
        id: narrationTimer
        interval: app.mode === modes.navigate ? 1000 : 3000
        repeat: true
        running: app.running && map.hasRoute
        triggeredOnStart: true

        property var coordPrev: QtPositioning.coordinate()
        property var timePrev: 0

        property bool _callRunning: false

        onRunningChanged: {
            // Always update after changing timer state.
            narrationTimer.coordPrev.longitude = 0;
            narrationTimer.coordPrev.latitude = 0;
        }

        onTriggered: {
            // Query maneuver narrative from Python and update status.
            if (_callRunning) return;
            var coord = map.position.coordinate;
            var now = Date.now() / 1000;
            // avoid updating with invalid coordinate or too soon unless we don't have total data
            if (app.navigator.totalDist) {
                if (now - timePrev < 60 &&
                        ( (narrationTimer.coordPrev !== QtPositioning.coordinate() && coord.distanceTo(narrationTimer.coordPrev) < 10) ||
                          coord === QtPositioning.coordinate() )) return;
            }
            _callRunning = true;
            var accuracy = map.position.horizontalAccuracyValid ?
                        map.position.horizontalAccuracy : null;
            var args = [coord.longitude, coord.latitude, accuracy, app.mode === modes.navigate];
            py.call("poor.app.narrative.get_display", args, function(status) {
                navigator.updateStatus(status);
                if (navigator.voiceUri && app.conf.voiceNavigation) {
                    sound.source = navigator.voiceUri;
                    sound.play();
                }
                if (navigator.reroute) app.rerouteMaybe();

                narrationTimer.coordPrev.longitude = coord.longitude;
                narrationTimer.coordPrev.latitude = coord.latitude;
                narrationTimer.timePrev = now;
                _callRunning = false;
            });
        }
    }

    function clearStatus() {
        // Reset all navigation status properties.
        destDist  = "";
        destTime  = "";
        direction = undefined;
        icon      = "";
        manDist   = "";
        manTime   = "";
        narrative = "";
        progress  = 0;
        reroute   = false;
        sign      = undefined;
        street    = undefined;
        totalDist = "";
        totalTime = "";
        voiceUri  = "";
    }

    function updateStatus(data) {
        // Update navigation status with data from Python backend.
        if (!data) return;
        destDist  = data.dest_dist  || "";
        destEta   = data.dest_eta   || "";
        destTime  = data.dest_time  || "";
        if (data.direction !== undefined && data.direction !== null) direction = data.direction;
        else direction = undefined;
        icon      = data.icon       || "";
        manDist   = data.man_dist   || "";
        manTime   = data.man_time   || "";
        narrative = data.narrative  || "";
        progress  = data.progress   || 0;
        reroute   = data.reroute    || false;
        sign      = data.sign       || undefined;
        street    = data.street     || undefined;
        totalDist = data.total_dist || "";
        totalTime = data.total_time || "";
        voiceUri  = data.voice_uri  || "";
    }

}
