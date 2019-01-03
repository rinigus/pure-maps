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
import "."
import "platform"

import "js/util.js" as Util

PagePL {
    id: page
    title: app.tr("Search")
    pageMenu: PageMenuPL {
        PageMenuItemPL {
            text: app.tr("Using %1").arg(name)
            property string name: py.evaluate("poor.app.geocoder.name")
            onClicked: {
                var dialog = app.push("GeocoderPage.qml");
                dialog.accepted.connect(function() {
                    name = py.evaluate("poor.app.geocoder.name");
                });
            }
        }
    }

    property string browsingQuery

    GeocodeItem {
        id: geo
        active: true
        fillModel: false
        selectionPlaceholderText: ""

        onSelectionChanged: {
            if (!selection || !selection.coordinate) return;
            var poi = Util.shallowCopy(selection);
            if (selection.selection_type === "search result") {
                py.call_sync("poor.app.history.add_place", [geo.query]);
                var new_poi = app.pois.add(poi, geo.stateId);
                if (new_poi) {
                    poi = new_poi;
                    geo.poiBlacklisted.push(poi.poiId);
                } else
                    poi.title = app.tr("%1 [duplicate]", poi.title);
            }
            app.stateId = geo.stateId;
            browsingQuery = geo.query;
            app.hideMenu(app.tr("Search: %1").arg(geo.query));
            app.pois.show(poi, true);
            map.autoCenter = false;
            map.setCenter(poi.coordinate.longitude, poi.coordinate.latitude);
        }
    }

    onPageStatusActive: {
        geo.fillModel = true;
        if (!browsingQuery || browsingQuery!==geo.query) geo.activate();
    }
}
