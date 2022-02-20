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
import QtPositioning 5.4
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
    property bool   hasDestination: locationsModel.hasDestination
    property bool   hasNextLocation: nextLocationDist
    property bool   hasOrigin: locationsModel.hasOrigin
    property bool   hasRoute:  navigatorBase.route.length > 0
    property bool   hasTraffic: navigatorBase.hasTraffic
    property alias  icon:      navigatorBase.icon
    property alias  locations: navigatorBase.locations
    property alias  locationsModel: navigatorBase.locationsModel
    property alias  maneuvers: navigatorBase.maneuvers
    property alias  manDist:   navigatorBase.manDist
    property alias  manTime:   navigatorBase.manTime
    property alias  narrative: navigatorBase.narrative
    property alias  nextIcon:  navigatorBase.nextIcon
    property bool   nextLocationDestination: locationsModel.nextLocationDestination
    property string nextLocationDist: locationsModel.nextLocationDist
    property string nextLocationEta: locationsModel.nextLocationEta
    property string nextLocationTime: locationsModel.nextLocationTime
    property alias  nextManDist: navigatorBase.nextManDist
    property bool   notify:    app.conf.showNarrative && app.mode === modes.navigate && (icon || narrative)
    property alias  optimized: navigatorBase.optimized
    property real   progress:  navigatorBase.progress / 100.0
    property string provider
    property int    rerouteConsecutiveErrors: 0
    property int    rerouteConsecutiveIgnored: 0
    property real   reroutePreviousTime: -1
    property bool   routing: false
    property alias  roundaboutExit: navigatorBase.roundaboutExit
    property alias  route:     navigatorBase.route
    property alias  running:   navigatorBase.running
    property alias  sign:      navigatorBase.sign
    property alias  street:    navigatorBase.street
    property alias  totalDist: navigatorBase.totalDist
    property alias  totalTime: navigatorBase.totalTime
    property alias  totalTimeInTraffic: navigatorBase.totalTimeInTraffic
    property alias  transportMode: navigatorBase.mode

    NavigatorBase {
        id: navigatorBase
        horizontalAccuracy: app.conf.navigationHorizontalAccuracy
        trafficRerouteTime: app.conf.trafficRerouteTime
        units: app.conf.units

        property bool voicePrepared: false

        onLocationArrived: {
            if (app.mode === modes.navigate) {
                notification.flash(destination ? app.tr("Destination %1 reached", name) :
                                                 app.tr("Waypoint %1 reached", name),
                                   "navigatorStop");
            }
        }

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

        onRerouteRequest: {
            // Find a new route if conditions are met.
            if (!app.conf.reroute) return;
            if (app.mode !== modes.navigate) return;
            if (!gps.horizontalAccuracyValid || !gps.ready) return;
            if (gps.horizontalAccuracy > 100) return;
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
                if (Date.now() - reroutePreviousTime < interval) return;
                return reroute(traffic);
            }
        }

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
            navigatorBase.setPosition(gps.coordinate,
                                      gps.directionDeviceValid ? gps.directionDevice : gps.direction,
                                      gps.horizontalAccuracy,
                                      gps.horizontalAccuracyValid &&
                                      gps.ready &&
                                      gps.directionValid);
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
        target: gps
        onPositionUpdated: navigatorBase.updatePosition()
    }

    Component.onCompleted: {
        loadRoute();
    }

    function clearRoute() {
        navigatorBase.clearRoute();
        provider = "";
        saveRoute({});
    }

    function findRoute(locations, options, traffic) {
        if (routing) return;
        if (!options) options = {};
        options.optimized = navigatorBase.optimized;
        var notifyId = "route";
        var loc = locations || navigatorBase.locations;
        // note that GPX trace does not use locations
        if (loc.length >= 1 && !loc[0].origin) {
            if (!gps.coordinateValid) {
                app.notification.flash(app.tr("Routing failed: current position not known"), notifyId);
                return;
            }
            var p = app.getPosition();
            loc.splice(0, 0,
                       {"text": navigatorBase.running ?
                                    app.tr("Rerouting position") :
                                    app.tr("Current position"),
                                    "x": p[0], "y": p[1]});
        }
        // filter out arrived locations
        loc = loc.filter(function (l) {
           return !l.arrived;
        });
        var notification  = options.notification || app.tr("Routing")
        app.notification.hold(notification, notifyId);
        routing = true;
        var args = [loc,
                    options];
        py.call("poor.app.router.route", args, function(route) {
            if (Array.isArray(route) && route.length > 0)
                // If the router returns multiple alternative routes,
                // always route using the first one.
                route = route[0];
            if (route && route.error && route.message) {
                app.notification.flash(app.tr("Routing failed: %1").arg(route.message), notifyId);
                if (options.voicePrompt) navigatorBase.prompt("std:routing failed");
                rerouteConsecutiveErrors++;
            } else if (route && route.x && route.x.length > 0) {
                app.notification.flash(navigatorBase.running ?
                                           (traffic ? app.tr("Traffic and route updated") : app.tr("New route found")) :
                                           app.tr("Route found"), notifyId);
                if (options.voicePrompt) navigatorBase.prompt(traffic ? "std:traffic updated" :
                                                                        "std:new route found");
                setRoute(route);
                rerouteConsecutiveErrors = 0;
                if (options.fitToView) map.fitViewToRoute();
                if (options.save) {
                    saveDestination();
                    saveLocations();
                }
            } else {
                app.notification.flash(app.tr("Routing failed"), notifyId);
                if (options.voicePrompt) navigatorBase.prompt("std:routing failed");
                rerouteConsecutiveErrors++;
            }
            routing = false;
        });
    }

    function loadRoute() {
        // Restore route polyline from JSON file.
        py.call("poor.storage.read_route", [], function(data) {
            if (data.x && data.x.length > 0) setRoute(data);
        });
    }

    function locationRemove(index) {
        if (!navigatorBase.locationRemove(index)) {
            console.log("Failed to remove location " + index);
            return false;
        }
        return true;
    }

    function reroute(traffic) {
        // Find a new route from the current position to the existing destination.
        if (routing) return;
        if (!traffic) navigatorBase.prompt("std:rerouting");
        if (!hasBeenAlongRoute) rerouteConsecutiveIgnored++;
        hasBeenAlongRoute = false;
        var loc = navigatorBase.locations.slice(1);
        var options = {
            "heading": gps.direction,
            "notification": traffic ? app.tr("Updating traffic"): app.tr("Rerouting"),
            "voicePrompt": true
        }
        findRoute(loc, options, traffic);
        reroutePreviousTime = Date.now();
    }

    function saveDestination() {
        // Save destinations if not POIs
        var _destinationsNotForSave = [];
        var pois = app.pois.pois.filter(function (p) {
            return (p.bookmarked && p.shortlisted);
        });
        pois.sort(function (a, b){
            if (a.title < b.title) return -1;
            if (a.title > b.title) return 1;
            return 0;
        })
        pois.forEach(function (p) {
            var t = {
                "text": (p.title ? p.title : app.tr("Unnamed point")) +
                        (p.shortlisted ? " ☰" : ""),
                "toText": p.title ? p.title : app.tr("Unnamed point"),
                "type": "poi",
                "visible": true,
                "x": p.coordinate.longitude,
                "y": p.coordinate.latitude
            };
            _destinationsNotForSave.push(t);
        });

        var loc = navigatorBase.locations;
        var dest = loc[ loc.length - 1 ];

        for (var i=0; i < _destinationsNotForSave.length; i++)
            if (dest.text === _destinationsNotForSave[i].toText &&
                    Math.abs(dest.x -_destinationsNotForSave[i].x) < 1e-8 &&
                    Math.abs(dest.y -_destinationsNotForSave[i].y) < 1e-8)
                return false;

        if (!dest.text)
            return false;

        py.call_sync("poor.app.history.add_destination", [dest]);
        return true;
    }

    function saveLocations() {
        py.call_sync("poor.app.history.add_route",
                     [{  "locations": navigatorBase.locations,
                         "optimized": navigatorBase.optimized }]);
    }

    function saveRoute(route_in) {
        // Save route polyline to JSON file.
        var data = Util.polylineToJson(route_in);
        py.call_sync("poor.storage.write_route", [data]);
    }

    function setRoute(route) {
        // Set new route
        navigatorBase.setRoute(route);
        provider = route.provider;
        saveRoute(route);
    }

}
