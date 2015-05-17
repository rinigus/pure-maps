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
 * To make transitions smooth and animated, we can make the dummy look like
 * the actual map, thus providing the smooth built-in page stack transition.
 */

ApplicationWindow {
    id: app
    allowedOrientations: ~Orientation.PortraitInverse
    cover: Cover {}
    initialPage: DummyPage { id: dummy }

    property var  conf: Config {}
    property var  map: null
    property var  menuButton: null
    property bool running: applicationActive || cover.active
    property var  scaleBar: null
    property var  statusArea: null

    Item {
        id: rootContainer
        anchors.fill: parent
        height: Screen.height
        width: Screen.width
        z: 1000000
        Item {
            id: mapContainer
            anchors.centerIn: parent
            Map { id: map }
            MenuButton { id: menuButton }
            ScaleBar { id: scaleBar }
            StatusArea { id: statusArea }
            Component.onCompleted: {
                mapContainer.updateOrientation();
                app.onDeviceOrientationChanged.connect(mapContainer.updateOrientation);
                app.map = map;
                app.menuButton = menuButton;
                app.scaleBar = scaleBar;
                app.statusArea = statusArea;
            }
            function updateOrientation() {
                if (app.deviceOrientation == Orientation.Portrait) {
                    mapContainer.width = Screen.width;
                    mapContainer.height = Screen.height;
                    mapContainer.rotation = 0;
                } else if (app.deviceOrientation == Orientation.Landscape) {
                    mapContainer.width = Screen.height;
                    mapContainer.height = Screen.width;
                    mapContainer.rotation = 90;
                } else if (app.deviceOrientation == Orientation.LandscapeInverted) {
                    mapContainer.width = Screen.height;
                    mapContainer.height = Screen.width;
                    mapContainer.rotation = 270;
                }
                map.changed = true;
                map.hasRoute && map.route.redraw();
            }
        }
    }

    PositionSource { id: gps }
    Python { id: py }

    Component.onCompleted: {
        py.setHandler("render-tile", map.renderTile);
        py.setHandler("show-tile", map.showTile);
    }

    Component.onDestruction: {
        if (!py.ready) return;
        app.conf.set("auto_center", map.autoCenter);
        app.conf.set("center", [map.center.longitude, map.center.latitude]);
        app.conf.set("show_routing_narrative", map.showNarrative);
        app.conf.set("zoom", Math.floor(map.zoomLevel));
        py.call_sync("poor.app.quit", []);
    }

    Keys.onPressed: {
        // Allow zooming with plus and minus keys on the emulator.
        (event.key == Qt.Key_Plus)  && map.setZoomLevel(map.zoomLevel+1);
        (event.key == Qt.Key_Minus) && map.setZoomLevel(map.zoomLevel-1);
    }

    onApplicationActiveChanged: {
        if (!py.ready)
            return py.onReadyChanged.connect(app.updateKeepAlive);
        app.updateKeepAlive();
    }

    function clearMenu() {
        // Clear pages from the menu and hide the menu.
        app.pageStack.pop(dummy, PageStackAction.Immediate);
        app.hideMenu();
    }

    function hideMenu() {
        // Immediately hide the menu, keeping pages intact.
        rootContainer.visible = true;
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
        rootContainer.visible = false;
    }

    function updateKeepAlive() {
        // Update state of display blanking prevention, i.e. keep-alive.
        var prevent = app.conf.get("keep_alive");
        DisplayBlanking.preventBlanking = app.applicationActive && (
            prevent == "always" || (map.hasRoute && prevent == "navigating"));
    }
}
