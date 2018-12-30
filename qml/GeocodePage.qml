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
                enabled: model.type == ""
                text: app.tr("Remove")
                onClicked: {
                    if (model.type != "") return;
                    py.call_sync("poor.app.history.remove_place", [model.place]);
                    page.history = py.evaluate("poor.app.history.places");
                    page.model.remove(index);
                }
            }
        }

        visible: model.visible

        property bool header: model.type === "header"

        SectionHeaderPL {
            visible: listItem.header
            text: model.text
        }

        ListItemLabel {
            anchors.leftMargin: page.searchField.textLeftMargin
            color: listItem.highlighted ? app.styler.themeHighlightColor : app.styler.themePrimaryColor
            height: app.styler.themeItemSizeSmall
            text: model.text
            textFormat: Text.RichText
            visible: !listItem.header
        }

        ListView.onRemove: animateRemoval(listItem);

        onClicked: {
            if (listItem.header) return;
            listItem.focus = true;
            if (model.type === "autocomplete") {
                var details = page.completionDetails[model.place];
                if (details && details.x && details.y) {
                    // Autocompletion result with known coordinates, open directly.
                    py.call_sync("poor.app.history.add_place", [page.prevAutocompleteQuery]);
                    app.hideMenu(app.tr("Search: %1").arg(page.query));
                    var p = pois.convertFromPython(details);
                    app.stateId = stateId;
                    var new_poi = app.pois.add(p, stateId);
                    if (new_poi) {
                        p = new_poi;
                        page.poiBlacklisted.push(p.poiId);
                    } else
                        p.title = app.tr("%1 [duplicate]", p.title);
                    app.pois.show(p, true);
                    map.autoCenter = false;
                    map.setCenter(details.x, details.y);
                }
            } else if (model.type === "poi") {
                var poi = page.poiDetails[model.place];
                if (poi) {
                    app.hideMenu(app.tr("Search: %1").arg(page.query));
                    app.pois.show(poi, true);
                    map.autoCenter = false;
                    map.setCenter(poi.coordinate.longitude, poi.coordinate.latitude);
                }
            } else {
                // No autocompletion, no POI, open results page.
                page.query = model.place;
                app.pages.navigateForward();
            }
        }
    }

    headerExtra: Component {
        SearchFieldPL {
            id: searchField
            focus: true
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
            Component.onCompleted: page.searchField = searchField;
        }
    }

    model: ListModel {}

    pageMenu: PageMenuPL {
        PageMenuItemPL {
            text: app.tr("Using %1").arg(name)
            property string name: py.evaluate("poor.app.geocoder.name")
            onClicked: {
                var dialog = app.push("GeocoderPage.qml");
                dialog.accepted.connect(function() {
                    name = py.evaluate("poor.app.geocoder.name");
                });
            }
        }
    }

    placeholderText: app.tr("You can search by address, locality, landmark and many other terms. For best results, include a region, e.g. “address, city” or “city, country”.")

    property bool   autocompletePending: false
    property var    autocompletions: []
    property var    completionDetails: []
    property var    history: []
    property var    poiBlacklisted: [] // POIs that were created as a part of this search
    property var    poiDetails: []
    property string prevAutocompleteQuery: "."
    property var    searchField: undefined
    property string stateId
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
        page.searchField.forceActiveFocus();
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
            page.completionDetails = [];
            for (var i = 0; i < results.length && i < 10; i++) {
                page.autocompletions.push(results[i].label);
                page.completionDetails[results[i].label] = results[i];
            }
            page.filterCompletions();
        });
    }

    function filterCompletions() {
        // Filter completions for the current search query.
        var found = [];
        var query = page.searchField.text.trim();

        stateId = "Geocoder: " + query;

        // POIs
        if (query) {
            var searchKeys = ["shortlisted", "bookmarked", "title", "poiType", "address", "postcode", "text", "phone", "link"];
            var pois = app.pois.pois.filter(function (p) {
               return (page.poiBlacklisted.indexOf(p.poiId) < 0);
            });
            var s = Util.findMatchesInObjects(query, pois, searchKeys);
            if (s.length > 0) {
                found.push({
                               "markup": app.tr("Points of Interest"),
                               "text": "",
                               "type": "header"
                           });
                page.poiDetails = [];
                s = s.slice(0, 10);
                s.forEach(function (p){
                    var t = (p.title ? p.title : app.tr("Unnamed point")) +
                            (p.bookmarked ? " ☆" : "") + (p.shortlisted ? " ☰" : "");
                    found.push({
                        "markup": t,
                        "text": p.poiId,
                        "type": "poi"
                    });
                    page.poiDetails[p.poiId] = p;
                });
            }
        }

        // Autocompletions
        if (query && page.autocompletions && page.autocompletions.length > 0) {
            found.push({
                           "markup": app.tr("Suggestions"),
                           "text": "",
                           "type": "header"
                       });
            autocompletions.forEach(function (p){
                found.push({
                               "markup": p,
                               "text": p,
                               "type": "autocomplete"
                           });
            });
        }

        // Recent searches
        var f = Util.findMatches(page.searchField.text.trim(),
                                 page.history,
                                 [],
                                 page.model.count - found.length);
        if (f.length > 0) {
            found.push({
                           "markup": app.tr("Recent searches"),
                           "text": "",
                           "type": "header"
                       });
            found = found.concat(f);
        }

        Util.injectMatches(page.model, found, "place", "text", ["type"]);
        page.placeholderEnabled = found.length === 0;
    }

    function loadHistory() {
        // Load search history and preallocate list items.
        page.history = py.evaluate("poor.app.history.places");
        while (page.model.count < 40)
            page.model.append({"place": "",
                                  "text": "",
                                  "visible": false});

    }

}
