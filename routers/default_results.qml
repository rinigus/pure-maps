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

PagePL {
    id: page
    title: app.tr("Route")

    property bool loading: true

    Item {
        height: busy.visible ? page.height*3.0/4.0 : 0
        width: page.width
        BusyModal {
            id: busy
            running: page.loading
        }
    }

    onPageStatusActivating: {
        if (loading) busy.text = app.tr("Searching");
    }
    onPageStatusActive: {
        if (loading) page.findRoute();
    }

    function findRoute() {
        // Load routing results from the Python backend.
        page.loading = true;
        busy.visible = true;
        var routePage = app.pages.previousPage();
        routePage.saveDestination();
        var routePoints = routePage.getLocations();
        var args = [routePoints];
        py.call("poor.app.router.route", args, function(route) {
            if (route && route.error && route.message) {
                busy.error = route.message;
                page.loading = false;
            } else if (route && route.x && route.x.length > 0) {
                routePage.saveLocations();
                // apply new route
                app.hideMenu(app.tr("Route to %1", routePage.toText));
                pois.hide();
                navigator.setRoute(route);
                map.fitViewToRoute();
                if (app.isConvergent) {
                    page.loading = false;
                    busy.visible = false;
                }
            } else {
                busy.error = app.tr("No results");
                page.loading = false;
                if (routePage.autoRoute) {
                    routePage.notify(app.tr("No results"));
                    app.pages.popAttached();
                }
            }
        });
    }

}
