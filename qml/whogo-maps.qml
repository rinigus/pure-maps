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
import QtMultimedia 5.2
import Sailfish.Silica 1.0
import org.nemomobile.keepalive 1.0
import "."

/*
 * We need to keep the map outside of the page stack so that we can easily
 * flip between the map and a particular page in a retained state.
 * To allow swiping back from the menu to the map, we need the first page
 * in the stack to be a dummy that upon activation hides the page stack.
 * To make transitions smooth and animated, we can make the dummy look like
 * the actual map, thus providing the smooth built-in page stack transition.
 */

ApplicationWindow {
    id: app
    allowedOrientations: defaultAllowedOrientations
    cover: Cover {}
    initialPage: DummyPage { id: dummy }

    property var  attributionButton: null
    property var  centerButton: null
    property var  conf: Config {}
    property bool hasMapMatching: false
    property var  map: null
    property string mapMatchingMode: {
        if (!hasMapMatching) return "none";
        if (navigationActive) return mapMatchingModeNavigation;
        return mapMatchingModeIdle;
    }
    property string mapMatchingModeIdle: "none"
    property string mapMatchingModeNavigation: "none"
    property var  menuButton: null
    property var  meters: null
    property var  narrativePageSeen: false
    property bool navigationActive: false
    property var  navigationBlock: null
    property var  navigationPageSeen: false
    property var  navigationStatus: NavigationStatus {}
    property bool navigationStarted: false
    property var  northArrow: null
    property var  notification: null
    property int  rerouteConsecutiveErrors: 0
    property var  reroutePreviousTime: -1
    property int  rerouteTotalCalls: 0
    property bool rerouting: false
    property bool running: applicationActive || cover.active
    property var  scaleBar: null
    property int  screenHeight: Screen.height
    property int  screenWidth: Screen.width
    property var  showNarrative: null

    // Default vertical margin for various multiline list items
    // such that it would be consistent with single-line list items
    // and the associated constant Theme.itemSizeSmall.
    property real listItemVerticalMargin: (Theme.itemSizeSmall - 1.125 * Theme.fontSizeMedium) / 2

    Root { id: root }
    PositionSource { id: gps }
    Python { id: py }

    Audio {
        id: sound
        autoLoad: true
        autoPlay: true
        loops: 1
    }

    Component.onCompleted: {
        updateMapMatching()
    }

    Component.onDestruction: {
        if (!py.ready) return;
        app.conf.set("auto_center", map.autoCenter);
        app.conf.set("auto_rotate", map.autoRotate);
        app.conf.set("center", [map.center.longitude, map.center.latitude]);
        app.conf.set("zoom", map.zoomLevel);
        py.call_sync("poor.app.quit", []);
    }

    Keys.onPressed: {
        // Allow zooming with plus and minus keys on the emulator.
        (event.key === Qt.Key_Plus)  && map.setZoomLevel(map.zoomLevel+1);
        (event.key === Qt.Key_Minus) && map.setZoomLevel(map.zoomLevel-1);
    }

    onApplicationActiveChanged: {
        if (!py.ready)
            return py.onReadyChanged.connect(app.updateKeepAlive);
        app.updateKeepAlive();
    }

    onNavigationActiveChanged: {
        app.updateKeepAlive();
    }

    function clearMenu() {
        // Clear the page stack and hide the menu.
        app.pageStack.pop(dummy, PageStackAction.Immediate);
        app.hideMenu();
    }

    function getIcon(name) {
        // Return path to icon suitable for user's screen,
        // finding the closest match to Theme.pixelRatio.
        var ratios = [1.00, 1.25, 1.50, 1.75, 2.00];
        var minIndex = -1, minDiff = 1000, diff;
        for (var i = 0; i < ratios.length; i++) {
            diff = Math.abs(Theme.pixelRatio - ratios[i]);
            minIndex = diff < minDiff ? i : minIndex;
            minDiff = Math.min(minDiff, diff);
        }
        var ratio = ratios[minIndex].toFixed(2);
        return "%1@%2.png".arg(name).arg(ratio);
    }

    function hideMenu() {
        // Immediately hide the menu, keeping pages intact.
        root.visible = true;
    }

    function playMaybe(message) {
        // Play message via TTS engine if applicable.
        if (!app.conf.get("voice_navigation")) return;
        var fun = "poor.app.narrative.get_message_voice_uri";
        py.call(fun, [message], function(uri) {
            if (uri) sound.source = uri;
        });
    }

    function reroute() {
        // Find a new route from the current position to the existing destination.
        if (app.rerouting) return;
        app.notification.hold(app.tr("Rerouting"));
        app.playMaybe("Rerouting");
        app.rerouting = true;
        // Note that rerouting does not allow us to relay params to the router,
        // i.e. ones saved only temporarily as page.params in RoutePage.qml.
        var args = [map.getPosition(), map.getDestination(), gps.direction];
        py.call("poor.app.router.route", args, function(route) {
            if (Array.isArray(route) && route.length > 0)
                // If the router returns multiple alternative routes,
                // always reroute using the first one.
                route = route[0];
            if (route && route.error && route.message) {
                app.notification.flash(app.tr("Rerouting failed: %1").arg(route.message));
                app.playMaybe("Rerouting failed");
                app.rerouteConsecutiveErrors++;
            } else if (route && route.x && route.x.length > 0) {
                app.notification.flash(app.tr("New route found"));
                app.playMaybe("New route found");
                map.addRoute(route, true);
                map.addManeuvers(route.maneuvers);
                app.rerouteConsecutiveErrors = 0;
            } else {
                app.notification.flash(app.tr("Rerouting failed"));
                app.playMaybe("Rerouting failed");
                app.rerouteConsecutiveErrors++;
            }
            app.reroutePreviousTime = Date.now();
            app.rerouteTotalCalls++;
            app.rerouting = false;
        });
    }

    function rerouteMaybe() {
        // Find a new route if conditions are met.
        if (!app.conf.get("reroute")) return;
        if (!app.navigationActive) return;
        if (!gps.position.horizontalAccuracyValid) return;
        if (gps.position.horizontalAccuracy > 100) return;
        if (py.evaluate("poor.app.router.offline")) {
            if (Date.now() - app.reroutePreviousTime < 5000) return;
            return app.reroute();
        } else {
            // Limit the total amount and frequency of rerouting for online routers
            // to avoid an excessive amount of API calls (causing data traffic and
            // costs) in some special case where the router returns bogus results
            // and the user is not able to manually intervene.
            if (app.rerouteTotalCalls > 50) return;
            var interval = 5000 * Math.pow(2, Math.min(4, app.rerouteConsecutiveErrors));
            if (Date.now() - app.reroutePreviousTime < interval) return;
            return app.reroute();
        }
    }

    function showNavigationPages() {
        // Show NavigationPage and NarrativePage.
        if (!app.pageStack.currentPage ||
            !app.pageStack.currentPage.partOfNavigationStack) {
            app.pageStack.pop(dummy, PageStackAction.Immediate);
            app.pageStack.push("NavigationPage.qml");
            app.pageStack.pushAttached("NarrativePage.qml");
        }
        // If the narrative page is already active, we don't get the page status
        // change signal and must request repopulation to scroll the list.
        var narrativePage = app.pageStack.nextPage(app.pageStack.nextPage(dummy));
        app.pageStack.currentPage === narrativePage && narrativePage.populate();
        root.visible = false;
    }

    function showMenu(page, params) {
        // Show a menu page, either given, last viewed, or the main menu.
        if (page) {
            app.pageStack.pop(dummy, PageStackAction.Immediate);
            app.pageStack.push(page, params || {});
        } else if (app.pageStack.currentPage &&
                   app.pageStack.currentPage.partOfNavigationStack) {
            // Clear NavigationPage and NarrativePage from the stack.
            app.pageStack.pop(dummy, PageStackAction.Immediate);
            app.pageStack.push("MenuPage.qml");
        } else if (app.pageStack.depth < 2) {
            app.pageStack.push("MenuPage.qml");
        }
        root.visible = false;
    }

    function tr(message) {
        // Return translated message.
        // In addition to the message, string formatting arguments can be passed
        // as well as short-hand for message.arg(arg1).arg(arg2)...
        message = qsTranslate("", message);
        for (var i = 1; i < arguments.length; i++)
            message = message.arg(arguments[i]);
        return message;
    }

    function updateKeepAlive() {
        // Update state of keep-alive, i.e. display blanking prevention.
        var prevent = app.conf.get("keep_alive");
        DisplayBlanking.preventBlanking = app.applicationActive &&
            (prevent === "always" || (prevent === "navigating" && app.navigationActive));
    }

    function updateMapMatching() {
        if (!py.ready) return py.onReadyChanged.connect(app.updateMapMatching);
        app.hasMapMatching = py.call_sync("poor.app.has_mapmatching", []);
        app.mapMatchingModeIdle = app.conf.get("map_matching_when_idle");
        // app.mapMatchingModeNavigation is set on Navigation page
    }

    function updateNavigationStatus(status) {
        // Update navigation status with data from Python backend.
        if (app.showNarrative === null)
            app.showNarrative = app.conf.get("show_narrative");
        app.navigationStatus.update(status);
        if (app.navigationStatus.voiceUri && app.conf.get("voice_navigation"))
            sound.source = app.navigationStatus.voiceUri;
        app.navigationStatus.reroute && app.rerouteMaybe();
    }

}
