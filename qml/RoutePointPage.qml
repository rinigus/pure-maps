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
    property var    completionDetails: []
    property var    history: []
    property var    poiCompletionDetails: []
    property string prevAutocompleteQuery: "."
    property string query: ""
    property var    selectedPoi: undefined

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
                        py.call_sync("poor.app.history.remove_place", [model.place]);
                        dialog.history = py.evaluate("poor.app.history.places");
                        listView.model.remove(index);
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

        header: Column {
            height: dialogHeader.height + gpsItem.height + searchField.height
            width: parent.width

            DialogHeader {
                id: dialogHeader
            }

            ListItem {
                id: gpsItem
                contentHeight: Theme.itemSizeSmall
                ListItemLabel {
                    anchors.leftMargin: listView.searchField.textLeftMargin
                    color: Theme.highlightColor
                    height: Theme.itemSizeSmall
                    text: app.tr("Current position")
                }
                onClicked: {
                    dialog.query = app.tr("Current position");
                    dialog.accept();
                }
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
            running: dialog.status === PageStatus.Active && app.conf.autoCompleteGeo
            triggeredOnStart: true
            onTriggered: dialog.fetchCompletions();
        }

        ViewPlaceholder {
            id: viewPlaceholder
            enabled: false
            hintText: app.tr("You can search by address, locality, landmark and many other terms. For best results, include a region, e.g. “address, city” or “city, country”.")
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
        if (!app.conf.autoCompleteGeo || dialog.autocompletePending) return;
        var query = listView.searchField.text.trim();
        if (query === dialog.prevAutocompleteQuery) return;
        dialog.autocompletePending = true;
        dialog.prevAutocompleteQuery = query;
        var x = map.position.coordinate.longitude || 0;
        var y = map.position.coordinate.latitude || 0;
        py.call("poor.app.router.geocoder.autocomplete", [query, x, y], function(results) {
            if (!dialog) return;
            dialog.autocompletePending = false;
            if (dialog.status !== PageStatus.Active) return;
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
        var found = Util.findMatches(listView.searchField.text.trim(),
                                     dialog.history,
                                     dialog.autocompletions,
                                     listView.model.count);

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
        Util.injectMatches(listView.model, found, "place", "text");
        viewPlaceholder.enabled = found.length === 0;
    }

    function loadHistory() {
        // Load search history and preallocate list items.
        dialog.history = py.evaluate("poor.app.history.places");
        while (listView.model.count < 100)
            listView.model.append({"place": "",
                                   "text": "",
                                   "visible": false});

    }

}
