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

Dialog {
    id: dialog
    allowedOrientations: Orientation.All
    canAccept: dialog.query.length > 0
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
            menu: contextMenu
            ListView.onRemove: animateRemoval(listItem)
            ListItemLabel {
                anchors.leftMargin: listView.searchField.textLeftMargin
                color: listItem.highlighted ?
                    Theme.highlightColor : Theme.primaryColor
                height: Theme.itemSizeSmall
                text: model.type
            }
            Component {
                id: contextMenu
                ContextMenu {
                    MenuItem {
                        text: "Remove"
                        onClicked: listItem.remove();
                    }
                }
            }
            onClicked: {
                dialog.query = model.type;
                dialog.accept();
            }
            function remove() {
                py.call_sync("poor.app.history.remove_place_type", [model.type]);
                listView.model.remove(index);
            }
        }
        header: Column {
            width: parent.width
            DialogHeader {}
            SearchField {
                id: searchField
                placeholderText: "Type of place"
                width: parent.width
                EnterKey.enabled: searchField.text.length > 0
                EnterKey.onClicked: dialog.accept();
                onTextChanged: {
                    dialog.query = searchField.text;
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
                for (var i = 0; i < dialog.history.length; i++) {
                    var historyItem = dialog.history[i].toLowerCase()
                    if (query != "" && historyItem.indexOf(query) == 0) {
                        listModel.insert(nstart++, {"type": dialog.history[i]});
                        if (listModel.count >= 100) break;
                    } else if (query == "" || historyItem.indexOf(query) > 0) {
                        listModel.append({"type": dialog.history[i]});
                        if (listModel.count >= 100) break;
                    }
                }
            }
        }
        property var searchField
        VerticalScrollDecorator {}
    }
    onStatusChanged: {
        if (dialog.status != PageStatus.Activating) return;
        dialog.history = py.evaluate("poor.app.history.place_types");
        listView.model.update();
    }
}
