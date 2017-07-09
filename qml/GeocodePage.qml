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

import "js/util.js" as Util

Page {
    id: page
    allowedOrientations: app.defaultAllowedOrientations
    canNavigateForward: query.length > 0

    property var    history: []
    property string query: ""

    SilicaListView {
        id: listView
        anchors.fill: parent
        // Prevent list items from stealing focus.
        currentIndex: -1

        delegate: ListItem {
            id: listItem
            contentHeight: visible ? Theme.itemSizeSmall : 0
            menu: contextMenu
            visible: model.visible

            ListItemLabel {
                anchors.leftMargin: listView.searchField.textLeftMargin
                color: listItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                height: Theme.itemSizeSmall
                text: model.text
            }

            ContextMenu {
                id: contextMenu
                MenuItem {
                    text: app.tr("Remove")
                    onClicked: {
                        py.call_sync("poor.app.history.remove_place", [model.place]);
                        page.history = py.evaluate("poor.app.history.places");
                        listView.model.remove(index);
                    }
                }
            }

            ListView.onRemove: animateRemoval(listItem);

            onClicked: {
                page.query = model.place;
                app.pageStack.navigateForward();
            }

        }

        header: Column {
            height: header.height + usingButton.height + searchField.height
            width: parent.width

            PageHeader {
                id: header
                title: app.tr("Search")
            }

            ValueButton {
                id: usingButton
                height: Theme.itemSizeSmall
                label: app.tr("Using")
                value: py.evaluate("poor.app.geocoder.name")
                width: parent.width
                onClicked: {
                    var dialog = app.pageStack.push("GeocoderPage.qml");
                    dialog.accepted.connect(function() {
                        usingButton.value = py.evaluate("poor.app.geocoder.name");
                    });
                }
            }

            SearchField {
                id: searchField
                placeholderText: app.tr("Search")
                width: parent.width
                EnterKey.enabled: text.length > 0
                EnterKey.onClicked: app.pageStack.navigateForward();
                onTextChanged: {
                    page.query = searchField.text;
                    page.filterHistory();
                }
            }

            Component.onCompleted: listView.searchField = searchField;

        }

        model: ListModel {}

        property var searchField: undefined

        ViewPlaceholder {
            id: viewPlaceholder
            enabled: false
            hintText: app.tr("You can search by address, locality, landmark and many other terms. For best results, include a region, e.g. “address, city” or “city, country”.")
        }

        VerticalScrollDecorator {}

    }

    onStatusChanged: {
        if (page.status === PageStatus.Activating) {
            page.loadHistory();
            page.filterHistory();
        } else if (page.status === PageStatus.Active) {
            var resultPage = app.pageStack.nextPage();
            resultPage.populated = false;
        }
    }

    function filterHistory() {
        // Filter search history for current search field text.
        var query = listView.searchField.text;
        var found = Util.findMatches(query, page.history, listView.model.count);
        Util.injectMatches(listView.model, found, "place", "text");
        viewPlaceholder.enabled = found.length === 0;
    }

    function loadHistory() {
        // Load search history and preallocate list items.
        page.history = py.evaluate("poor.app.history.places");
        while (listView.model.count < 100)
            listView.model.append({"place": "",
                                   "text": "",
                                   "visible": false});

    }

}
