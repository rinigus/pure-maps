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
import QtPositioning 5.4
import "."
import "platform"

import "js/util.js" as Util

PageListPL {
    id: page
    title: app.tr("Bookmarks")

    currentIndex: -1

    delegate: ListItemPL {
        id: listItem
        contentHeight: titleItem.height + detailsItem.height + textItem.height + spacer.height*2

        Spacer {
            id: spacer
            height: styler.themePaddingLarge/2
        }

        ListItemLabel {
            id: titleItem
            anchors.leftMargin: page.searchField.textLeftMargin
            anchors.top: spacer.bottom
            color: listItem.highlighted ? styler.themeHighlightColor : styler.themePrimaryColor
            height: implicitHeight + styler.themePaddingSmall
            text: (model.title ? model.title : app.tr("Unnamed point")) + (model.bookmarked ? " ☆" : "") + (model.shortlisted ? " ☰" : "")
            verticalAlignment: Text.AlignTop
        }

        ListItemLabel {
            id: detailsItem
            anchors.leftMargin: page.searchField.textLeftMargin
            anchors.top: titleItem.bottom
            color: listItem.highlighted ? styler.themeSecondaryHighlightColor : styler.themeSecondaryColor
            font.pixelSize: styler.themeFontSizeSmall
            height: text ? implicitHeight + styler.themePaddingSmall : 0
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
            anchors.leftMargin: page.searchField.textLeftMargin
            anchors.top: detailsItem.bottom
            anchors.topMargin: styler.themePaddingSmall
            color: listItem.highlighted ? styler.themeSecondaryHighlightColor : styler.themeSecondaryColor
            font.pixelSize: styler.themeFontSizeExtraSmall
            height: text ? implicitHeight : 0
            maximumLineCount: 1
            text: model.text
            truncMode: truncModes.elide
            verticalAlignment: Text.AlignTop
        }

        menu: ContextMenuPL {
            id: contextMenu
            ContextMenuItemPL {
                iconName: styler.iconAbout
                text: app.tr("View")
                onClicked: {
                    var poi = pois.getById(model.poiId);
                    if (!poi) return;
                    app.push(Qt.resolvedUrl("PoiInfoPage.qml"),
                             {"active": true, "poi": poi});
                }
            }
            ContextMenuItemPL {
                iconName: styler.iconEdit
                text: app.tr("Edit")
                onClicked: {
                    var poi = pois.getById(model.poiId);
                    if (!poi) return;
                    var dialog = app.push(Qt.resolvedUrl("PoiEditPage.qml"),
                                          {"poi": poi});
                    dialog.accepted.connect(function() {
                        pois.update(dialog.poi);
                    })
                }
            }
            ContextMenuItemPL {
                iconName: styler.iconDelete
                text: app.tr("Remove")
                onClicked: {
                    pois.remove(model.poiId);
                }
            }
        }

        onClicked: {
            var p = pois.getById(model.poiId);
            if (!p) {
                // poi got missing, let's refill
                fillModel(lastQuery);
                return;
            }
            app.stateId = "pois";
            pois.show(p, true);
            map.setCenter(
                        p.coordinate.longitude,
                        p.coordinate.latitude);
            app.hideMenu(app.tr("Bookmarks"));
        }

    }

    headerExtra: Component {
        SearchFieldPL {
            id: searchField
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

    placeholderEnabled: pois.pois.length === 0
    placeholderText: app.tr("No points of bookmarks defined yet. You can bookmark locations using map and search.")

    property string lastQuery: ""
    property var    searchField: undefined
    property var    searchKeys: ["shortlisted", "bookmarked", "title", "poiType", "address", "postcode", "text", "phone", "link"]

    Connections {
        target: pois
        onPoiChanged: fillModel(lastQuery)
    }

    Component.onCompleted: {
        fillModel(lastQuery);
    }

    function fillModel(query) {
        var data = pois.pois;
        var s = Util.findMatchesInObjects(query, data, searchKeys);
        page.model.clear();
        s.forEach(function (p){ page.model.append(p); });
    }

}
