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

    property var  conf: Config {}
    property bool inMenu: !root.visible
    property var  map: null
    property var  menuButton: null
    property var  narrativePageSeen: false
    property bool navigationActive: false
    property var  navigationBlock: null
    property bool navigationCanStart: false
    property var  navigationDirection: null
    property bool navigationReroutable: false
    property var  navigationStatus: null
    property var  navigationTarget: null
    property var  northArrow: null
    property var  routerInfo: null
    property bool running: applicationActive || cover.active
    property var  scaleBar: null
    property int  screenHeight: Screen.height
    property int  screenWidth: Screen.width

    Root { id: root }
    PositionSource { id: gps }
    Python { id: py }

    Component.onCompleted: {
        py.setHandler("queue-update", map.queueUpdate);
        py.setHandler("render-tile", map.renderTile);
        py.setHandler("show-tile", map.showTile);
    }

    Component.onDestruction: {
        if (!py.ready) return;
        app.conf.set("auto_center", map.autoCenter);
        app.conf.set("auto_rotate", map.autoRotate);
        app.conf.set("center", [map.center.longitude, map.center.latitude]);
        app.conf.set("zoom", Math.floor(map.zoomLevel));
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

    function navigationReroute() {
        app.routerInfo.setInfo(app.tr("Finding new route"))
        // Prevent new reroute calculations before this route is ready
        app.navigationReroutable = false;
        // Start recalculations
        var args = [map.getPosition(), app.navigationTarget];
        py.call("poor.app.router.route", args, function(route) {
            if (route && route.error && route.message) {
                app.routerInfo.setError(route.message);
            } else if (route && route.x && route.x.length > 0) {
                app.hideMenu();
                app.routerInfo.clear();
                map.addRoute({
                    "x": route.x,
                    "y": route.y,
                    "mode": "car",
                    "attribution": route.attribution
                });
                map.hidePoiBubbles();
                map.fitViewToRoute();
                map.addManeuvers(route.maneuvers);
                //app.pageStack.navigateBack(PageStackAction.Immediate);

                // start navigation again
                app.narrativePageSeen = true;
                map.beginNavigating();
                app.clearMenu();
                app.navigationReroutable = true;
            } else {
                app.routerInfo.setError(app.tr("New route not found"));
            }
        });
    }

    function setNavigationStatus(status) {
        // Set values of labels in the navigation status area.
        if (status && map.showNarrative) {
            app.navigationBlock.destDist  = status.dest_dist || "";
            app.navigationBlock.destTime  = status.dest_time || "";
            app.navigationBlock.icon      = status.icon      || "";
            app.navigationBlock.manDist   = status.man_dist  || "";
            app.navigationBlock.manTime   = status.man_time  || "";
            app.navigationBlock.narrative = status.narrative || "";
            app.navigationDirection       = status.direction || null;

            if (status.reroute && app.navigationReroutable && app.navigationActive)  {
                app.navigationReroute();
            }
        } else {
            app.navigationBlock.destDist  = "";
            app.navigationBlock.destTime  = "";
            app.navigationBlock.icon      = "";
            app.navigationBlock.manDist   = "";
            app.navigationBlock.manTime   = "";
            app.navigationBlock.narrative = "";
            app.navigationDirection       = null;
        }
        app.navigationStatus = status;
    }

    function showMenu(page, params) {
        // Show a menu page, either given, last viewed, or the main menu.
        dummy.updateTiles();
        if (page) {
            app.pageStack.pop(dummy, PageStackAction.Immediate);
            app.pageStack.push(page, params || {});
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
            (prevent === "always" || (prevent === "navigating" && map.hasRoute));
    }

}
