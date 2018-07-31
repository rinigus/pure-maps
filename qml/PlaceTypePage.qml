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

Dialog {
    id: dialog
    allowedOrientations: app.defaultAllowedOrientations
    canAccept: dialog.query.length > 0

    property bool   autocompletePending: false
    property var    autocompletions: []
    property var    history: []
    property string prevAutocompleteQuery: "."
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
                textFormat: Text.RichText
            }

            ContextMenu {
                id: contextMenu
                MenuItem {
                    text: app.tr("Remove")
                    onClicked: {
                        py.call_sync("poor.app.history.remove_place_type", [model.type]);
                        dialog.history = py.evaluate("poor.app.history.place_types");
                        listView.model.remove(index);
                    }
                }
            }

            ListView.onRemove: animateRemoval(listItem);

            onClicked: {
                listItem.focus = true;
                dialog.query = model.type;
                dialog.accept();
            }

        }

        header: Column {
            height: dialogHeader.height + searchField.height
            width: parent.width

            DialogHeader {
                id: dialogHeader
            }

            SearchField {
                id: searchField
                placeholderText: app.tr("Search")
                width: parent.width
                property string prevText: ""
                EnterKey.enabled: text.length > 0
                EnterKey.onClicked: dialog.accept();
                onTextChanged: {
                    var newText = searchField.text.trim();
                    if (newText === searchField.prevText) return;
                    dialog.query = newText;
                    searchField.prevText = newText;
                    dialog.filterCompletions();
                }
            }

            Component.onCompleted: listView.searchField = searchField;

        }

        model: ListModel {}

        property var searchField: undefined

        Timer {
            id: autocompleteTimer
            interval: 1000
            repeat: true
            running: dialog.status === PageStatus.Active
            triggeredOnStart: true
            onTriggered: dialog.fetchCompletions();
        }

        ViewPlaceholder {
            id: viewPlaceholder
            enabled: false
            hintText: app.tr("You can search for venues by type or name.")
        }

        VerticalScrollDecorator {}

    }

    onStatusChanged: {
        if (dialog.status === PageStatus.Activating) {
            dialog.autocompletePending = false;
            dialog.loadHistory();
            dialog.filterCompletions();
        }
    }

    function fetchCompletions() {
        // Fetch completions for a partial search query.
        if (dialog.autocompletePending) return;
        var query = listView.searchField.text.trim();
        if (query === dialog.prevAutocompleteQuery) return;
        dialog.autocompletePending = true;
        dialog.prevAutocompleteQuery = query;
        var x = map.position.coordinate.longitude || 0;
        var y = map.position.coordinate.latitude || 0;
        py.call("poor.app.guide.autocomplete_type", [query], function(results) {
            dialog.autocompletePending = false;
            if (dialog.status !== PageStatus.Active) return;
            results = results || [];
            dialog.autocompletions = [];
            for (var i = 0; i < results.length; i++) {
                dialog.autocompletions.push(results[i].label);
                // Use auto-completion results to fix history item letter case.
                for (var j = 0; j < dialog.history.length; j++)
                    if (results[i].label.toLowerCase() === dialog.history[j].toLowerCase())
                        dialog.history[j] = results[i].label;
            }
            dialog.filterCompletions();
        });
    }

    function filterCompletions() {
        // Filter completions for the current search query.
        var ac = py.evaluate("poor.app.guide.autocomplete_type_supported");
        var found = Util.findMatches(listView.searchField.text.trim(),
                                     ac ? [] : dialog.history,
                                     ac ? dialog.autocompletions : [],
                                     listView.model.count);

        Util.injectMatches(listView.model, found, "type", "text");
        viewPlaceholder.enabled = found.length === 0;
    }

    function loadHistory() {
        // Load search history and preallocate list items.
        dialog.history = py.evaluate("poor.app.history.place_types");
        while (listView.model.count < 100)
            listView.model.append({"type": "",
                                   "text": "",
                                   "visible": false});

    }

}
