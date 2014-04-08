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
                text: place
            }
            onClicked: {
                var resultPage = app.pageStack.nextPage()
                app.pageStack.navigateForward();
                resultPage.populate(place);
            }
        }
        header: Column {
            width: parent.width
            PageHeader { title: "Find Place" }
            ValueButton {
                label: "Using"
                height: Theme.itemSizeSmall
                value: py.evaluate("poor.app.geocoder.name")
                width: parent.width
                onClicked: app.pageStack.push("GeocoderPage.qml");
            }
            SearchField {
                id: searchField
                placeholderText: "Address, landmark, etc."
                width: parent.width
                EnterKey.enabled: searchField.text.length > 0
                EnterKey.onClicked: {
                    var resultPage = app.pageStack.nextPage()
                    app.pageStack.navigateForward();
                    resultPage.populate(searchField.text);
                }
                onTextChanged: listModel.update();
            }
            Component.onCompleted: listView.searchField = searchField;
        }
        model: ListModel {
            id: listModel
            property var history: py.evaluate("poor.app.history.places")
            Component.onCompleted: listModel.update();
            function update() {
                listModel.clear();
                var query = listView.searchField.text.toLowerCase();
                for (var i = 0; i < listModel.history.length; i++) {
                    var historyItem = listModel.history[i].toLowerCase()
                    if (query != "" && historyItem.indexOf(query) == 0)
                        listModel.append({"place": listModel.history[i]})
                    if (listModel.count >= 100) break;
                }
                for (var i = 0; i < listModel.history.length; i++) {
                    var historyItem = listModel.history[i].toLowerCase()
                    if (query == "" || historyItem.indexOf(query) > 0)
                        listModel.append({"place": listModel.history[i]})
                    if (listModel.count >= 100) break;
                }
            }
        }
        property var searchField
        VerticalScrollDecorator {}
    }
}
