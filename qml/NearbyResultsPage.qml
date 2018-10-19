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

    property bool   loading: true
    property bool   populated: false

    delegate: ListItemPL {
        id: listItem
        contentHeight: titleLabel.height + descriptionLabel.height

        property bool visited: false

        ListItemLabel {
            id: titleLabel
            color: (listItem.highlighted || listItem.visited) ?
                       app.styler.themeHighlightColor : app.styler.themePrimaryColor;
            height: implicitHeight + app.listItemVerticalMargin
            text: model.title
            verticalAlignment: Text.AlignBottom
        }

        ListItemLabel {
            id: descriptionLabel
            anchors.top: titleLabel.bottom
            anchors.topMargin: app.styler.themePaddingSmall
            color: app.styler.themeSecondaryColor
            font.pixelSize: app.styler.themeFontSizeExtraSmall
            height: implicitHeight + app.listItemVerticalMargin
            lineHeight: 1.15
            text: model.description + "\n" + model.distance
            verticalAlignment: Text.AlignTop
            wrapMode: Text.WordWrap
        }

        onClicked: {
            app.hideMenu();
            var p = {
                "address": model.address || "",
                "link": model.link || "",
                "phone": model.phone || "",
                "poiType": model.poi_type || "",
                "postcode": model.postcode || "",
                "provider": model.provider || "",
                "text": model.text || "",
                "title": model.title,
                "type": "venue",
                "x": model.x,
                "y": model.y,
            };
            if (map.addPoi(p)) p = map.pois[map.pois.length-1];
            else p.title = app.tr("%1 [duplicate]", p.title);
            map.showPoi(p, true);
            map.autoCenter = false;
            map.setCenter(model.x, model.y);
            listItem.visited = true;
        }

    }

    model: ListModel {}

    pageMenu: PageMenuPL {
        visible: page.model.count > 1
        PageMenuItemPL {
            text: app.tr("Show all")
            onClicked: {
                var pois = [];
                for (var i = 0; i < page.model.count; i++) {
                    var item = page.model.get(i);
                    pois.push({
                                  "address": item.address || "",
                                  "link": item.link || "",
                                  "phone": item.phone || "",
                                  "poiType": item.poi_type || "",
                                  "postcode": item.postcode || "",
                                  "provider": item.provider || "",
                                  "text": item.text || "",
                                  "title": item.title,
                                  "type": "venue",
                                  "x": item.x,
                                  "y": item.y,
                              });
                }
                app.hideMenu();
                map.clearPois();
                map.addPois(pois);
                map.fitViewToPois(pois);
            }
        }
    }

    BusyModal {
        id: busy
        running: page.loading
    }

    onPageStatusActivating: {
        if (page.populated) return;
        page.model.clear();
        page.loading = true;
        page.title = "";
        busy.text = app.tr("Searching");
    }

    onPageStatusActive: {
        //listView.visible = true;
        if (page.populated) return;
        var nearbyPage = app.pages.previousPage();
        page.populate(nearbyPage.query, nearbyPage.near, nearbyPage.radius, nearbyPage.params);
    }

    onPageStatusInactive: {
        //listView.visible = false;
    }

    function populate(query, near, radius, params) {
        // Load nearby results from the Python backend.
        page.model.clear();
        py.call("poor.app.guide.nearby", [query, near, radius, params], function(results) {
            if (results && results.error && results.message) {
                page.title = "";
                busy.error = results.message;
            } else if (results.length > 0) {
                page.title = app.tr("%1 Results", results.length);
                Util.appendAll(page.model, results);
            } else {
                page.title = "";
                busy.error = app.tr("No results");
            }
            page.loading = false;
            page.populated = true;
        });
    }

}
