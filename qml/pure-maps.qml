/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2014 Osmo Salomaa, 2018 Rinigus
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
    initialPage: InitPage { }

    property var  conf: Config {}
    property bool hasMapMatching: false
    property bool initialized: false
    property var  map: null
    property string mapMatchingMode: "none"
    property int    mode: modes.explore
    property bool   narrativePageSeen: false
    property bool   navigationPageSeen: false
    property var    navigationStatus: NavigationStatus {}
    property bool   navigationStarted: false
    property var    notification: null
    property bool   poiActive: false
    property bool   portrait: screenHeight >= screenWidth
    property var    remorse: null
    property int    rerouteConsecutiveErrors: 0
    property real   reroutePreviousTime: -1
    property int    rerouteTotalCalls: 0
    property bool   rerouting: false
    property var    rootPage: null
    property bool   running: applicationActive || cover.active
    property int    screenHeight: Screen.height
    property int    screenWidth: Screen.width
    property var    styler: Styler {}
    property var    _stackMain: Stack {}
    property var    _stackNavigation: Stack {}

    // Default vertical margin for various multiline list items
    // such that it would be consistent with single-line list items
    // and the associated constant Theme.itemSizeSmall.
    property real listItemVerticalMargin: (Theme.itemSizeSmall - 1.125 * Theme.fontSizeMedium) / 2

    PositionSource { id: gps }
    Python { id: py }

    Audio {
        id: sound
        autoLoad: true
        autoPlay: true
        loops: 1
    }

    Modes {
        id: modes
    }

    Connections {
        target: app.conf
        onMapMatchingWhenNavigatingChanged: app.updateMapMatching()
        onMapMatchingWhenFollowingChanged: app.updateMapMatching()
        onMapMatchingWhenIdleChanged: app.updateMapMatching()
   }

    Component.onDestruction: {
        if (!py.ready || !app.map) return;
        app.conf.set("auto_center", app.map.autoCenter);
        app.conf.set("auto_rotate", app.map.autoRotate);
        app.conf.set("center", [app.map.center.longitude, app.map.center.latitude]);
        app.conf.set("zoom", app.map.zoomLevel);
        py.call_sync("poor.app.quit", []);
    }

    Keys.onPressed: {
        // Allow zooming with plus and minus keys on the emulator.
        (event.key === Qt.Key_Plus)  && map.setZoomLevel(map.zoomLevel+1);
        (event.key === Qt.Key_Minus) && map.setZoomLevel(map.zoomLevel-1);
    }

    onApplicationActiveChanged: {
        if (!initialized) return;
        app.updateKeepAlive();
    }

    onDeviceOrientationChanged: updateOrientation()

    onHasMapMatchingChanged: updateMapMatching()

    onModeChanged: {
        if (!initialized) return;
        if (app.mode === modes.explore) {

        } else if (app.mode === modes.followMe) {

        } else if (app.mode === modes.navigate) {
            app.navigationPageSeen = true;
            app.navigationStarted = true;
            app.rerouteConsecutiveErrors = 0;
            app.reroutePreviousTime = -1;
            app.rerouteTotalCalls = 0;
            app.resetMenu();
        }
        app.updateKeepAlive();
        app.updateMapMatching();
    }

    function getIcon(name, no_variant) {
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
        if (!no_variant && app.styler.iconVariant) return "%1-%2@%3.png".arg(name).arg(app.styler.iconVariant).arg(ratio);
        return "%1@%2.png".arg(name).arg(ratio);
    }

    function hideMenu() {
        app._stackMain.keep = true;
        app._stackMain.setCurrent(app.pageStack.currentPage);
        app.showMap();
    }

    function hideNavigationPages() {
        app._stackNavigation.keep = true;
        app._stackNavigation.setCurrent(app.pageStack.currentPage);
        app.showMap();
    }

    function initialize() {
        app.hasMapMatching = py.call_sync("poor.app.has_mapmatching", []);
        updateOrientation();
        updateKeepAlive();
        initialized = true;
    }

    function playMaybe(message) {
        // Play message via TTS engine if applicable.
        if (!app.conf.voiceNavigation) return;
        var fun = "poor.app.narrative.get_message_voice_uri";
        py.call(fun, [message], function(uri) {
            if (uri) sound.source = uri;
        });
    }

    function push(pagefile, options) {
        return app.pageStack.push(pagefile, options ? options : {});
    }

    function pushAttached(pagefile, options) {
        return app.pageStack.pushAttached(pagefile, options ? options : {});
    }

    function pushMain(pagefile, options) {
        // replace the current main with the new stack
        app._stackMain.clear();
        return app._stackMain.push(pagefile, options);
    }

    function pushAttachedMain(pagefile, options) {
        // attach pages to the current main
        return app._stackMain.pushAttached(pagefile, options);
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
        if (!app.conf.reroute) return;
        if (app.mode !== modes.navigate) return;
        if (!gps.position.horizontalAccuracyValid) return;
        if (gps.position.horizontalAccuracy > 100) return;
        if (!py.evaluate("poor.app.router.can_reroute")) return;
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

    function resetMenu() {
        app._stackMain.keep = false;
    }

    function setModeExplore() {
        app.mode = modes.explore;
    }

    function setModeFollowMe() {
        app.mode = modes.followMe;
    }

    function setModeNavigate() {
        app.mode = modes.navigate;
    }

    function showMap() {
        // Clear the page stack and hide the menu.
        app.pageStack.completeAnimation();
        app.pageStack.pop(app.rootPage);
    }

    function showMenu(page, options) {
        if (page) {
            app._stackMain.clear();
            app.pushMain(page, options);
        } else if (app._stackMain.keep) {
            // restore former menu stack
            app._stackMain.keep = false;
            app._stackMain.restore();
        } else {
            // start a new call
            app._stackMain.clear();
            app.push("MenuPage.qml");
        }
    }

    function showNavigationPages() {
        if (app._stackNavigation.keep) {
            // restore former navigation pages stack
            app._stackNavigation.keep = false;
            app._stackNavigation.restore();
        } else {
            app._stackNavigation.clear();
            app._stackNavigation.push("NavigationPage.qml")
            app._stackNavigation.pushAttached("NarrativePage.qml");
        }
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
            (prevent === "always" || (prevent === "navigating" && (app.mode === modes.navigate || app.mode === modes.followMe)));
    }

    function updateMapMatching() {
        if (!hasMapMatching) mapMatchingMode = "none";
        else if (app.mode === modes.navigate)
            mapMatchingMode = (app.conf.mapMatchingWhenNavigating && map && map.route && map.route.mode ? map.route.mode : "none");
        else if (app.mode === modes.followMe) mapMatchingMode = app.conf.mapMatchingWhenFollowing;
        else mapMatchingMode = app.conf.mapMatchingWhenIdle;
    }

    function updateNavigationStatus(status) {
        // Update navigation status with data from Python backend.
        app.navigationStatus.update(status);
        if (app.navigationStatus.voiceUri && app.conf.voiceNavigation)
            sound.source = app.navigationStatus.voiceUri;
        app.navigationStatus.reroute && app.rerouteMaybe();
    }

    function updateOrientation() {
        if (!(app.deviceOrientation & app.allowedOrientations)) return;
        switch (app.deviceOrientation) {
        case Orientation.Portrait:
            app.screenWidth = Screen.width;
            app.screenHeight = Screen.height;
            break;
        case Orientation.PortraitInverted:
            app.screenWidth = Screen.width;
            app.screenHeight = Screen.height;
            break;
        case Orientation.Landscape:
            app.screenWidth = Screen.height;
            app.screenHeight = Screen.width;
            break;
        case Orientation.LandscapeInverted:
            app.screenWidth = Screen.height;
            app.screenHeight = Screen.width;
            break;
        }
    }

}
