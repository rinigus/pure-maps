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

PageListPL {
    id: page
    title: app.tr("Search")

    canNavigateForward: query.length > 0
    currentIndex: -1

    delegate: ListItemPL {
        id: listItem
        contentHeight: visible ? app.styler.themeItemSizeSmall : 0
        menu: ContextMenuPL {
            id: contextMenu
            ContextMenuItemPL {
                text: app.tr("Remove")
                onClicked: {
                    py.call_sync("poor.app.history.remove_place", [model.place]);
                    page.history = py.evaluate("poor.app.history.places");
                    page.model.remove(index);
                }
            }
        }

        visible: model.visible

        ListItemLabel {
            anchors.leftMargin: page.searchField.textLeftMargin
            color: listItem.highlighted ? app.styler.themeHighlightColor : app.styler.themePrimaryColor
            height: app.styler.themeItemSizeSmall
            text: model.text
            textFormat: Text.RichText
        }

        ListView.onRemove: animateRemoval(listItem);

        onClicked: {
            listItem.focus = true;
            var details = page.completionDetails[model.place.toLowerCase()];
            if (details && details.x && details.y) {
                // Autocompletion result with known coordinates, open directly.
                py.call_sync("poor.app.history.add_place", [model.place]);
                app.hideMenu();
                var p = {
                    "address": details.address || "",
                    "link": details.link || "",
                    "phone": details.phone || "",
                    "poiType": details.poi_type || "",
                    "postcode": details.postcode || "",
                    "provider": details.provider || "",
                    "text": details.text || "",
                    "title": details.title || model.place,
                    "type": "geocode",
                    "x": details.x,
                    "y": details.y,
                };
                if (map.addPoi(p)) p = map.pois[map.pois.length-1];
                else p.title = app.tr("%1 [duplicate]", p.title);
                map.showPoi(p, true);
                map.autoCenter = false;
                map.setCenter(details.x, details.y);
            } else {
                // No autocompletion, open results page.
                page.query = model.place;
                app.pages.navigateForward();
            }
        }
    }

    headerExtra: Component {
        Column {
            spacing: app.styler.themePaddingLarge
            width: parent.width

            ValueButtonPL {
                id: usingButton
                height: app.styler.themeItemSizeSmall
                label: app.tr("Using")
                value: py.evaluate("poor.app.geocoder.name")
                width: parent.width
                onClicked: {
                    var dialog = app.push("GeocoderPage.qml");
                    dialog.accepted.connect(function() {
                        usingButton.value = py.evaluate("poor.app.geocoder.name");
                    });
                }
            }

            SearchFieldPL {
                id: searchField
                placeholderText: app.tr("Search")
                width: parent.width
                property string prevText: ""
                onSearch: app.pages.navigateForward();
                onTextChanged: {
                    var newText = searchField.text.trim();
                    if (newText === searchField.prevText) return;
                    page.query = newText;
                    searchField.prevText = newText;
                    page.filterCompletions();
                }
            }

            Component.onCompleted: page.searchField = searchField;
        }
    }

    model: ListModel {}

    placeholderText: app.tr("You can search by address, locality, landmark and many other terms. For best results, include a region, e.g. “address, city” or “city, country”.")

    property bool   autocompletePending: false
    property var    autocompletions: []
    property var    completionDetails: []
    property var    history: []
    property string prevAutocompleteQuery: "."
    property var    searchField: undefined
    property string query: ""

    Timer {
        id: autocompleteTimer
        interval: 1000
        repeat: true
        running: page.active && app.conf.autoCompleteGeo
        triggeredOnStart: true
        onTriggered: page.fetchCompletions();
    }

    onPageStatusActivating: {
        page.autocompletePending = false;
        page.loadHistory();
        page.filterCompletions();
    }

    onPageStatusActive: {
        var resultPage = app.pages.nextPage();
        if (resultPage) resultPage.populated = false;
    }

    function fetchCompletions() {
        // Fetch completions for a partial search query.
        if (!app.conf.autoCompleteGeo || page.autocompletePending) return;
        var query = page.searchField.text.trim();
        if (query === page.prevAutocompleteQuery) return;
        page.autocompletePending = true;
        page.prevAutocompleteQuery = query;
        var x = map.position.coordinate.longitude || 0;
        var y = map.position.coordinate.latitude || 0;
        py.call("poor.app.geocoder.autocomplete", [query, x, y], function(results) {
            page.autocompletePending = false;
            if (!page.active) return;
            results = results || [];
            page.autocompletions = [];
            for (var i = 0; i < results.length; i++) {
                page.autocompletions.push(results[i].label);
                page.completionDetails[results[i].label.toLowerCase()] = results[i];
                // Use auto-completion results to fix history item letter case.
                for (var j = 0; j < page.history.length; j++)
                    if (results[i].label.toLowerCase() === page.history[j].toLowerCase())
                        page.history[j] = results[i].label;
            }
            page.filterCompletions();
        });
    }

    function filterCompletions() {
        // Filter completions for the current search query.
        var found = Util.findMatches(page.searchField.text.trim(),
                                     page.history,
                                     page.autocompletions,
                                     page.model.count);

        Util.injectMatches(page.model, found, "place", "text");
        page.placeholderEnabled = found.length === 0;
    }

    function loadHistory() {
        // Load search history and preallocate list items.
        page.history = py.evaluate("poor.app.history.places");
        while (page.model.count < 100)
            page.model.append({"place": "",
                                  "text": "",
                                  "visible": false});

    }

}
