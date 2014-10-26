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
 * Technically, this also allows us to use a split screen if need arises.
 * To allow swiping back from the menu to the map, we need the first page
 * in the stack to be a dummy that upon activation hides the page stack.
 * Hiding the page stack is done using ApplicationWindow.bottomMargin.
 * To make transitions smooth and animated, we can make the dummy look like
 * the actual map, thus providing the smooth built-in page stack transition,
 * followed by a sudden bottomMargin change, only noticeable by
 * the reappearance of map overlays not duplicated in the dummy.
 *
 * As a downside, our map cannot benefit from automatic orientation handling
 * in the Page container as the map is not in a Page. This means that we need
 * to write our own orientation handling code once Qt bug #40799 is resolved
 * and map gestures correctly change orientation along with the map.
 *
 * http://bugreports.qt-project.org/browse/QTBUG-40799
 * http://lists.sailfishos.org/pipermail/devel/2014-October/005064.html
 */

ApplicationWindow {
    id: app
    allowedOrientations: Orientation.All
    cover: Cover {}
    initialPage: DummyPage { id: dummy }
    property bool running: applicationActive || cover.status == Cover.Active
    Map {
        id: map
        anchors.left: app.contentItem.left
        anchors.right: app.contentItem.right
        anchors.top: app.contentItem.bottom
        height: app.bottomMargin
    }
    PositionSource { id: gps }
    Python { id: py }
    Component.onCompleted: {
        py.setHandler("render-tile", map.renderTile);
        py.setHandler("show-tile", map.showTile);
    }
    onApplicationActiveChanged: {
        if (!app.applicationActive && py.ready) {
            app.setConf(["auto_center", map.autoCenter]);
            app.setConf(["center", [map.center.longitude, map.center.latitude]]);
            app.setConf(["show_routing_narrative", map.showNarrative]);
            app.setConf(["zoom", Math.floor(map.zoomLevel)]);
            py.call_sync("poor.conf.write", []);
            py.call_sync("poor.app.history.write", []);
        }
        app.updateKeepAlive();
    }
    function clearMenu() {
        // Clear pages from the menu and hide the menu.
        app.pageStack.pop(dummy, PageStackAction.Immediate);
        app.hideMenu();
    }
    function hideMenu() {
        // Immediately hide the menu, keeping pages intact.
        app.bottomMargin = Math.max(Screen.width, Screen.height);
    }
    function showMenu(page, params) {
        // Show a menu page, either given, last viewed, or menu.
        dummy.updateTiles();
        if (page) {
            app.pageStack.pop(dummy, PageStackAction.Immediate);
            app.pageStack.push(page, params || {});
        } else if (app.pageStack.depth < 2) {
            app.pageStack.push("MenuPage.qml");
        }
        app.bottomMargin = 0;
    }
    function setConf(args) {
        // Set value of configuration variable.
        py.call_sync("poor.conf.set", args);
    }
    function updateKeepAlive() {
        // Update state of display blanking prevention, i.e. keep-alive.
        var prevent = py.evaluate("poor.conf.keep_alive");
        DisplayBlanking.preventBlanking = app.applicationActive && (
            prevent == "always" || (map.hasRoute && prevent == "navigating"));
    }
}
