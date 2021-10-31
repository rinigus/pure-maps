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

PagePL {
    id: page
    title: poi.title || app.tr("Unnamed point")

    pageMenu: PageMenuPL {
        PageMenuItemPL {
            enabled: page.active
            iconName: styler.iconEdit
            text: app.tr("Edit")
            onClicked: {
                var dialog = app.push(Qt.resolvedUrl("PoiEditPage.qml"),
                                      {"poi": poi});
                dialog.accepted.connect(function() {
                    pois.update(dialog.poi);
                })
            }
        }
    }

    property bool active: false
    property bool bookmarked: false
    property bool hasCoordinate: poi && poi.coordinate ? true : false
    property var  poi
    property bool shortlisted: false

    Column {
        id: column
        width: page.width

        ListItemLabel {
            color: styler.themeHighlightColor
            height: implicitHeight + styler.themePaddingMedium
            text: poi.poiType ? poi.poiType : ""
            truncMode: truncModes.none
            verticalAlignment: Text.AlignTop
            visible: text
            wrapMode: Text.WordWrap
        }

        ListItemLabel {
            color: styler.themeHighlightColor
            font.pixelSize: styler.themeFontSizeSmall
            height: implicitHeight + styler.themePaddingMedium
            text: hasCoordinate ? app.tr("Latitude: %1", poi.coordinate.latitude) + "\n" +
                                  app.tr("Longitude: %2", poi.coordinate.longitude) : ""
            truncMode: truncModes.none
            verticalAlignment: Text.AlignTop
            visible: text
            wrapMode: Text.WordWrap
        }

        ListItemLabel {
            color: styler.themeHighlightColor
            font.pixelSize: styler.themeFontSizeSmall
            height: implicitHeight + styler.themePaddingMedium
            text: hasCoordinate ? app.tr("Plus code: %1",
                                         py.call_sync("poor.util.format_location_olc",
                                                      [poi.coordinate.longitude,
                                                       poi.coordinate.latitude])) : ""
            truncMode: truncModes.none
            verticalAlignment: Text.AlignTop
            visible: text
            wrapMode: Text.WordWrap
        }

        Spacer {
            height: styler.themePaddingMedium
        }

        SectionHeaderPL {
            height: implicitHeight + styler.themePaddingMedium
            text: poi.address || poi.postcode ? app.tr("Address") : ""
            visible: text
        }

        ListItemLabel {
            color: styler.themeHighlightColor
            height: implicitHeight + styler.themePaddingMedium
            text: poi.address ? poi.address : ""
            truncMode: truncModes.none
            verticalAlignment: Text.AlignTop
            visible: text
            wrapMode: Text.WordWrap
        }

        ListItemLabel {
            color: styler.themeHighlightColor
            height: implicitHeight + styler.themePaddingMedium
            text: poi.postcode ? app.tr("Postal code: %1", poi.postcode) : ""
            truncMode: truncModes.none
            verticalAlignment: Text.AlignTop
            visible: text
            wrapMode: Text.WordWrap
        }

        Spacer {
            height: styler.themePaddingMedium
        }

        SectionHeaderPL {
            height: implicitHeight + styler.themePaddingMedium
            text: app.tr("Actions")
        }

        IconListItem {
            enabled: page.active
            icon: bookmarked ? styler.iconFavoriteSelected  : styler.iconFavorite
            label: app.tr("Bookmark")
            onClicked: {
                if (!active) return;
                bookmarked = !bookmarked;
                poi.bookmarked = bookmarked;
                pois.bookmark(poi.poiId, bookmarked);
            }
        }

        IconListItem {
            id: shortlistItem
            enabled: page.active && bookmarked
            icon: shortlisted ? styler.iconShortlistedSelected  : styler.iconShortlisted
            label: app.tr("Shortlist")
            onClicked: {
                if (!active) return;
                shortlisted = !shortlisted;
                if (poi.shortlisted === shortlisted) return;
                poi.shortlisted = shortlisted;
                pois.shortlist(poi.poiId, shortlisted);
            }
        }

        IconListItem {
            enabled: hasCoordinate
            icon: styler.iconShare
            label: app.tr("Share location")
            onClicked: {
                app.push(Qt.resolvedUrl("SharePage.qml"), {
                             "coordinate": poi.coordinate,
                             "title": poi.title,
                             "poi": poi
                         });
            }
        }

        IconListItem {
            enabled: hasCoordinate
            icon: styler.iconDot
            label: app.tr("Center on location")
            onClicked: {
                map.setCenter(
                            poi.coordinate.longitude,
                            poi.coordinate.latitude);
                app.showMap();
            }
        }

        IconListItem {
            enabled: hasCoordinate
            icon: styler.iconNavigateTo
            label: app.tr("Navigate To")
            onClicked: {
                navigator.clearRoute();
                navigator.findRoute([{"text": poi.title,
                                     "x": poi.coordinate.longitude, "y": poi.coordinate.latitude,
                                     "destination": true} ],
                                    {"save": true, "fitToView": true} );
                app.showMap();
                pois.hide();
            }
        }

        IconListItem {
            enabled: hasCoordinate
            icon: styler.iconNavigateFrom
            label: app.tr("Navigate From")
            onClicked: {
                navigator.clearRoute();
                app.showMenu(Qt.resolvedUrl("RoutePage.qml"), {
                                 "from": [poi.coordinate.longitude, poi.coordinate.latitude],
                                 "fromText": poi.title,
                             });
            }
        }

        IconListItem {
            enabled: hasCoordinate
            icon: styler.iconNearby
            label: app.tr("Nearby")
            onClicked: {
                app.showMenu(Qt.resolvedUrl("NearbyPage.qml"), {
                                 "near": [poi.coordinate.longitude, poi.coordinate.latitude],
                                 "nearText": poi.title,
                             });
            }
        }

        SectionHeaderPL {
            height: text ? implicitHeight + styler.themePaddingMedium : 0
            text: poi.phone || poi.link ? app.tr("Contact") : ""
            visible: text
        }

        IconListItem {
            height: styler.themeItemSizeSmall
            icon: poi.phone ? styler.iconPhone : ""
            label: poi.phone
            visible: poi.phone
            onClicked: Qt.openUrlExternally("tel:" + poi.phone)
        }

        IconListItem {
            height: styler.themeItemSizeSmall
            icon: poi.link ? styler.iconWebLink : ""
            label: poi.link
            visible: poi.link
            onClicked: Qt.openUrlExternally(poi.link)
        }

        IconListItem {
            height: styler.themeItemSizeSmall
            icon: poi.email ? styler.iconWebLink : ""
            label: poi.email
            visible: poi.email
            onClicked: Qt.openUrlExternally(poi.email)
        }

        Spacer {
            height: styler.themePaddingMedium
        }

        SectionHeaderPL {
            height: text ? implicitHeight + styler.themePaddingMedium : 0
            text: poi.text ? app.tr("Additional info") : ""
            visible: text
        }

        ListItemLabel {
            color: styler.themeHighlightColor
            height: implicitHeight + styler.themePaddingMedium
            text: poi.text
            truncMode: truncModes.none
            verticalAlignment: Text.AlignTop
            visible: text
            wrapMode: Text.WordWrap
        }

        Connections {
            target: pois
            onPoiChanged: {
                if (poi.poiId !== poiId) return;
                page.setPoi(pois.getById(poiId));
            }
        }
    }

    Component.onCompleted: {
        if (!poi.coordinate)
            poi.coordinate = QtPositioning.coordinate(poi.y, poi.x);
        setPoi(poi);
    }

    function setPoi(p) {
        page.poi = p;
        page.bookmarked = Boolean(p.bookmarked);
        page.shortlisted = Boolean(p.shortlisted);
    }

}
