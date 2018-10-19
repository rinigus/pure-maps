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

PagePL {
    id: page
    title: poi.title || app.tr("Unnamed point")

    pageMenu: PageMenuPL {
        PageMenuItemPL {
            enabled: page.active
            text: app.tr("Edit")
            onClicked: {
                var dialog = app.push("PoiEditPage.qml",
                                      {"poi": poi});
                dialog.accepted.connect(function() {
                    map.updatePoi(dialog.poi);
                    page.poi = dialog.poi;
                    map.showPoi(dialog.poi);
                })
            }
        }
    }

    property bool active: false
    property var  poi
    property bool hasCoordinate: poi && poi.coordinate ? true : false

    Column {
        id: column
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: app.styler.themePaddingMedium
        width: parent.width

        ListItemLabel {
            color: app.styler.themeHighlightColor
            height: text ? implicitHeight + app.styler.themePaddingMedium: 0
            text: poi.poiType ? poi.poiType : ""
            truncMode: truncModes.none
            verticalAlignment: Text.AlignTop
            wrapMode: Text.WordWrap
        }

        ListItemLabel {
            color: app.styler.themeHighlightColor
            font.pixelSize: app.styler.themeFontSizeSmall
            height: text ? implicitHeight + app.styler.themePaddingMedium: 0
            text: hasCoordinate ? app.tr("Latitude: %1", poi.coordinate.latitude) + "\n" + app.tr("Longitude: %2", poi.coordinate.longitude) : ""
            truncMode: truncModes.none
            verticalAlignment: Text.AlignTop
            wrapMode: Text.WordWrap
        }

        Spacer {
            height: app.styler.themePaddingMedium
        }

        SectionHeaderPL {
            height: text ? implicitHeight + app.styler.themePaddingMedium : 0
            text: poi.address || poi.postcode ? app.tr("Address") : ""
        }

        ListItemLabel {
            color: app.styler.themeHighlightColor
            height: text ? implicitHeight + app.styler.themePaddingMedium: 0
            text: poi.address ? poi.address : ""
            truncMode: truncModes.none
            verticalAlignment: Text.AlignTop
            wrapMode: Text.WordWrap
        }

        ListItemLabel {
            color: app.styler.themeHighlightColor
            height: text ? implicitHeight + app.styler.themePaddingMedium: 0
            text: poi.postcode ? app.tr("Postal code: %1", poi.postcode) : ""
            truncMode: truncModes.none
            verticalAlignment: Text.AlignTop
            wrapMode: Text.WordWrap
        }

        Spacer {
            height: app.styler.themePaddingMedium
        }

        SectionHeaderPL {
            height: implicitHeight + app.styler.themePaddingMedium
            text: app.tr("Actions")
        }

        IconListItem {
            enabled: hasCoordinate
            icon: app.styler.iconShare
            label: app.tr("Share location")
            onClicked: {
                app.push("SharePage.qml", {
                             "coordinate": poi.coordinate,
                             "title": poi.title,
                         });
            }
        }

        IconListItem {
            enabled: hasCoordinate
            icon: app.styler.iconDot
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
            icon: app.styler.iconNavigate
            label: app.tr("Navigate To")
            onClicked: {
                app.showMenu("RoutePage.qml", {
                                 "to": [poi.coordinate.longitude, poi.coordinate.latitude],
                                 "toText": poi.title,
                             });
            }
        }

        IconListItem {
            enabled: hasCoordinate
            icon: app.styler.iconNavigate
            label: app.tr("Navigate From")
            onClicked: {
                app.showMenu("RoutePage.qml", {
                                 "from": [poi.coordinate.longitude, poi.coordinate.latitude],
                                 "fromText": poi.title,
                             });
            }
        }

        IconListItem {
            enabled: hasCoordinate
            icon: app.styler.iconNearby
            label: app.tr("Nearby")
            onClicked: {
                app.showMenu("NearbyPage.qml", {
                                 "near": [poi.coordinate.longitude, poi.coordinate.latitude],
                                 "nearText": poi.title,
                             });
            }
        }

        SectionHeaderPL {
            height: text ? implicitHeight + app.styler.themePaddingMedium : 0
            text: poi.phone || poi.link ? app.tr("Contact") : ""
        }

        Item {
            // phone number is usually short and does not fill the whole line
            // since the rest of the line can be used for dragging the panel,
            // this arrangement minimizes the area used to show the phone
            anchors.left: parent.left
            anchors.leftMargin: app.styler.themeHorizontalPageMargin
            height: poi.phone ? Math.max(phoneIcon.height, phoneText.height) + app.styler.themePaddingMedium : 0
            width: phoneIcon.width + phoneText.width + app.styler.themePaddingMedium

            Image {
                id: phoneIcon
                anchors.left: parent.left
                anchors.top: parent.top
                fillMode: Image.Pad
                height: poi.phone ? implicitHeight : 0
                source: poi.phone ? app.styler.iconPhone : ""
            }

            LabelPL {
                id: phoneText
                anchors.left: phoneIcon.right
                anchors.leftMargin: app.styler.themePaddingMedium
                anchors.verticalCenter: phoneIcon.verticalCenter
                text: poi.phone
                truncMode: truncModes.fade
                width: Math.min(implicitWidth, poi.width-phoneIcon.width-2*app.styler.themeHorizontalPageMargin-app.styler.themePaddingMedium)
            }

            MouseArea {
                anchors.fill: parent
                onClicked: Qt.openUrlExternally("tel:" + poi.phone)
            }
        }

        IconListItem {
            height: poi.link ? implicitHeight + app.styler.themePaddingLarge : 0
            icon: poi.link ? app.styler.iconWebLink : ""
            label: poi.link
            MouseArea {
                anchors.fill: parent
                onClicked: Qt.openUrlExternally(poi.link)
            }
        }

        SectionHeaderPL {
            height: text ? implicitHeight + app.styler.themePaddingMedium : 0
            text: poi.text ? app.tr("Additional info") : ""
        }

        ListItemLabel {
            color: app.styler.themeHighlightColor
            height: text ? implicitHeight + app.styler.themePaddingMedium: 0
            text: poi.text
            truncMode: truncModes.none
            verticalAlignment: Text.AlignTop
            wrapMode: Text.WordWrap
        }
    }

    Component.onCompleted: {
        if (!poi.coordinate)
            poi.coordinate = QtPositioning.coordinate(poi.y, poi.x);
    }

}
