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
import "."
import "platform"

import "js/util.js" as Util

PageListPL {
    id: page
    title: app.tr("Points of Interest")

    currentIndex: -1

    delegate: ListItemPL {
        id: listItem
        contentHeight: titleItem.height + detailsItem.height + textItem.height + spacer.height*2

        Spacer {
            id: spacer
            height: app.styler.themePaddingLarge/2
        }

        ListItemLabel {
            id: titleItem
            anchors.leftMargin: page.searchField.textLeftMargin
            anchors.top: spacer.bottom
            color: listItem.highlighted ? app.styler.themeHighlightColor : app.styler.themePrimaryColor
            height: implicitHeight + app.styler.themePaddingSmall
            text: (model.title ? model.title : app.tr("Unnamed point")) + (model.bookmarked ? " ☆" : "")
            verticalAlignment: Text.AlignTop
        }

        ListItemLabel {
            id: detailsItem
            anchors.top: titleItem.bottom
            anchors.leftMargin: page.searchField.textLeftMargin
            color: listItem.highlighted ? app.styler.themeSecondaryHighlightColor : app.styler.themeSecondaryColor
            font.pixelSize: app.styler.themeFontSizeSmall
            height: text ? implicitHeight + app.styler.themePaddingSmall : 0
            text: {
                if (model.poiType && model.address) return model.poiType + ", " + model.address;
                if (model.poiType) return model.poiType;
                return model.address;
            }
            verticalAlignment: Text.AlignTop
            wrapMode: Text.WordWrap
        }

        ListItemLabel {
            id: textItem
            anchors.top: detailsItem.bottom
            anchors.topMargin: app.styler.themePaddingSmall
            anchors.leftMargin: page.searchField.textLeftMargin
            color: listItem.highlighted ? app.styler.themeSecondaryHighlightColor : app.styler.themeSecondaryColor
            font.pixelSize: app.styler.themeFontSizeExtraSmall
            height: text ? implicitHeight : 0
            maximumLineCount: 1
            text: model.text
            truncMode: truncModes.elide
            verticalAlignment: Text.AlignTop
        }

        menu: ContextMenuPL {
            id: contextMenu
            ContextMenuItemPL {
                text: app.tr("View")
                onClicked: {
                    var poi = map.getPoiById(model.poiId);
                    if (!poi) return;
                    app.push("PoiInfoPage.qml",
                             {"poi": poi});
                }
            }
            ContextMenuItemPL {
                text: app.tr("Edit")
                onClicked: {
                    var poi = map.getPoiById(model.poiId);
                    if (!poi) return;
                    var dialog = app.push("PoiEditPage.qml",
                                          {"poi": poi});
                    dialog.accepted.connect(function() {
                        map.updatePoi(dialog.poi);
                        fillModel(lastQuery);
                    })
                }
            }
            ContextMenuItemPL {
                text: app.tr("Remove")
                onClicked: {
                    app.map.deletePoi(model.poiId);
                    page.model.remove(index);
                }
            }
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

    headerExtra: Component {
        SearchFieldPL {
            id: searchField
            width: parent.width
            placeholderText: app.tr("Search")
            property string prevText: ""
            onTextChanged: {
                var newText = searchField.text.trim().toLowerCase();
                if (newText === lastQuery) return;
                fillModel(newText);
                lastQuery = newText;
            }

            Component.onCompleted: page.searchField = searchField;
        }
    }

    model: ListModel {}

    pageMenu: PageMenuPL {
        PageMenuItemPL {
            text: bookmarkedOnly ? app.tr("Show all") : app.tr("Show bookmarked")
            onClicked: {
                bookmarkedOnly = !bookmarkedOnly;
                app.conf.set("poi_list_show_bookmarked", bookmarkedOnly);
                fillModel(lastQuery);
            }
        }
    }

    placeholderEnabled: map.pois.length === 0
    placeholderText: app.tr("No points of interests defined yet. You can create and bookmark points of interest using map and search.")

    property bool   bookmarkedOnly: false
    property string lastQuery: ""
    property var    searchField: undefined
    property var    searchKeys: ["title", "poiType", "address", "postcode", "text", "phone", "link"]

    Component.onCompleted: {
        bookmarkedOnly = app.conf.get("poi_list_show_bookmarked");
        fillModel("");
    }

    function fillModel(query) {
        var data = map.pois;
        if (bookmarkedOnly) data = map.pois.filter(function (p) { return p.bookmarked; });
        var s = Util.findMatchesInObjects(query, data, searchKeys);
        page.model.clear();
        s.map(function (p){ page.model.append(p); });
    }

}
