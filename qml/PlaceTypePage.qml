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

DialogListPL {
    id: dialog

    canAccept: dialog.query.length > 0
    currentIndex: -1

    property bool   autocompletePending: false
    property var    autocompletions: []
    property var    history: []
    property string prevAutocompleteQuery: "."
    property string query: ""

    delegate: ListItemPL {
        id: listItem
        contentHeight: visible ? app.styler.themeItemSizeSmall : 0

        menu: ContextMenuPL {
            id: contextMenu
            ContextMenuItemPL {
                text: app.tr("Remove")
                onClicked: {
                    py.call_sync("poor.app.history.remove_place_type", [model.type]);
                    dialog.history = py.evaluate("poor.app.history.place_types");
                    dialog.model.remove(index);
                }
            }
        }

        visible: model.visible

        ListItemLabel {
            anchors.leftMargin: dialog.searchField.textLeftMargin
            color: listItem.highlighted ? app.styler.themeHighlightColor : app.styler.themePrimaryColor
            height: app.styler.themeItemSizeSmall
            text: model.text
            textFormat: Text.RichText
        }

        ListView.onRemove: animateRemoval(listItem);

        onClicked: {
            listItem.focus = true;
            dialog.query = model.type;
            dialog.accept();
        }

    }

    headerExtra: Component {
        Column {
            width: dialog.width

            SearchFieldPL {
                id: searchField
                placeholderText: app.tr("Search")
                width: parent.width
                property string prevText: ""
                onSearch: dialog.accept();
                onTextChanged: {
                    var newText = searchField.text.trim();
                    if (newText === searchField.prevText) return;
                    dialog.query = newText;
                    searchField.prevText = newText;
                    dialog.filterCompletions();
                }
            }

            Component.onCompleted: dialog.searchField = searchField;

        }
    }

    model: ListModel {}

    placeholderText: app.tr("You can search for venues by type or name.")

    property var searchField: undefined

    Timer {
        id: autocompleteTimer
        interval: 1000
        repeat: true
        running: dialog.active
        triggeredOnStart: true
        onTriggered: dialog.fetchCompletions();
    }

    onPageStatusActivating: {
        dialog.autocompletePending = false;
        dialog.loadHistory();
        dialog.filterCompletions();
    }

    function fetchCompletions() {
        // Fetch completions for a partial search query.
        if (dialog.autocompletePending) return;
        var query = dialog.searchField.text.trim();
        if (query === dialog.prevAutocompleteQuery) return;
        dialog.autocompletePending = true;
        dialog.prevAutocompleteQuery = query;
        var x = map.position.coordinate.longitude || 0;
        var y = map.position.coordinate.latitude || 0;
        py.call("poor.app.guide.autocomplete_type", [query], function(results) {
            dialog.autocompletePending = false;
            if (!dialog.active) return;
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
        var found = Util.findMatches(dialog.searchField.text.trim(),
                                     ac ? [] : dialog.history,
                                          ac ? dialog.autocompletions : [],
                                               dialog.model.count);

        Util.injectMatches(dialog.model, found, "type", "text");
        dialog.placeholderEnabled = found.length === 0;
    }

    function loadHistory() {
        // Load search history and preallocate list items.
        dialog.history = py.evaluate("poor.app.history.place_types");
        while (dialog.model.count < 100)
            dialog.model.append({"type": "",
                                  "text": "",
                                  "visible": false});

    }

}
