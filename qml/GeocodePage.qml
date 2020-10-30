/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2014 Osmo Salomaa, 2018-2019 Rinigus, 2019 Purism SPC
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
            iconName: styler.iconPreferences
            text: app.tr("Change provider (%1)").arg(name)
            property string name: py.evaluate("poor.app.geocoder.name")
            onClicked: {
                var dialog = app.push(Qt.resolvedUrl("GeocoderPage.qml"));
                dialog.accepted.connect(function() {
                    name = py.evaluate("poor.app.geocoder.name");
                });
            }
        }

        PageMenuItemPL {
            enabled: geo.searchResults.length
            iconName: styler.iconMaps
            text: app.tr("Map")
            onClicked: {
                var pois = geo.searchResults;
                app.hideMenu(app.tr("Search: %1").arg(geo.query));
                map.fitViewToPois(pois);
            }
        }
    }

    property string browsingQuery
    property alias  query: geo.query

    GeocodeItem {
        id: geo
        active: true
        fillModel: false
        selectionPlaceholderText: ""

        onSelectionChanged: {
            if (!selection || !selection.coordinate) return;
            var poi = Util.shallowCopy(selection);
            if (selection.selectionType === selectionTypes.searchResult) {
                py.call_sync("poor.app.history.add_place", [geo.query]);
                var available_poi = app.pois.has(poi);
                if (available_poi &&
                        !available_poi.bookmarked)
                    // assuming that if there is a temporary
                    // poi its the same as the selected one
                    poi = available_poi;
                else {
                    // either add if its missing or show as a duplicate
                    var new_poi = app.pois.add(poi, geo.stateId);
                    if (new_poi) {
                        poi = new_poi;
                    } else
                        poi.title = app.tr("%1 [duplicate]", poi.title);
                }
            }
            app.stateId = geo.stateId;
            browsingQuery = geo.query;
            app.hideMenu(app.tr("Search: %1").arg(geo.query));
            app.pois.show(poi, true);
            map.autoCenter = false;
            map.setCenter(poi.coordinate.longitude, poi.coordinate.latitude);
        }

        onSearchResultsChanged: {
            app.stateId = geo.stateId;
            app.pois.addList(geo.searchResults, stateId);
        }
    }

    onPageStatusActive: {
        geo.fillModel = true;
        if (!browsingQuery || browsingQuery!==geo.query) geo.activate();
    }
}
