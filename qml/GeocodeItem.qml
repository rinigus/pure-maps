/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2017 Osmo Salomaa, 2018 Rinigus
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

///////////////////////////////////////////////////
// Item allowing to search for locations and POIs

Item {
    id: geo

    anchors.left: parent.left
    anchors.right: parent.right
    height: active ? column.height : selectionItem.height

    property bool   active: false
    property bool   autocompletePending: false
    property var    autocompletions: []
    property bool   fillModel: true
    property bool   highlightSelected: true
    property var    history: []
    property var    poiBlacklisted: [] // POIs that were created as a part of this search
    property string prevAutocompleteQuery: "."
    property var    resultDetails: []
    property bool   searchDone: false
    property string searchError: ""
    property bool   searchPending: false
    property string searchPlaceholderText: app.tr("Search")
    property var    searchResults: []
    property var    selection: null // current selection is kept here
    property string selectionPlaceholderText: app.tr("No selection")
    property string stateId
    property string query: ""

    // internal properties
    readonly property var _listDataKeys:
        ["description", "detailId", "distance", "markup", "text", "title", "type", "visited"]
    property int          _searchIndex: 0

    ListItemPL {
        id: selectionItem
        contentHeight: visible? itemSel.height + app.styler.themePaddingLarge : 0
        visible: !active

        ListItemLabel {
            id: itemSel
            anchors.verticalCenter: parent.verticalCenter
            color: app.styler.themePrimaryColor
            text: selection ? selection.title : selectionPlaceholderText
        }

        onClicked: active = true;
    }

    Column {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right
        visible: active

        SearchFieldPL {
            id: searchField
            focus: true
            placeholderText: searchPlaceholderText
            width: parent.width
            property string prevText: ""
            onSearch: fetchResults();
            onTextChanged: {
                var newText = searchField.text.trim();
                if (!newText && selection) selection = null;
                if (newText === searchField.prevText) return;
                selection = null;
                geo.searchPending = false;
                geo.searchDone = false;
                geo.query = newText;
                searchField.prevText = newText;
                geo.update();
            }
        }

        Spacer {
            height: app.styler.themePaddingLarge
        }

        Repeater {
            id: results

            delegate: ListItemPL {
                id: listItem
                contentHeight: {
                    if (!visible) return 0;
                    return itemColumn.height
                }
                menu: ContextMenuPL {
                    id: contextMenu
                    ContextMenuItemPL {
                        enabled: model.type === "recent search"
                        text: app.tr("Remove")
                        onClicked: {
                            if (model.type !== "recent search") return;
                            py.call_sync("poor.app.history.remove_place", [model.text]);
                            geo.history = py.evaluate("poor.app.history.places");
                            model.visible = false;
                        }
                    }
                }
                visible: model.visible

                property bool header: model.type === "header"
                property bool visited: model.visited

                Column {
                    id: itemColumn
                    anchors.left: parent.left
                    anchors.right: parent.right
                    spacing: app.styler.themePaddingSmall

                    Spacer {
                        id: extraSpacer
                        height: Math.max(0, app.styler.themePaddingLarge / 2 - app.styler.themePaddingSmall)
                    }

                    SectionHeaderPL {
                        height: visible ? implicitHeight : 0
                        text: model.markup
                        visible: listItem.header
                        wrapMode: Text.WordWrap
                    }

                    ListItemLabel {
                        //anchors.leftMargin: searchField.textLeftMargin
                        color: (listItem.highlighted || listItem.visited) ?
                                   app.styler.themeHighlightColor : app.styler.themePrimaryColor
                        height: visible ? implicitHeight : 0
                        text: model.markup ? model.markup : model.title
                        textFormat: Text.RichText
                        visible: !listItem.header && text
                    }

                    ListItemLabel {
                        //anchors.leftMargin: searchField.textLeftMargin
                        color: app.styler.themeSecondaryColor
                        font.pixelSize: app.styler.themeFontSizeExtraSmall
                        height: visible ? implicitHeight : 0
                        text: {
                            if (model.distance && model.description)
                                return model.description + "\n" + model.distance;
                            if (model.description)
                                return model.description;
                            return model.distance;
                        }
                        truncMode: truncModes.none
                        visible: !listItem.header && text
                        wrapMode: Text.WordWrap
                    }

                    Spacer {
                        height: extraSpacer.height
                    }
                }

                ListView.onRemove: animateRemoval(listItem);

                onClicked: {
                    if (listItem.header) return;
                    listItem.focus = true;
                    if (model.type === "autocomplete" || model.type === "result") {
                        var details = geo.resultDetails[model.detailId];
                        if (!details) {
                            console.log("GeocoderItem Unexpected result: " + model.detailId);
                            return;
                        }
                        details.selection_type = "search result";
                        selection = details;
                        model.visited = highlightSelected ? "Yes" : "";
                    } else if (model.type === "poi") {
                        var poi = geo.resultDetails[model.detailId];
                        poi.selection_type = "poi";
                        selection = poi;
                    } else if (model.type === "recent search"){
                        // No autocompletion, no POI, open results geo.
                        searchField.text = model.text;
                        fetchResults();
                    } else {
                        console.log("Unknown type in Geocoder Item: " + model.type)
                    }
                }
            }
            model: ListModel {}
        }
    }

    Timer {
        id: autocompleteTimer
        interval: 1000
        repeat: true
        running: geo.active && app.conf.autoCompleteGeo
        triggeredOnStart: true
        onTriggered: geo.fetchCompletions();
    }

    Timer {
        id: fillModelTimer
        interval: 250
        repeat: true
        running: geo.active && geo.fillModel && results.model.count < targetCount
        property var  empty: null
        property int  targetCount: 100
        onRunningChanged: {
            cache.reset();
            geo.update();
        }
        onTriggered: {
            // init model
            if (!empty) return;
            var first = (!results.model.count);
            var n = 10;
            for (var i=0; i < n && results.model.count < targetCount; ++i)
                results.model.append(empty);
            // update on the first call and on the half way
            if (first || (targetCount/2 > results.model.count-n && targetCount/2 <= results.model.count)) {
                cache.reset();
                geo.update();
            }
        }
        Component.onCompleted: {
            var e = {"visible": true};
            _listDataKeys.forEach(function (k){
                e[k] = "";
            });
            empty = e;
        }
    }

    QtObject {
        id: cache
        property var c: null

        function get(type, key) {
            if (c && c[type] && c[type].key===key) return c[type].data;
            return undefined;
        }

        function reset() {
            c = null;
        }

        function set(type, key, data) {
            var n = c ? c : {};
            n[type] = {"data": data, "key": key};
            c = n;
        }
    }

    Component.onCompleted: {
        geo.loadHistory();
        geo.update();
        if (active) activate();
    }

    onActiveChanged: if (active) activate();

    function activate() {
        geo.selection = null;
        searchField.forceActiveFocus();
    }

    function fetchCompletions() {
        // Fetch completions for a partial search query.
        if (!app.conf.autoCompleteGeo || geo.autocompletePending || geo.searchPending || geo.searchDone) return;
        var query = geo.query;
        if (!query || query === geo.prevAutocompleteQuery) return;
        geo.autocompletePending = true;
        geo.prevAutocompleteQuery = query;
        var x = map.position.coordinate.longitude || 0;
        var y = map.position.coordinate.latitude || 0;
        py.call("poor.app.geocoder.autocomplete", [query, x, y], function(results) {
            geo.autocompletePending = false;
            if (!geo.active || geo.searchPending || geo.searchDone) return;
            results = results || [];
            geo.autocompletions = results.slice(0, 10).map(function (p){
                var n = pois.convertFromPython(p);
                n.label = p.label;
                return n;
            });
            geo.update();
        });
    }

    function fetchResults() {
        _searchIndex += 1;
        var mySearchIndex = _searchIndex;
        searchPending = true;
        searchDone = false;
        searchResults = [];
        autocompletePending = false; // skip any ongoing autocomplete search
        py.call_sync("poor.app.history.add_place", [query]);
        var x = map.position.coordinate.longitude || 0;
        var y = map.position.coordinate.latitude || 0;
        geo.update();
        py.call("poor.app.geocoder.geocode", [query, null, x, y], function(results) {
            // skip, new search or autocomplete was started
            if (_searchIndex !== mySearchIndex || !searchPending) return;

            searchPending = false;
            searchDone = true;
            if (results && results.error && results.message) {
                searchError = results.message;
                searchResults = [];
            } else {
                searchResults = results.map(function (p){
                    var n = pois.convertFromPython(p);
                    n.description = p.description;
                    n.distance = p.distance;
                    return n;
                });
            }
            searchDone = true;
            geo.update();
        });
    }

    function fillCompletions() {
        // Fill found autocompletions for the current search query.
        var found = [];
        if (query && geo.autocompletions && geo.autocompletions.length > 0) {
            found.push({
                           "markup": app.tr("Suggestions (%1)").arg(geo.autocompletions.length),
                           "type": "header"
                       });
            autocompletions.forEach(function (p){
                var k = "autocompletions - " + p.label;
                found.push({
                               "detailId": k,
                               "markup": p.label,
                               "type": "autocomplete"
                           });
                resultDetails[k] = p;
            });
        }
        return found;
    }

    function fillResults() {
        // Fill found results for the current search query
        var found = [];
        if (searchError) {
            found.push({
                           "markup": app.tr("Error while fetching results"),
                           "type": "header"
                       });
            found.push({
                           "markup": searchError,
                           "type": "error"
                       });
        } else if (searchPending) {
            found.push({
                           "markup": app.tr("Searching ..."),
                           "type": "header"
                       });
        } else if (searchResults.length === 0) {
            found.push({
                           "markup": app.tr("No results"),
                           "type": "header"
                       });
        } else {
            found.push({
                           "markup": app.tr("Results (%1)").arg(searchResults.length),
                           "type": "header"
                       });
            var index = 0;
            searchResults.forEach(function (p){
                index += 1;
                var k = "search results - %1".arg(index);
                found.push({
                               "detailId": k,
                               "title": p.title,
                               "description": p.description,
                               "distance": p.distance,
                               "type": "result"
                           });
                resultDetails[k] = p;
            });
        }
        return found;
    }

    function filterPois() {
        // POIs
        var found = [];
        var pois = cache.get("poi", query);
        if (!pois) {
            var searchKeys = ["shortlisted", "bookmarked", "title", "poiType",
                              "address", "postcode", "text", "phone", "link"];
            pois = app.pois.pois.filter(function (p) {
                return (geo.poiBlacklisted.indexOf(p.poiId) < 0 &&
                        (query || p.shortlisted));
            });
            if (query) pois = Util.findMatchesInObjects(query, pois, searchKeys);
            cache.set("poi", query, pois);
        }
        if (pois.length > 0) {
            found.push({
                           "markup": app.tr("Points of Interest (%1)").arg(pois.length),
                           "type": "header"
                       });
            pois = pois.slice(0, 10);
            pois.forEach(function (p){
                var t = (p.title ? p.title : app.tr("Unnamed point")) +
                        (p.bookmarked ? " ☆" : "") + (p.shortlisted ? " ☰" : "");
                var k = "poi - " + p.poiId;
                found.push({
                               "detailId": k,
                               "markup": t,
                               "type": "poi"
                           });
                resultDetails[k] = p;
            });
        }

        return found;
    }

    function filterRecentSearch() {
        // Filter recent searches for the current search query.
        var found = [];
        var cached = cache.get("recent", query);
        if (cached) return cached;
        var f = Util.findMatches(geo.query,
                                 geo.history,
                                 [],
                                 Math.min(25, results.model.count));
        if (f.length > 0) {
            found.push({
                           "markup": app.tr("Recent searches (%1)").arg(f.length),
                           "type": "header"
                       });
            f.forEach(function (p){
                found.push({
                               "markup": p.markup,
                               "text": p.text,
                               "type": "recent search"
                           });
            });
        }
        cache.set("recent", query, found);
        return found;
    }

    function loadHistory() {
        // Load search history and preallocate list items.
        geo.history = py.evaluate("poor.app.history.places");
    }

    function update() {
        if (!results.model.count) return; // too early, hasn't initialized yet
        var found = [];
        stateId = "Geocoder: " + query;
        resultDetails = []

        // use a long form to avoid crashes in JS
        // while calling free on the tmp variables
        var f = [];
        f = filterPois();
        f.forEach(function (p) { found.push(p) });
        if (searchPending || searchDone) {
            f = fillResults();
            f.forEach(function (p) { found.push(p) });
        } else {
            f = fillCompletions();
            f.forEach(function (p) { found.push(p) });
            f = filterRecentSearch();
            f.forEach(function (p) { found.push(p) });
        }

        Util.injectData(results.model, found, _listDataKeys);
        //geo.placeholderEnabled = found.length === 0;
    }
}
