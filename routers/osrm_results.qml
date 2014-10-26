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

Page {
    id: page
    allowedOrientations: Orientation.Portrait
    property bool loading: true
    Label {
        id: busyLabel
        anchors.bottom: busyIndicator.top
        color: Theme.highlightColor
        font.pixelSize: Theme.fontSizeLarge
        height: Theme.itemSizeLarge
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        visible: page.loading || text != "Searching"
        width: parent.width
    }
    BusyIndicator {
        id: busyIndicator
        anchors.centerIn: parent
        running: page.loading
        size: BusyIndicatorSize.Large
        visible: page.loading
    }
    onStatusChanged: {
        if (page.status == PageStatus.Activating) {
            busyLabel.text = "Searching";
        } else if (page.status == PageStatus.Active) {
            page.findRoute();
        }
    }
    function findRoute() {
        // Load routing results from the Python backend.
        var routePage = app.pageStack.previousPage();
        var args = [routePage.from, routePage.to];
        py.call("poor.app.router.route", args, function(route) {
            if (route && route.error && route.message) {
                busyLabel.text = route.message;
                page.loading = false;
            } else if (route && route.x && route.x.length > 0) {
                app.hideMenu();
                map.addRoute({"x": route.x,
                              "y": route.y,
                              "mode": "car",
                              "attribution": "Routing courtesy of OSRM."});

                map.autoCenter = false;
                map.fitViewToRoute();
                map.addManeuvers(route.maneuvers);
                app.pageStack.pop();
            } else {
                busyLabel.text = "No results";
                page.loading = false;
            }
        });
    }
}
