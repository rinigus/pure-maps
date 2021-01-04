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

PageListPL {
    id: page

    delegate: ListItemPL {
        id: listItem
        contentHeight: titleLabel.height + descriptionLabel.height + descriptionLabel.anchors.topMargin

        property bool visited: false

        ListItemLabel {
            id: titleLabel
            color: (listItem.highlighted || listItem.visited) ?
                       styler.themeHighlightColor : styler.themePrimaryColor;
            height: implicitHeight + app.listItemVerticalMargin
            text: model.title
            verticalAlignment: Text.AlignBottom
        }

        ListItemLabel {
            id: descriptionLabel
            anchors.top: titleLabel.bottom
            anchors.topMargin: styler.themePaddingSmall
            color: listItem.highlighted ? styler.themeSecondaryHighlightColor : styler.themeSecondaryColor
            font.pixelSize: styler.themeFontSizeExtraSmall
            height: implicitHeight + app.listItemVerticalMargin
            lineHeight: 1.15
            text: model.description + "\n" + model.distance
            verticalAlignment: Text.AlignTop
            wrapMode: Text.WordWrap
        }

        onClicked: {
            app.hideMenu(querySummary);
            var p = pois.convertFromPython(model);
            app.stateId = stateId;
            var available_poi = app.pois.has(p);
            if (available_poi &&
                    !available_poi.bookmarked)
                // assuming that if there is a temporary
                // poi its the same as the selected one
                p = available_poi;
            else {
                var new_poi = pois.add(p, stateId);
                if (new_poi) p = new_poi;
                else p.title = app.tr("%1 [duplicate]", p.title);
            }
            pois.show(p, true);
            map.autoCenter = false;
            map.setCenter(model.x, model.y);
            listItem.visited = true;
        }

    }

    model: ListModel {}

    pageMenu: PageMenuPL {
        visible: page.model.count > 1
        PageMenuItemPL {
            iconName: styler.iconMaps
            text: app.tr("Map")
            onClicked: {
                var pois = [];
                for (var i = 0; i < page.model.count; i++) {
                    var item = page.model.get(i);
                    pois.push(app.pois.convertFromPython(item));
                }
                app.hideMenu(querySummary);
                map.fitViewToPois(pois);
            }
        }
    }

    placeholderEnabled: populated && model.count < 1
    placeholderText: app.tr("No results")
    title: app.tr("Nearby Venues")

    property bool   loading: true
    property bool   populated: false
    property int    searchCounter: 0
    property string stateId: "Nearby search: " + querySummary + searchCounter
    property string querySummary

    headerExtra: Component {
        Item {
            height: busy.running ? page.height : 0
            width: busy.running ? page.width : 0
            BusyModal {
                id: busy
                running: page.loading
                text: app.tr("Searching")
            }
        }
    }

    onPageStatusActivating: {
        if (page.populated) return;
        page.model.clear();
        page.loading = true;
    }

    onPageStatusActive: {
        if (page.populated) return;
        var nearbyPage = app.pages.previousPage();
        page.populate(nearbyPage.queryType, nearbyPage.queryName,
                      nearbyPage.near, nearbyPage.radius, nearbyPage.params);
        querySummary = app.tr("Nearby venues: %1 %2",
                              nearbyPage.queryType, nearbyPage.queryName)
    }

    onPageStatusInactive: {
    }

    function populate(queryType, queryName, near, radius, params) {
        // Load nearby results from the Python backend.
        page.model.clear();
        searchCounter += 1;
        py.call("poor.app.guide.nearby", [queryType, queryName,
                                          near, radius, params], function(results) {
            if (results && results.error && results.message) {
                page.placeholderText = results.message;
            } else if (results.length > 0) {
                page.title = app.tr("%1 Results", results.length);
                Util.appendAll(page.model, results);
            }
            page.loading = false;
            page.populated = true;
            // put all results on a map
            var pois = [];
            for (var i = 0; i < results.length; i++) {
                pois.push(app.pois.convertFromPython(results[i]));
            }
            app.stateId = stateId;
            app.pois.addList(pois, stateId);
        });
    }

}
