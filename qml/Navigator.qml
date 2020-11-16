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
import org.puremaps 1.0

import "js/util.js" as Util

Item {
    id: navigator

    property string destDist:  navigatorBase.destDist
    property string destEta:   navigatorBase.destEta
    property string destTime:  navigatorBase.destTime
    property var    direction: navigatorBase.onRoute ? navigatorBase.bearing : undefined
    property bool   hasRoute:  route.length > 0
    property string icon:      navigatorBase.icon
    property var    maneuvers: []
    property string manDist:   navigatorBase.manDist
    property string manTime:   navigatorBase.manTime
    property string narrative: navigatorBase.narrative
    property bool   notify:    app.conf.showNarrative && app.mode === modes.navigate && (icon || narrative)
    property real   progress:  navigatorBase.progress
    property string provider
    property int    rerouteConsecutiveErrors: 0
    property real   reroutePreviousTime: -1
    property int    rerouteTotalCalls: 0
    property bool   rerouting: false
    property var    route:     navigatorBase.route
    property var    sign:      navigatorBase.sign
    property var    street:    navigatorBase.street
    property string totalDist: navigatorBase.totalDist
    property string totalTime: navigatorBase.totalTime
    property string transportMode: navigatorBase.mode

    NavigatorBase {
        id: navigatorBase
        units: app.conf.units
        running: app.mode === modes.navigate && route.length > 0

        property bool voicePrepared: false

        onRerouteRequest: rerouteMaybe()

        onPromptPlay: {
            if (!app.conf.voiceNavigation) return;
            voice.play(text);
        }

        onPromptPrepare: {
            if (!app.conf.voiceNavigation) return;
            voice.prepare(text, preserve)
        }

        onRunningChanged: {
            if (running) updatePosition();

            if (running && app.conf.voiceNavigation) {
                // check if the call was caused by rerouting, for example
                if (voicePrepared) return;

                if (voice.active) {
                    notification.flash(app.tr("Voice navigation on"), "navVoice");
                    navigatorBase.prepareStandardPrompts();
                    navigatorBase.prompt("std:starting navigation");
                    voicePrepared = true;
                } else {
                    notification.flash(app.tr("Voice navigation unavailable: missing Text-to-Speech (TTS) engine for selected language"),
                                       "navVoice");
                }
            } else {
                voicePrepared = false;
            }
        }

        function updatePosition() {
            navigatorBase.setPosition(app.position.coordinate,
                                      app.position.horizontalAccuracy,
                                      app.position.horizontalAccuracyValid && app.position.latitudeValid && app.position.longitudeValid);
        }
    }

    Voice {
        id: voice
        enabled: app.conf.voiceNavigation
        engine: "navigator"
        gender: app.conf.voiceGender
        language: navigatorBase.language
    }

    Connections {
        target: app
        onPositionChanged: navigatorBase.updatePosition()
    }

    Component.onCompleted: {
        loadRoute();
    }

    function clearRoute() {
        navigatorBase.clearRoute();
        // Remove route
        maneuvers = [];
        //route = {};
        py.call("poor.app.narrative.unset", [], null);
        provider = "";
        saveRoute({});
    }

    function getDestination() {
        // Return coordinates of the route destination.
        var destination = navigator.route[navigator.route.length - 1];
        return [destination.longitude, destination.latitude];
    }

    function loadRoute() {
        // Restore route polyline from JSON file.
        py.call("poor.storage.read_route", [], function(data) {
            if (data.x && data.x.length > 0) setRoute(data);
        });
    }

    function reroute() {
        // Find a new route from the current position to the existing destination.
        if (rerouting) return;
        var notifyId = "app reroute";
        app.notification.hold(app.tr("Rerouting"), notifyId);
        navigatorBase.prompt("std:rerouting");
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
                navigatorBase.prompt("std:rerouting failed");
                rerouteConsecutiveErrors++;
            } else if (route && route.x && route.x.length > 0) {
                app.notification.flash(app.tr("New route found"), notifyId);
                navigatorBase.prompt("std:new route found");
                setRoute(route, true);
                rerouteConsecutiveErrors = 0;
            } else {
                app.notification.flash(app.tr("Rerouting failed"), notifyId);
                navigatorBase.prompt("std:rerouting failed");
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
    }

    function setRoute(route, amend) {
        // Set new route
        navigatorBase.setRoute(route);
        provider = route.provider;
        if (route.maneuvers != null) {
            setManeuvers(route.maneuvers);
        }
        saveRoute(route);
        if (!amend) app.setModeExploreRoute();
    }

    function saveRoute(route_in) {
        // Save route polyline to JSON file.
        var data = Util.polylineToJson(route_in);
        py.call_sync("poor.storage.write_route", [data]);
    }

}
