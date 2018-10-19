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
import "../qml"
import "../qml/platform"

PageEmptyPL {
    id: page

    property bool loading: true

    BusyModal {
        id: busy
        running: page.loading
    }

    onPageStatusActivating: busy.text = app.tr("Searching");
    onPageStatusActive: page.findRoute();

    function findRoute() {
        // Load routing results from the Python backend.
        var routePage = app.pages.previousPage();
        var args = [routePage.from, routePage.to];
        py.call("poor.app.router.route", args, function(route) {
            if (route && route.error && route.message) {
                busy.error = route.message;
                page.loading = false;
            } else if (route && route.x && route.x.length > 0) {
                app.setModeExplore();
                app.hideMenu();
                map.hidePoi();
                map.addRoute(route);
                map.fitViewToRoute();
                map.addManeuvers(route.maneuvers);
            } else {
                busy.error = app.tr("No results");
                page.loading = false;
            }
        });
    }

}
