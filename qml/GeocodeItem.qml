/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2017 Osmo Salomaa, 2018-2019 Rinigus, 2019 Purism SPC
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
import QtPositioning 5.4
import "."
import "platform"

import "js/util.js" as Util

///////////////////////////////////////////////////
// Item allowing to search for locations and POIs

Item {
    id: geo

    height: active ? column.height : selectionItem.height
    width: parent.width

    property bool   active: false
    property bool   fillModel: true
    property bool   highlightSelected: true
    property string searchPlaceholderText: app.tr("Search")
    property bool   showCurrentPosition: false
    property var    searchResults: [] // current list of found search or autocomplete results
    property var    selection: null
    property string selectionPlaceholderText: app.tr("No selection")
    property string stateId: "Geocoder: " + query + _stateIdCounter
    property string query: ""

    readonly property var selectionTypes: QtObject {
        readonly property int currentPosition: 1
        readonly property int searchResult: 2
        readonly property int poi: 3
    }

    // internal properties
    property bool   _autocompletePending: false
    property var    _autocompletions: []
    property var    _history: []
    property string _prevAutocompleteQuery: "."
    property var    _resultDetails: {}
    property bool   _searchDone: false
    property string _searchError: ""
    property var    _searchHits: []
    property int    _searchIndex: 0
    property bool   _searchPending: false
    property int    _stateIdCounter: 0

    // internal properties: readonly
    readonly property var _listDataKeys:
        ["description", "detailId", "distance", "markup", "text", "title", "type", "visited"]

    // Components

    ListItemPL {
        id: selectionItem
        contentHeight: visible? itemSel.height + styler.themePaddingLarge : 0
        visible: !active

        ListItemLabel {
            id: itemSel
            anchors.verticalCenter: parent.verticalCenter
            color: styler.themePrimaryColor
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
            placeholderText: searchPlaceholderText
            text: query
            width: parent.width
            property string prevText: ""
            onSearch: fetchResults();
            onTextChanged: {
                var newText = searchField.text.trim();
                if (!newText && selection) selection = null;
                if (!newText && searchResults) searchResults = [];
                if (newText === searchField.prevText) return;
                selection = null;
                geo._searchPending = false;
                geo._searchDone = false;
                geo.query = newText;
                searchField.prevText = newText;
                geo.update();
            }
        }

        Spacer {
            height: styler.themePaddingLarge
        }

        Repeater {
            id: results

            delegate: ListItemPL {
                id: listItem
                contentHeight: {
                    if (!visible) return 0;
                    if (setHeightToSmall && styler.themeItemSizeSmall > itemColumn.height)
                        return styler.themeItemSizeSmall;
                    return itemColumn.height
                }
                menu: ContextMenuPL {
                    id: contextMenu
                    enabled: model.type === "recent search"
                    ContextMenuItemPL {
                        enabled: model.type === "recent search"
                        iconName: enabled ? styler.iconDelete : ""
                        text: enabled ? app.tr("Remove") : ""
                        onClicked: {
                            if (model.type !== "recent search") return;
                            py.call_sync("poor.app.history.remove_place", [model.text]);
                            geo._history = py.evaluate("poor.app.history.places");
                            model.visible = false;
                        }
                    }
                }
                visible: model.visible

                property bool header: model.type === "header"
                property bool currentPosition: model.type === "current position"
                property bool setHeightToSmall: model.type === "poi" ||
                                                model.type === "recent search" ||
                                                model.type === "autocomplete" ||
                                                model.type === "subquery"
                property bool visited: model.visited

                Column {
                    id: itemColumn
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: styler.themePaddingSmall

                    Spacer {
                        id: extraSpacer
                        height: Math.max(0, styler.themePaddingLarge / 2 - styler.themePaddingSmall)
                    }

                    SectionHeaderPL {
                        height: visible ? implicitHeight : 0
                        text: model.markup
                        visible: listItem.header
                        wrapMode: Text.WordWrap
                    }

                    ListItemLabel {
                        //anchors.leftMargin: searchField.textLeftMargin
                        color: (listItem.highlighted || listItem.visited || !listItem.enabled) ?
                                   styler.themeHighlightColor : styler.themePrimaryColor
                        height: visible ? implicitHeight : 0
                        text: (model.type === "subquery" ? "\u2794 " : "") + (model.markup ? model.markup : model.title)
                        textFormat: Text.StyledText
                        visible: !listItem.header && text
                    }

                    ListItemLabel {
                        //anchors.leftMargin: searchField.textLeftMargin
                        color: listItem.highlighted ? styler.themeSecondaryHighlightColor : styler.themeSecondaryColor
                        font.pixelSize: styler.themeFontSizeExtraSmall
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
                    if (currentPosition) {
                        var pos = {
                            "title": app.tr("Current position"),
                            "selectionType": selectionTypes.currentPosition
                        };
                        selection = pos;
                    } else if (model.type === "autocomplete" || model.type === "result") {
                        var details = geo._resultDetails[model.detailId];
                        if (!details) {
                            console.log("GeocoderItem Unexpected result: " + model.detailId);
                            return;
                        }
                        details.selectionType = selectionTypes.searchResult;
                        if (!details.coordinate)
                            details.coordinate = QtPositioning.coordinate(details.y, details.x);
                        selection = details;
                        model.visited = highlightSelected ? "Yes" : "";
                    } else if (model.type === "poi") {
                        var poi = geo._resultDetails[model.detailId];
                        poi.selectionType = selectionTypes.poi;
                        if (!poi.coordinate)
                            poi.coordinate = QtPositioning.coordinate(poi.y, poi.x);
                        selection = poi;
                    } else if (model.type === "recent search"){
                        // No autocompletion, no POI, open results geo.
                        searchField.text = model.text;
                        fetchResults();
                    } else if (model.type === "subquery"){
                        var q = geo._resultDetails[model.detailId];
                        if (!q) {
                            console.log("GeocoderItem Unexpected result: " + model.detailId);
                            return;
                        }
                        searchField.text = model.title;
                        fetchResults(q.query);
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
        if (active) {
            if (query) fetchResults();
            else activate();
        }
    }

    onActiveChanged: if (active) activate();

    function activate() {
        geo.selection = null;
        searchField.forceActiveFocus();
    }

    function fetchCompletions() {
        // Fetch completions for a partial search query.
        if (!app.conf.autoCompleteGeo || geo._autocompletePending || geo._searchPending || geo._searchDone) return;
        var query = geo.query;
        if (!query || query === geo._prevAutocompleteQuery) return;
        geo._autocompletePending = true;
        geo._prevAutocompleteQuery = query;
        py.call("poor.app.geocoder.autocomplete",
                gps.coordinateValid ? [query, gps.coordinate.longitude, gps.coordinate.latitude,
                                       map.center.longitude, map.center.latitude] :
                                      [query, 0, 0, map.center.longitude, map.center.latitude],
                function(results) {
            if (!geo._autocompletePending) return;

            geo._autocompletePending = false;
            if (!geo.active || geo._searchPending || geo._searchDone) return;
            results = results || [];
            geo._autocompletions = results.slice(0, 10).map(function (p){
                var n = pois.convertFromPython(p);
                n.label = p.label;
                return n;
            });
            setSearchResults(geo._autocompletions);
            geo.update();
        });
    }

    function fetchResults(queryStructure) {
        _searchIndex += 1;
        var mySearchIndex = _searchIndex;
        var q = queryStructure ? queryStructure : query
        _searchPending = true;
        _searchDone = false;
        _searchHits = [];
        setSearchResults([]);
        _autocompletePending = false; // skip any ongoing autocomplete search
        if (queryStructure == null) {
            py.call_sync("poor.app.history.add_place", [query]);
            geo.update();
        }
        py.call("poor.app.geocoder.geocode",
                gps.coordinateValid ? [q, gps.coordinate.longitude, gps.coordinate.latitude,
                                       map.center.longitude, map.center.latitude] :
                                      [q, 0, 0, map.center.longitude, map.center.latitude],
                function(results) {
            // skip, new search or autocomplete was started
            if (_searchIndex !== mySearchIndex || !_searchPending) return;

            _searchPending = false;
            _searchDone = true;
            if (results && results.error && results.message) {
                _searchError = results.message;
                _searchHits = [];
            } else {
                _searchHits = results.map(function (p){
                    var n = pois.convertFromPython(p);
                    n.description = p.description;
                    n.distance = p.distance;
                    return n;
                });
            }
            setSearchResults(_searchHits);
            _searchDone = true;
            geo.update();
        });
    }

    function fillCompletions() {
        // Fill found autocompletions for the current search query.
        var found = [];
        if (query && geo._autocompletions && geo._autocompletions.length > 0) {
            found.push({
                           "markup": app.tr("Suggestions (%1)").arg(geo._autocompletions.length),
                           "type": "header"
                       });
            _autocompletions.forEach(function (p){
                var k = "autocompletions - " + p.label;
                found.push({
                               "detailId": k,
                               "markup": p.label,
                               "title": p.label,
                               "type": p.poiType === "PM:Query" ? "subquery" : "autocomplete"
                           });
                _resultDetails[k] = p;
            });
        }
        return found;
    }

    function fillResults() {
        // Fill found results for the current search query
        var found = [];
        if (_searchError) {
            found.push({
                           "markup": app.tr("Error while fetching results"),
                           "type": "header"
                       });
            found.push({
                           "markup": _searchError,
                           "type": "error"
                       });
        } else if (_searchPending) {
            found.push({
                           "markup": app.tr("Searching ..."),
                           "type": "header"
                       });
        } else if (_searchHits.length === 0) {
            found.push({
                           "markup": app.tr("No results"),
                           "type": "header"
                       });
        } else {
            found.push({
                           "markup": app.tr("Results (%1)").arg(_searchHits.length),
                           "type": "header"
                       });
            var index = 0;
            _searchHits.forEach(function (p){
                index += 1;
                var k = "search results - %1".arg(index);
                found.push({
                               "detailId": k,
                               "title": p.title,
                               "description": p.description,
                               "distance": p.distance,
                               "type": p.poiType === "PM:Query" ? "subquery" : "result"
                           });
                _resultDetails[k] = p;
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
                return (p.bookmarked &&
                        (query || p.shortlisted));
            });
            pois = Util.findMatchesInObjects(query, pois, searchKeys);
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
                _resultDetails[k] = p;
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
                                 geo._history,
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
        geo._history = py.evaluate("poor.app.history.places");
    }

    function setSearchResults(n) {
        _stateIdCounter += 1;
        searchResults = n;
    }

    function update() {
        if (!results.model.count) return; // too early, hasn't initialized yet
        var found = [];
        _resultDetails = {}

        // add current location if its requested and there
        // is no query
        if (!query && showCurrentPosition) {
            found.push({
                           "markup": app.tr("Current position"),
                           "type": "current position"
                       });
        }

        // use a long form to avoid crashes in JS
        // while calling free on the tmp variables
        var f = [];
        f = filterPois();
        f.forEach(function (p) { found.push(p) });
        if (_searchPending || _searchDone) {
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
