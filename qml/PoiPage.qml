/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2018 Rinigus
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
import QtPositioning 5.3
import Sailfish.Silica 1.0
import "."

import "js/util.js" as Util

Dialog {
    id: page
    allowedOrientations: app.defaultAllowedOrientations

    property string lastQuery: ""
    property var searchKeys: ["title", "poiType", "address", "postcode", "text", "phone", "link"]

    SilicaListView {
        id: listView
        anchors.fill: parent
        // Prevent list items from stealing focus.
        currentIndex: -1

        delegate: ListItem {
            id: listItem
            contentHeight: titleItem.height + detailsItem.height + textItem.height + Theme.paddingLarge

            ListItemLabel {
                id: titleItem
                anchors.leftMargin: listView.searchField.textLeftMargin
                color: listItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                height: implicitHeight + Theme.paddingSmall
                text: (model.title ? model.title : app.tr("Unnamed point")) + (model.bookmarked ? " ☆" : "")
                verticalAlignment: Text.AlignTop
            }

            ListItemLabel {
                id: detailsItem
                anchors.top: titleItem.bottom
                anchors.leftMargin: listView.searchField.textLeftMargin
                color: listItem.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
                height: text ? implicitHeight + Theme.paddingSmall : 0
                maximumLineCount: 1
                text: {
                    if (model.poiType && model.address) return model.poiType + ", " + model.address;
                    if (model.poiType) return model.poiType;
                    return model.address;
                }
                verticalAlignment: Text.AlignTop
            }

            ListItemLabel {
                id: textItem
                anchors.top: detailsItem.bottom
                anchors.topMargin: Theme.paddingSmall
                anchors.leftMargin: listView.searchField.textLeftMargin
                color: listItem.highlighted ? Theme.secondaryHighlightColor : Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                height: text ? implicitHeight : 0
                maximumLineCount: 1
                text: model.text
                truncationMode: TruncationMode.Elide
                verticalAlignment: Text.AlignTop
            }

            onClicked: {
                var p = map.getPoiById(model.poiId);
                if (!p) {
                    // poi got missing, let's refill
                    fillModel(lastQuery);
                    return;
                }
                map.showPoi(p, true);
                map.setCenter(
                            p.coordinate.longitude,
                            p.coordinate.latitude);
                app.hideMenu();
            }

        }

        header: Column {
            height: header.height + searchField.height
            width: parent.width

            PageHeader {
                id: header
                title: app.tr("Points of Interest")
            }

            SearchField {
                id: searchField
                placeholderText: app.tr("Search")
                width: parent.width
                property string prevText: ""
                onTextChanged: {
                    var newText = searchField.text.trim().toLowerCase();
                    if (newText === lastQuery) return;
                    fillModel(newText);
                    lastQuery = newText;
                }
            }

            Component.onCompleted: listView.searchField = searchField;

        }

        model: ListModel {}

        property var searchField: undefined

        ViewPlaceholder {
            id: viewPlaceholder
            enabled: map.pois.length === 0
            hintText: app.tr("No points of interests defined yet. You can create and bookmark points of interest using map and search.")
        }

        VerticalScrollDecorator {}

    }

    Component.onCompleted: {
        fillModel("");
    }

    function fillModel(query) {
        var s = Util.findMatchesInObjects(query, map.pois, searchKeys);
        listView.model.clear();
        s.map(function (p){ listView.model.append(p); });
    }

}
