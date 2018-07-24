/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2017 Osmo Salomaa
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

QtObject {
    id: status

    property string destDist:  ""
    property string destTime:  ""
    property var    direction: undefined
    property string icon:      ""
    property string manDist:   ""
    property string manTime:   ""
    property string narrative: ""
    property bool   notify:    app.showNarrative && (icon || narrative)
    property real   progress:  0
    property bool   reroute:   false
    property string totalDist: ""
    property string totalTime: ""
    property string voiceUri:  ""

    function clear() {
        // Reset all navigation status properties.
        status.destDist  = "";
        status.destTime  = "";
        status.direction = undefined;
        status.icon      = "";
        status.manDist   = "";
        status.manTime   = "";
        status.narrative = "";
        status.progress  = 0;
        status.reroute   = false;
        status.totalDist = "";
        status.totalTime = "";
        status.voiceUri  = "";
    }

    function update(data) {
        // Update navigation status with data from Python backend.
        if (!data) return;
        status.destDist  = data.dest_dist  || "";
        status.destTime  = data.dest_time  || "";
        if (data.direction !== undefined && data.direction !== null) status.direction = data.direction;
        else status.direction = undefined;
        status.icon      = data.icon       || "";
        status.manDist   = data.man_dist   || "";
        status.manTime   = data.man_time   || "";
        status.narrative = data.narrative  || "";
        status.progress  = data.progress   || 0;
        status.reroute   = data.reroute    || false
        status.totalDist = data.total_dist || "";
        status.totalTime = data.total_time || "";
        status.voiceUri  = data.voice_uri  || "";
    }

}
