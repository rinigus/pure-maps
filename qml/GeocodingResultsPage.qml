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
import "."

Page {
    id: page
    allowedOrientations: app.defaultAllowedOrientations
    property bool loading: true
    property bool populated: false
    property string title: ""
    SilicaListView {
        id: listView
        anchors.fill: parent
        delegate: ListItem {
            id: listItem
            contentHeight: titleLabel.height + descriptionLabel.height + distanceLabel.height
            property bool visited: false
            ListItemLabel {
                id: titleLabel
                color: (listItem.highlighted || listItem.visited)?
                    Theme.highlightColor : Theme.primaryColor;
                height: implicitHeight + Theme.paddingMedium
                text: model.title
                verticalAlignment: Text.AlignBottom
            }
            ListItemLabel {
                id: descriptionLabel
                anchors.top: titleLabel.bottom
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                height: implicitHeight
                text: model.description
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WordWrap
            }
            ListItemLabel {
                id: distanceLabel
                anchors.top: descriptionLabel.bottom
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                height: implicitHeight + Theme.paddingMedium
                text: model.distance
                verticalAlignment: Text.AlignTop
            }
            onClicked: {
                app.hideMenu();
                map.addPois([{"x": model.x,
                              "y": model.y,
                              "title": model.title,
                              "text": model.text || model.title,
                              "link": model.link || ""}]);

                map.autoCenter = false;
                map.setCenter(model.x, model.y);
                listItem.visited = true;
            }
        }
        header: PageHeader { title: page.title }
        model: ListModel {}
        PullDownMenu {
            visible: listView.model.count > 1
            MenuItem {
                text: "Show all"
                onClicked: {
                    var pois = [];
                    for (var i = 0; i < listView.model.count; i++) {
                        var item = listView.model.get(i);
                        pois.push({
                            "x": item.x,
                            "y": item.y,
                            "title": item.title,
                            "text": item.text || item.title,
                            "link": item.link || ""
                        });
                    }
                    app.hideMenu();
                    map.clearPois();
                    map.addPois(pois);
                    map.fitViewToPois(pois);
                }
            }
        }
        VerticalScrollDecorator {}
    }
    BusyModal {
        id: busy
        running: page.loading
    }
    onStatusChanged: {
        if (page.status == PageStatus.Activating) {
            if (page.populated) return;
            listView.model.clear();
            page.loading = true;
            page.title = "";
            busy.text = "Searching";
        } else if (page.status == PageStatus.Active) {
            listView.visible = true;
            if (page.populated) return;
            var geocodePage = app.pageStack.previousPage();
            page.populate(geocodePage.query);
        } else if (page.status == PageStatus.Inactive) {
            listView.visible = false;
        }
    }
    function populate(query) {
        // Load geocoding results from the Python backend.
        py.call_sync("poor.app.history.add_place", [query]);
        listView.model.clear();
        var x = map.position.coordinate.longitude || 0;
        var y = map.position.coordinate.latitude || 0;
        py.call("poor.app.geocoder.geocode", [query, null, x, y], function(results) {
            if (results && results.error && results.message) {
                page.title = "";
                busy.error = results.message;
            } else if (results.length > 0) {
                page.title = results.length == 1 ?
                    "1 Result" : results.length + " Results";
                for (var i = 0; i < results.length; i++)
                    listView.model.append(results[i]);
            } else {
                page.title = "";
                busy.error = "No results";
            }
            page.loading = false;
            page.populated = true;
        });
    }
}
