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
import Sailfish.Silica 1.0
import "."

Page {
    id: page
    allowedOrientations: app.defaultAllowedOrientations

    property var poi

    SilicaFlickable {

        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge

        Column {
            id: column
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width

            PageHeader {
                title: poi.title || app.tr("Unnamed point")
            }

            ListItemLabel {
                color: Theme.highlightColor
                height: text ? implicitHeight + Theme.paddingMedium: 0
                text: poi.poiType ? poi.poiType : ""
                truncationMode: TruncationMode.None
                verticalAlignment: Text.AlignTop
                wrapMode: Text.WordWrap
            }

            ListItemLabel {
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeSmall
                height: text ? implicitHeight + Theme.paddingMedium: 0
                text: poi.coordinate ? app.tr("Latitude: %1", poi.coordinate.latitude) + "\n" + app.tr("Longitude: %2", poi.coordinate.longitude) : ""
                truncationMode: TruncationMode.None
                verticalAlignment: Text.AlignTop
                wrapMode: Text.WordWrap
            }

            SectionHeader {
                height: text ? implicitHeight + Theme.paddingMedium : 0
                text: poi.address || poi.postcode ? app.tr("Address") : ""
            }

            ListItemLabel {
                color: Theme.highlightColor
                height: text ? implicitHeight + Theme.paddingMedium: 0
                text: poi.address ? poi.address : ""
                truncationMode: TruncationMode.None
                verticalAlignment: Text.AlignTop
                wrapMode: Text.WordWrap
            }

            ListItemLabel {
                color: Theme.highlightColor
                height: text ? implicitHeight + Theme.paddingMedium: 0
                text: poi.postcode ? app.tr("Postal code: %1", poi.postcode) : ""
                truncationMode: TruncationMode.None
                verticalAlignment: Text.AlignTop
                wrapMode: Text.WordWrap
            }

            SectionHeader {
                height: text ? implicitHeight + Theme.paddingMedium : 0
                text: poi.phone || poi.link ? app.tr("Contact") : ""
            }

            Item {
                // phone number is usually short and does not fill the whole line
                // since the rest of the line can be used for dragging the panel,
                // this arrangement minimizes the area used to show the phone
                anchors.left: parent.left
                anchors.leftMargin: Theme.horizontalPageMargin
                height: poi.phone ? Math.max(phoneIcon.height, phoneText.height) + Theme.paddingMedium : 0
                width: phoneIcon.width + phoneText.width + Theme.paddingMedium

                Image {
                    id: phoneIcon
                    anchors.left: parent.left
                    anchors.top: parent.top
                    fillMode: Image.Pad
                    height: poi.phone ? implicitHeight : 0
                    source: poi.phone ? "image://theme/icon-m-phone" : ""
                }

                Label {
                    id: phoneText
                    anchors.left: phoneIcon.right
                    anchors.leftMargin: Theme.paddingMedium
                    anchors.verticalCenter: phoneIcon.verticalCenter
                    text: poi.phone
                    truncationMode: TruncationMode.Fade
                    width: Math.min(implicitWidth, poi.width-phoneIcon.width-2*Theme.horizontalPageMargin-Theme.paddingMedium)
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: Qt.openUrlExternally("tel:" + poi.phone)
                }
            }

            IconListItem {
                height: poi.link ? implicitHeight + Theme.paddingLarge : 0
                icon: poi.link ? "image://theme/icon-m-link" : ""
                label: poi.link
                MouseArea {
                    anchors.fill: parent
                    onClicked: Qt.openUrlExternally(poi.link)
                }
            }

            SectionHeader {
                height: text ? implicitHeight + Theme.paddingMedium : 0
                text: poi.text ? app.tr("Additional info") : ""
            }

            ListItemLabel {
                color: Theme.highlightColor
                height: text ? implicitHeight + Theme.paddingMedium: 0
                text: poi.text
                textFormat: Text.StyledText
                truncationMode: TruncationMode.None
                verticalAlignment: Text.AlignTop
                wrapMode: Text.WordWrap
            }
        }

        VerticalScrollDecorator {}

    }

    Component.onCompleted: {
        if (!poi.coordinate)
            poi.coordinate = QtPositioning.coordinate(poi.y, poi.x);
    }

}
