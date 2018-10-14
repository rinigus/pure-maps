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
import "."
import "platform"

import "js/util.js" as Util

DialogListPL {
    id: dialog

    canAccept: dialog.query.length > 0
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
            textFormat: Text.RichText
        }

        ContextMenuPL {
            id: contextMenu
            ContextMenuItemPL {
                text: app.tr("Remove")
                onClicked: {
                    py.call_sync("poor.app.history.remove_place", [model.place]);
                    dialog.history = py.evaluate("poor.app.history.places");
                    dialog.model.remove(index);
                }
            }
        }

        ListView.onRemove: animateRemoval(listItem);

        onClicked: {
            listItem.focus = true;
            var poi = dialog.poiCompletionDetails[model.place.toLowerCase()];
            if (poi) dialog.selectedPoi = poi;
            dialog.query = model.place;
            dialog.accept();
        }

    }

    headerExtra: Component {
        Column {
            height: gpsItem.height + searchField.height
            width: parent.width

            ListItemPL {
                id: gpsItem
                contentHeight: app.styler.themeItemSizeSmall
                ListItemLabel {
                    anchors.leftMargin: dialog.searchField.textLeftMargin
                    color: app.styler.themeHighlightColor
                    height: app.styler.themeItemSizeSmall
                    text: app.tr("Current position")
                }
                onClicked: {
                    dialog.query = app.tr("Current position");
                    dialog.accept();
                }
            }

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

    placeholderText: app.tr("You can search by address, locality, landmark and many other terms. For best results, include a region, e.g. “address, city” or “city, country”.")

    property bool   autocompletePending: false
    property var    autocompletions: []
    property var    completionDetails: []
    property var    history: []
    property var    poiCompletionDetails: []
    property string prevAutocompleteQuery: "."
    property string query: ""
    property var    searchField: undefined
    property var    selectedPoi: undefined

    onPageStatusActivating: {
        dialog.autocompletePending = false;
        dialog.loadHistory();
        dialog.filterCompletions();
    }

    Timer {
        id: autocompleteTimer
        interval: 1000
        repeat: true
        running: dialog.active && app.conf.autoCompleteGeo
        triggeredOnStart: true
        onTriggered: dialog.fetchCompletions();
    }

    function fetchCompletions() {
        // Fetch completions for a partial search query.
        if (!app.conf.autoCompleteGeo || dialog.autocompletePending) return;
        var query = dialog.searchField.text.trim();
        if (query === dialog.prevAutocompleteQuery) return;
        dialog.autocompletePending = true;
        dialog.prevAutocompleteQuery = query;
        var x = map.position.coordinate.longitude || 0;
        var y = map.position.coordinate.latitude || 0;
        py.call("poor.app.router.geocoder.autocomplete", [query, x, y], function(results) {
            if (!dialog) return;
            dialog.autocompletePending = false;
            if (!dialog.active) return;
            results = results || [];
            dialog.autocompletions = [];
            for (var i = 0; i < results.length; i++) {
                dialog.autocompletions.push(results[i].label);
                dialog.completionDetails[results[i].label.toLowerCase()] = results[i];
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
        var found = Util.findMatches(dialog.searchField.text.trim(),
                                     dialog.history,
                                     dialog.autocompletions,
                                     dialog.model.count);

        // Find POIs matching the completions
        var searchKeys = ["title", "poiType", "address", "postcode", "text", "phone", "link"];
        var s = Util.findMatchesInObjects(query, map.pois, searchKeys);
        var jointResults = [];
        // Limit to max 10 POIs if there are many completions
        if (found.length > 20 && s.length > 10)
            s = s.slice(0, 9);
        // save poi completions details
        dialog.poiCompletionDetails = [];
        s.map(function (p) {
            var txt = p.title || s.address || app.tr("Unnamed point");
            dialog.poiCompletionDetails[txt.toLowerCase()] = p;
            jointResults.push({"text": txt, "markup": txt});
        });

        // Merge all completions
        found = jointResults.concat(found);
        Util.injectMatches(dialog.model, found, "place", "text");
        dialog.placeholderEnabled = found.length === 0;
    }

    function loadHistory() {
        // Load search history and preallocate list items.
        dialog.history = py.evaluate("poor.app.history.places");
        while (dialog.model.count < 100)
            dialog.model.append({"place": "",
                                    "text": "",
                                    "visible": false});

    }

}
