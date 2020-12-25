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

    property alias  destDist:  navigatorBase.destDist
    property alias  destEta:   navigatorBase.destEta
    property alias  destTime:  navigatorBase.destTime
    property bool   destReached: false
    property var    direction: navigatorBase.directionValid ? navigatorBase.direction : undefined
    property bool   followMe:  false
    property bool   hasBeenAlongRoute: false
    property bool   hasRoute:  navigatorBase.route.length > 0
    property alias  icon:      navigatorBase.icon
    property alias  maneuvers: navigatorBase.maneuvers
    property alias  manDist:   navigatorBase.manDist
    property alias  manTime:   navigatorBase.manTime
    property alias  narrative: navigatorBase.narrative
    property alias  nextIcon:  navigatorBase.nextIcon
    property alias  nextManDist: navigatorBase.nextManDist
    property bool   notify:    app.conf.showNarrative && app.mode === modes.navigate && (icon || narrative)
    property real   progress:  navigatorBase.progress / 100.0
    property string provider
    property int    rerouteConsecutiveErrors: 0
    property int    rerouteConsecutiveIgnored: 0
    property real   reroutePreviousTime: -1
    property int    rerouteTotalCalls: 0
    property bool   rerouting: false
    property alias  roundaboutExit: navigatorBase.roundaboutExit
    property alias  route:     navigatorBase.route
    property alias  running:   navigatorBase.running
    property alias  sign:      navigatorBase.sign
    property alias  street:    navigatorBase.street
    property alias  totalDist: navigatorBase.totalDist
    property alias  totalTime: navigatorBase.totalTime
    property alias  transportMode: navigatorBase.mode

    NavigatorBase {
        id: navigatorBase
        units: app.conf.units

        property bool voicePrepared: false

        onNavigationEnded: {
            if (app.mode === modes.navigate) {
                notification.flash(app.tr("Destination reached"),
                                   "navigatorStop");
                destReached = true;
            }
        }

        onPromptPlay: {
            if (!app.conf.voiceNavigation) return;
            voice.play(text);
        }

        onPromptPrepare: {
            if (!app.conf.voiceNavigation) return;
            voice.prepare(text, preserve)
        }

        onRerouteRequest: rerouteMaybe()

        onAlongRouteChanged: {
            if (!hasBeenAlongRoute && alongRoute) hasBeenAlongRoute = true;
        }

        onRunningChanged: {
            if (running && followMe)
                followMe = false;

            if (destReached)
                destReached = false;

            if (running) {
                rerouteConsecutiveErrors = 0;
                rerouteConsecutiveIgnored = 0;
                reroutePreviousTime = -1;
                rerouteTotalCalls = 0;
                hasBeenAlongRoute = alongRoute;
                updatePosition();
            }

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
            if (destReached) return; // no more updates
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
        var notifyId = "reroute";
        app.notification.hold(app.tr("Rerouting"), notifyId);
        navigatorBase.prompt("std:rerouting");
        rerouting = true;
        if (!hasBeenAlongRoute) rerouteConsecutiveIgnored++;
        hasBeenAlongRoute = false;
        // Note that rerouting does not allow us to relay params to the router,
        // i.e. ones saved only temporarily as page.params in RoutePage.qml.
        var loc = navigatorBase.locations;
        loc.splice(0, 0, app.getPosition());
        var args = [loc, gps.direction];
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
        if (hasBeenAlongRoute) rerouteConsecutiveIgnored = 0;
        var interval = 5000*Math.pow(2, Math.min(4, rerouteConsecutiveErrors + rerouteConsecutiveIgnored));
        if (py.evaluate("poor.app.router.offline")) {
            if (Date.now() - reroutePreviousTime < interval) return;
            return reroute();
        } else {
            // Limit the total amount and frequency of rerouting for online routers
            // to avoid an excessive amount of API calls (causing data traffic and
            // costs) in some special case where the router returns bogus results
            // and the user is not able to manually intervene.
            if (rerouteTotalCalls > 50) return;
            if (Date.now() - reroutePreviousTime < interval) return;
            return reroute();
        }
    }

    function saveRoute(route_in) {
        // Save route polyline to JSON file.
        var data = Util.polylineToJson(route_in);
        py.call_sync("poor.storage.write_route", [data]);
    }

    function setRoute(route, amend) {
        // Set new route
        navigatorBase.setRoute(route);
        provider = route.provider;
        saveRoute(route);
    }

}
