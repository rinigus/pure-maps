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

import "../qml/js/util.js" as Util

DialogListPL {
    id: dialog

    currentIndex: -1

    delegate: ListItemPL {
        id: listItem
        contentHeight: visible ? app.styler.themeItemSizeSmall : 0
        menu: contextMenu
        visible: model.visible

        ListItemLabel {
            anchors.leftMargin: dialog.searchField.textLeftMargin
            color: listItem.highlighted ? app.styler.themeHighlightColor : app.styler.themePrimaryColor
            height: app.styler.themeItemSizeSmall
            text: model.text
        }

        ContextMenuPL {
            id: contextMenu
            ContextMenuItemPL {
                text: app.tr("Remove")
                onClicked: {
                    py.call_sync("poor.app.history.remove_place_name", [model.name]);
                    dialog.history = py.evaluate("poor.app.history.place_names");
                    dialog.model.remove(index);
                }
            }
        }

        ListView.onRemove: animateRemoval(listItem);

        onClicked: {
            dialog.query = model.name;
            dialog.accept();
        }

    }

    headerExtra: Component {
        SearchFieldPL {
            id: searchField
            placeholderText: app.tr("Search")
            width: parent.width
            onSearch: dialog.accept();
            onTextChanged: {
                dialog.query = searchField.text;
                dialog.filterHistory();
            }
            Component.onCompleted: dialog.searchField = searchField;
        }
    }

    model: ListModel {}
    placeholderText: app.tr("You can search for venues by name.")

    property var    history: []
    property string query: ""
    property var searchField: undefined

    onPageStatusActivating: {
        dialog.loadHistory();
        dialog.filterHistory();
    }

    function filterHistory() {
        // Filter search history for current search field text.
        var query = dialog.searchField.text;
        var found = Util.findMatches(query, dialog.history, [], dialog.model.count);
        Util.injectMatches(dialog.model, found, "name", "text");
        placeholderEnabled = found.length === 0;
    }

    function loadHistory() {
        // Load search history and preallocate list items.
        dialog.history = py.evaluate("poor.app.history.place_names");
        while (dialog.model.count < 100)
            dialog.model.append({"name": "",
                                    "text": "",
                                    "visible": false});

    }

}
