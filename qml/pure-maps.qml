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
import "."
import "platform"

ApplicationWindowPL {
    id: app
    initialPage: InitPage { }
    menuPageUrl: Qt.resolvedUrl("MenuPage.qml")
    title: app.tr("Pure Maps")

    keepAlive: app.conf.keepAlive === "always"
               || (app.conf.keepAlive === "navigating" && (app.mode === modes.navigate || app.mode === modes.followMe))

    property var    conf: Config {}
    property bool   errorPageOpen: false
    property bool   hasMapMatching: false
    property bool   initialized: false
    property bool   infoActive: infoPanel && infoPanel.infoText
    property var    infoPanel: null
    // infoPanelOpen is true if either info or poi (or both) are shown.
    property bool   infoPanelOpen: infoActive || poiActive
    // Default vertical margin for various multiline list items
    // such that it would be consistent with single-line list items
    // and the associated constant Theme.itemSizeSmall.
    property real   listItemVerticalMargin: (styler.themeItemSizeSmall - 1.125 * styler.themeFontSizeMedium) / 2
    property var    map: null
    property string mapMatchingMode: "none"
    property bool   modalDialog: modalDialogBasemap
    property bool   modalDialogBasemap: false
    property int    mode: modes.explore
    property bool   narrativePageSeen: false
    property bool   navigationPageSeen: false
    property var    navigationStatus: NavigationStatus {}
    property bool   navigationStarted: false
    property var    notification: null
    property var    pois: null
    property bool   poiActive: false
    property bool   portrait: screenHeight >= screenWidth
    property var    remorse: null
    property int    rerouteConsecutiveErrors: 0
    property real   reroutePreviousTime: -1
    property int    rerouteTotalCalls: 0
    property bool   rerouting: false
    property var    rootPage: null
    // used to track current search and other operations with kept states (temp pois, for example)
    property string stateId
    property var    _stackMain: Stack {}
    property var    _stackNavigation: Stack {}

    ClipboardPL { id: clipboard }
    Modes { id: modes }
    PositionSource { id: gps }
    Python { id: py }
    Styler { id: styler }
    TruncationModes { id: truncModes }

    Audio {
        id: sound
        autoLoad: true
        loops: 1
    }

    Timer {
        id: voicePromptRetry
        interval: 500
        running: false
        repeat: false

        property string message
        property int tries

        onMessageChanged: tries = 0
        onTriggered: {
            tries += 1;
            app.playMaybe(message);
        }
    }

    Connections {
        target: app.conf
        onMapMatchingWhenNavigatingChanged: app.updateMapMatching()
        onMapMatchingWhenFollowingChanged: app.updateMapMatching()
        onMapMatchingWhenIdleChanged: app.updateMapMatching()
    }

    Component.onDestruction: {
        keepAlive = false;
        gps.active = false;
        app.running = false;
        if (!py.ready || !app.map) return;
        app.conf.set("auto_center", app.map.autoCenter);
        app.conf.set("auto_rotate", app.map.autoRotate);
        app.conf.set("center", [app.map.center.longitude, app.map.center.latitude]);
        app.conf.set("zoom", app.map.zoomLevel);
        py.call_sync("poor.app.quit", []);
    }

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
        app.updateMapMatching();
    }

    onNarrativePageSeenChanged: {
        if (!narrativePageSeen)
            app._stackNavigation.keep = false; // drops navigation pagestack if a new route is obtained
    }

    function clear(confirm) {
        if (confirm) {
            app.remorse.execute(app.tr("Clearing map"),
                                function() {
                                    app.clear();
                                });
            return;
        }

        // Remove all markers from the map.
        pois.clear();
        map.clearRoute();
    }

    function createObject(page, options, parent) {
        var pc = Qt.createComponent(page);
        if (pc.status === Component.Error) {
            console.log('Error while creating component');
            console.log(pc.errorString());
            return null;
        }
        return pc.createObject(parent ? parent : app, options ? options : {})
    }

    function getIcon(name, no_variant) {
        if (!no_variant && styler.iconVariant)
            return Qt.resolvedUrl("%1-%2.svg".arg(name).arg(styler.iconVariant));
        return Qt.resolvedUrl("%1.svg".arg(name));
    }

    function getIconScaled(name, no_variant) {
        // Return path to icon suitable for user's screen,
        // finding the closest match to pixelRatio.
        var ratios = [1.00, 1.25, 1.50, 1.75, 2.00];
        var minIndex = -1, minDiff = 1000, diff;
        for (var i = 0; i < ratios.length; i++) {
            diff = Math.abs(styler.themePixelRatio - ratios[i]);
            minIndex = diff < minDiff ? i : minIndex;
            minDiff = Math.min(minDiff, diff);
        }
        var ratio = ratios[minIndex].toFixed(2);
        if (!no_variant && styler.iconVariant) return "%1-%2@%3.png".arg(name).arg(styler.iconVariant).arg(ratio);
        return "%1@%2.png".arg(name).arg(ratio);
    }

    function hideMenu(menutext) {
        app._stackMain.keep = true;
        app._stackMain.setCurrent(app.pages.currentPage());
        app.infoPanel.infoText = menutext ? menutext : "";
        app.showMap();
    }

    function hideNavigationPages() {
        app._stackNavigation.keep = true;
        app._stackNavigation.setCurrent(app.pages.currentPage());
        app.showMap();
    }

    function initialize() {
        initPages();
        app.hasMapMatching = py.call_sync("poor.app.has_mapmatching", []);
        initialized = true;
    }

    function openMapErrorMessage(error) {
        if (errorPageOpen) return;
        app.push(Qt.resolvedUrl("MapErrorPage.qml"), { "lastError": error } )
    }

    function playMaybe(message) {
        // Play message via TTS engine if applicable.
        if (!app.conf.voiceNavigation) return;
        var fun = "poor.app.narrative.get_message_voice_uri";
        py.call(fun, [message], function(uri) {
            if (uri) {
                sound.source = uri;
                sound.play();
            } else {
                if (voicePromptRetry.message !== message)
                    voicePromptRetry.message = message;
                if (voicePromptRetry.tries < 10)
                    voicePromptRetry.start();
            }
        });
    }

    function push(pagefile, options, clearAll) {
        if (app.isConvergent && clearAll) {
            app.resetMenu();
            app.clearPages();
        }
        return app.pages.push(pagefile, options);
    }

    function pushAttached(pagefile, options) {
        return app.pages.pushAttached(pagefile, options);
    }

    function pushMain(pagefile, options) {
        // replace the current main with the new stack
        app._stackMain.clear();
        app.resetMenu();
        if (app.isConvergent) {
            app.clearPages();
        }
        return app._stackMain.push(pagefile, options);
    }

    function pushAttachedMain(pagefile, options) {
        // attach pages to the current main
        return app._stackMain.pushAttached(pagefile, options);
    }

    function reroute() {
        // Find a new route from the current position to the existing destination.
        if (app.rerouting) return;
        var notifyId = "app reroute";
        app.notification.hold(app.tr("Rerouting"), notifyId);
        app.playMaybe("std:rerouting");
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
                app.notification.flash(app.tr("Rerouting failed: %1").arg(route.message), notifyId);
                app.playMaybe("std:rerouting failed");
                app.rerouteConsecutiveErrors++;
            } else if (route && route.x && route.x.length > 0) {
                app.notification.flash(app.tr("New route found"), notifyId);
                app.playMaybe("std:new route found");
                map.addRoute(route, true);
                map.addManeuvers(route.maneuvers);
                app.rerouteConsecutiveErrors = 0;
            } else {
                app.notification.flash(app.tr("Rerouting failed"), notifyId);
                app.playMaybe("std:rerouting failed");
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
        app.stateId = "";
        app.infoPanel.infoText = "";
    }

    function setModeExplore() {
        app.mode = modes.explore;
    }

    function setModeExploreRoute() {
        app.mode = modes.exploreRoute;
    }

    function setModeFollowMe() {
        app.mode = modes.followMe;
    }

    function setModeNavigate() {
        app.mode = modes.navigate;
    }

    function showMap() {
        // Clear the page stack and hide the menu.
        app.pages.completeAnimation();
        if (app.isConvergent && app.infoActive)
            app.pages.showRoot();
        else
            app.pages.pop(app.rootPage);
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
            app.showMainMenu();
        }
    }

    function showNavigationPages() {
        resetMenu();
        if (app._stackNavigation.keep) {
            // restore former navigation pages stack
            app._stackNavigation.keep = false;
            app._stackNavigation.restore();
        } else {
            app._stackNavigation.clear();
            app.narrativePageSeen = false;
            app._stackNavigation.push(Qt.resolvedUrl("NavigationPage.qml"));
            app._stackNavigation.pushAttached(Qt.resolvedUrl("NarrativePage.qml"));
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
        if (app.navigationStatus.voiceUri && app.conf.voiceNavigation) {
            sound.source = app.navigationStatus.voiceUri;
            sound.play();
        }
        app.navigationStatus.reroute && app.rerouteMaybe();
    }

}
