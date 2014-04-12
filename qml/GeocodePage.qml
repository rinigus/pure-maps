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
    allowedOrientations: Orientation.All
    property string geocoderName: ""
    property var history: []
    property string query: ""
    SilicaListView {
        id: listView
        anchors.fill: parent
        // Prevent list items from stealing focus.
        currentIndex: -1
        delegate: ListItem {
            id: listItem
            contentHeight: Theme.itemSizeSmall
            ListItemLabel {
                anchors.leftMargin: listView.searchField.textLeftMargin
                color: listItem.highlighted ?
                    Theme.highlightColor : Theme.primaryColor
                height: Theme.itemSizeSmall
                text: model.place
            }
            onClicked: {
                page.query = model.place;
                app.pageStack.navigateForward();
            }
        }
        header: Column {
            width: parent.width
            PageHeader { title: "Find Place" }
            ValueButton {
                label: "Using"
                height: Theme.itemSizeSmall
                value: page.geocoderName
                width: parent.width
                onClicked: app.pageStack.push("GeocoderPage.qml");
            }
            SearchField {
                id: searchField
                placeholderText: "Address, landmark, etc."
                width: parent.width
                EnterKey.enabled: searchField.text.length > 0
                EnterKey.onClicked: app.pageStack.navigateForward();
                onTextChanged: {
                    page.query = searchField.text;
                    listModel.update();
                }
            }
            Component.onCompleted: listView.searchField = searchField;
        }
        model: ListModel {
            id: listModel
            function update() {
                listModel.clear();
                var query = listView.searchField.text.toLowerCase();
                var nstart = 0;
                for (var i = 0; i < page.history.length; i++) {
                    var historyItem = page.history[i].toLowerCase()
                    if (query != "" && historyItem.indexOf(query) == 0) {
                        listModel.insert(nstart++, {"place": page.history[i]});
                        if (listModel.count >= 100) break;
                    } else if (query == "" || historyItem.indexOf(query) > 0) {
                        listModel.append({"place": page.history[i]});
                        if (listModel.count >= 100) break;
                    }
                }
            }
        }
        property var searchField
        VerticalScrollDecorator {}
    }
    onStatusChanged: {
        if (page.status == PageStatus.Activating) {
            page.geocoderName = py.evaluate("poor.app.geocoder.name");
            page.history = py.evaluate("poor.app.history.places");
            listView.model.update();
        }
    }
}
