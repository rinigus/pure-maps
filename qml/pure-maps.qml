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
import QtMultimedia 5.6
import QtPositioning 5.4
import org.puremaps 1.0
import "."
import "platform"

ApplicationWindowPL {
    id: app
    initialPage: InitPage { }
    menuPageUrl: Qt.resolvedUrl("MenuPage.qml")
    title: app.tr("Pure Maps")

    keepAlive: app.conf.keepAlive === "always"
               || (app.conf.keepAlive === "navigating" &&
                   (app.mode === modes.navigate || app.mode === modes.followMe || app.mode === modes.navigatePost))

    keepAliveBackground: app.conf.keepAliveBackground === "always"
                        || (app.conf.keepAliveBackground === "navigating" &&
                            (app.mode === modes.navigate || app.mode === modes.followMe || app.mode === modes.navigatePost))

    property var    conf: Config {}
    property bool   errorPageOpen: false
    property bool   fontKeyMissing: false
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
    property string mapMatchingMode: {
        if (app.mode === modes.navigate || app.mode === modes.followMe || app.mode === modes.navigatePost)
            return (app.conf.mapMatchingWhenNavigating && map && app.transportMode) ?
                        app.transportMode : "none";
        return app.conf.mapMatchingWhenIdle;
    }
    property bool   modalDialog: modalDialogBasemap
    property bool   modalDialogBasemap: false
    property int    mode: {
        if (navigator) {
            if (navigator.running && navigator.destReached) return modes.navigatePost;
            if (navigator.running) return modes.navigate;
            if (navigator.followMe) return modes.followMe;
            if (navigator.hasRoute) return modes.exploreRoute;
        }
        return modes.explore;
    }
    property bool   narrativePageSeen: false
    property var    navigator: null
    property var    notification: null
    property var    pois: null
    property bool   poiActive: false
    property bool   portrait: screenHeight >= screenWidth
    property var    remorse: null
    property var    rootPage: null
    // used to track current search and other operations with kept states (temp pois, for example)
    property string stateId
    property string transportMode: {
        if (app.mode === modes.followMe) return app.conf.followMeTransportMode;
        if (app.mode === modes.exploreRoute || app.mode === modes.navigate || app.mode === modes.navigatePost)
            return navigator.transportMode;
        return "";
    }
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
        audioRole: Audio.NotificationRole
        autoLoad: true
        loops: 1
    }

    Connections {
        target: app.navigator
        onRouteChanged: app.narrativePageSeen = false
    }

    Connections {
        target: Commander

        onSearch: {
            app.pushMain(Qt.resolvedUrl("GeocodePage.qml"),
                         {"query": searchString});
            app.activate();
        }

        onShowPoi: {
            var radius = 50; // meters default radius
            var p = pois.add({ "x": longitude, "y": latitude, "title": title });
            if (!p) return;
            pois.show(p);
            py.call("poor.app.geocoder.reverse",
                    [longitude, latitude, radius, 1],
                    function(result) {
                        if (!result || !result.length) return;
                        var r = result[0];
                        var rpoi = pois.convertFromPython(r);
                        rpoi.poiId = p.poiId;
                        rpoi.coordinate = QtPositioning.coordinate(rpoi.y, rpoi.x);
                        if (title) rpoi.title = title;
                        pois.update(rpoi);
                    });
            map.autoCenter = false;
            map.setCenter(longitude, latitude);
            app.activate();
        }
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

    onModeChanged: {
        if (!initialized) return;
        if (app.mode === modes.explore) {

        } else if (app.mode === modes.followMe) {
            app.resetMenu();
        } else if (app.mode === modes.navigate) {
            app.resetMenu();
        } else if (app.mode === modes.navigatePost) {
            app.resetMenu();
        }
    }

    onNarrativePageSeenChanged: {
        if (!narrativePageSeen)
            app._stackNavigation.keep = false; // drops navigation pagestack if a new route is obtained
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

    function getPosition() {
        // Return the coordinates of the current position.
        return [gps.coordinate.longitude, gps.coordinate.latitude];
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
        initialized = true;
        // after all objects and pages are initialized
        CmdLineParser.process()
    }

    function openMapErrorMessage(error) {
        if (errorPageOpen) return;
        app.push(Qt.resolvedUrl("MapErrorPage.qml"), { "lastError": error } )
    }

    function play(uri) {
        sound.source = uri;
        sound.play();
    }

    function push(pagefile, options) {
        return app.pages.push(pagefile, options);
    }

    function pushAttached(pagefile, options) {
        return app.pages.pushAttached(pagefile, options);
    }

    function pushMain(pagefile, options) {
        // replace the current main with the new stack
        app._stackMain.clear();
        app.resetMenu();
        return app._stackMain.push(pagefile, options);
    }

    function pushAttachedMain(pagefile, options) {
        // attach pages to the current main
        return app._stackMain.pushAttached(pagefile, options);
    }

    function resetMenu() {
        app._stackMain.keep = false;
        app.stateId = "";
        app.infoPanel.infoText = "";
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
            app._stackNavigation.restore();
        } else {
            app._stackNavigation.clear();
            app.narrativePageSeen = false;
            app._stackNavigation.keep = true;
            app._stackNavigation.push(Qt.resolvedUrl("NavigationPage.qml"));
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

}
