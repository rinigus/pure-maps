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

import "js/util.js" as Util

Item {
    id: navigator

    property string destDist:  ""
    property string destEta:   ""
    property string destTime:  ""
    property var    direction: undefined
    property bool   hasRoute:  false
    property string icon:      ""
    property var    maneuvers: []
    property string manDist:   ""
    property string manTime:   ""
    property string narrative: ""
    property bool   notify:    app.conf.showNarrative && app.mode === modes.navigate && (icon || narrative)
    property real   progress:  0
    property int    rerouteConsecutiveErrors: 0
    property real   reroutePreviousTime: -1
    property int    rerouteTotalCalls: 0
    property bool   rerouting: false
    property var    route:     {}
    property var    sign:      undefined
    property var    street:    undefined
    property string totalDist: ""
    property string totalTime: ""
    property string transportMode: route && route.mode ? route.mode : ""
    property string voiceUri:  ""

    property bool   _voiceNavigation: app.conf.voiceNavigation && app.mode === modes.navigate

    Timer {
        // timer for updating navigation instructions
        id: narrationTimer
        interval: app.mode === modes.navigate ? 1000 : 3000
        repeat: true
        running: app.running && navigator.hasRoute
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
            var coord = app.position.coordinate;
            var now = Date.now() / 1000;
            // avoid updating with invalid coordinate or too soon unless we don't have total data
            if (app.navigator.totalDist) {
                if (now - timePrev < 60 &&
                        ( (narrationTimer.coordPrev !== QtPositioning.coordinate() && coord.distanceTo(narrationTimer.coordPrev) < 10) ||
                         coord === QtPositioning.coordinate() )) return;
            }
            _callRunning = true;
            var accuracy = app.position.horizontalAccuracyValid ?
                        app.position.horizontalAccuracy : null;
            var args = [coord.longitude, coord.latitude, accuracy, app.mode === modes.navigate];
            py.call("poor.app.narrative.get_display", args, function(status) {
                navigator.updateStatus(status);
                if (navigator.voiceUri && app.conf.voiceNavigation) {
                    sound.source = navigator.voiceUri;
                    sound.play();
                }
                if (status.reroute) navigator.rerouteMaybe();

                narrationTimer.coordPrev.longitude = coord.longitude;
                narrationTimer.coordPrev.latitude = coord.latitude;
                narrationTimer.timePrev = now;
                _callRunning = false;
            });
        }
    }


    Component.onCompleted: {
        loadRoute();
    }

    on_VoiceNavigationChanged: initVoiceNavigation()

    function clearRoute() {
        // Remove route
        maneuvers = [];
        route = {};
        py.call("poor.app.narrative.unset", [], null);
        clearStatus();
        hasRoute = false;
        saveRoute();
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
        sign      = undefined;
        street    = undefined;
        totalDist = "";
        totalTime = "";
        voiceUri  = "";
    }

    function getDestination() {
        // Return coordinates of the route destination.
        var destination = navigator.route.coordinates[navigator.route.coordinates.length - 1];
        return [destination.longitude, destination.latitude];
    }

    function initVoiceNavigation() {
        // Initialize a TTS engine for the current routing instructions.
        if (_voiceNavigation) {
            var args = [app.conf.voiceGender];
            py.call_sync("poor.app.narrative.set_voice", args);
            var engine = py.evaluate("poor.app.narrative.voice_engine");
            if (engine) {
                notification.flash(app.tr("Voice navigation on"), "navVoice");
                app.playMaybe("std:starting navigation");
            } else
                notification.flash(app.tr("Voice navigation unavailable: missing Text-to-Speech (TTS) engine for selected language"),
                                   "navVoice");
        } else {
            py.call_sync("poor.app.narrative.unset_voice", []);
        }
    }

    function loadRoute() {
        // Restore route polyline from JSON file.
        py.call("poor.storage.read_route", [], function(data) {
            data.x && data.x.length > 0 && setRoute(data);
        });
    }

    function reroute() {
        // Find a new route from the current position to the existing destination.
        if (rerouting) return;
        var notifyId = "app reroute";
        app.notification.hold(app.tr("Rerouting"), notifyId);
        app.playMaybe("std:rerouting");
        rerouting = true;
        // Note that rerouting does not allow us to relay params to the router,
        // i.e. ones saved only temporarily as page.params in RoutePage.qml.
        var args = [app.getPosition(), getDestination(), gps.direction];
        py.call("poor.app.router.route", args, function(route) {
            if (Array.isArray(route) && route.length > 0)
                // If the router returns multiple alternative routes,
                // always reroute using the first one.
                route = route[0];
            if (route && route.error && route.message) {
                app.notification.flash(app.tr("Rerouting failed: %1").arg(route.message), notifyId);
                app.playMaybe("std:rerouting failed");
                rerouteConsecutiveErrors++;
            } else if (route && route.x && route.x.length > 0) {
                app.notification.flash(app.tr("New route found"), notifyId);
                app.playMaybe("std:new route found");
                setRoute(route, true);
                rerouteConsecutiveErrors = 0;
            } else {
                app.notification.flash(app.tr("Rerouting failed"), notifyId);
                app.playMaybe("std:rerouting failed");
                rerouteConsecutiveErrors++;
            }
            reroutePreviousTime = Date.now();
            rerouteTotalCalls++;
            rerouting = false;
        });
    }

    function rerouteMaybe() {
        // Find a new route if conditions are met.
        if (!app.conf.reroute) return;
        if (app.mode !== modes.navigate) return;
        if (!gps.position.horizontalAccuracyValid) return;
        if (gps.position.horizontalAccuracy > 100) return;
        if (!py.evaluate("poor.app.router.can_reroute")) return;
        if (py.evaluate("poor.app.router.offline")) {
            if (Date.now() - app.reroutePreviousTime < 5000) return;
            return reroute();
        } else {
            // Limit the total amount and frequency of rerouting for online routers
            // to avoid an excessive amount of API calls (causing data traffic and
            // costs) in some special case where the router returns bogus results
            // and the user is not able to manually intervene.
            if (rerouteTotalCalls > 50) return;
            var interval = 5000 * Math.pow(2, Math.min(4, rerouteConsecutiveErrors));
            if (Date.now() - app.reroutePreviousTime < interval) return;
            return reroute();
        }
    }

    function setManeuvers(maneuvers) {
        var m = maneuvers.map(function (maneuver) {
            return {
                "arrive_instruction": maneuver.arrive_instruction || "",
                "depart_instruction": maneuver.depart_instruction || "",
                "coordinate": QtPositioning.coordinate(maneuver.y, maneuver.x),
                "duration": maneuver.duration || 0,
                "icon": maneuver.icon || "flag",
                // Needed to have separate layers via filters.
                "name": maneuver.passive ? "passive" : "active",
                "narrative": maneuver.narrative || "",
                "passive": maneuver.passive || false,
                "sign": maneuver.sign || undefined,
                "street": maneuver.street|| undefined,
                "travel_type": maneuver.travel_type || "",
                "verbal_alert": maneuver.verbal_alert || "",
                "verbal_post": maneuver.verbal_post || "",
                "verbal_pre": maneuver.verbal_pre || "",
            };
        });
        navigator.maneuvers = m;
        py.call("poor.app.narrative.set_maneuvers", [maneuvers], null);
    }

    function setRoute(route, amend) {
        // Set new route
        clearRoute();
        route.coordinates = route.x.map(function(value, i) {
            return QtPositioning.coordinate(route.y[i], route.x[i]);
        });
        navigator.route = route;
        py.call("poor.app.narrative.set_language", [route.language || "en"], null);
        py.call("poor.app.narrative.set_mode", [route.mode || "car"], null);
        py.call("poor.app.narrative.set_route", [route.x, route.y], function() {
            navigator.hasRoute = true;
        });
        if (route.maneuvers !== undefined && route.maneuvers !== null) {
            //navigator.route.maneuvers = route.maneuvers;
            setManeuvers(route.maneuvers);
        }
        saveRoute();
        if (!amend) app.setModeExploreRoute();
    }

    function saveRoute() {
        // Save route polyline to JSON file.
        var data = Util.polylineToJson(navigator.route);
        py.call_sync("poor.storage.write_route", [data]);
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
        // reroute checked in narration timer and clashes with the method name.
        // no need to set it as a property
        sign      = data.sign       || undefined;
        street    = data.street     || undefined;
        totalDist = data.total_dist || "";
        totalTime = data.total_time || "";
        voiceUri  = data.voice_uri  || "";
    }

}
