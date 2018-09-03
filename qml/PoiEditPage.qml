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

Dialog {
    id: page
    allowedOrientations: app.defaultAllowedOrientations

    property var  poi

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge

        Column {
            id: column
            width: parent.width

            DialogHeader {
                acceptText: app.tr("Save")
                title: app.tr("Edit POI")
            }

            SectionHeader {
                text: app.tr("General")
            }

            TextField {
                id: titleField
                focus: true
                label: app.tr("Title")
                placeholderText: app.tr("Enter title")
                text: poi.title ? poi.title : ""
                width: parent.width
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: typeField.focus = true
            }

            TextField {
                id: typeField
                label: app.tr("Type")
                placeholderText: app.tr("Enter type, such as Restaurant")
                text: poi.poiType ? poi.poiType : ""
                width: parent.width
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: addressField.focus = true
            }

            SectionHeader {
                text: app.tr("Address")
            }

            TextField {
                id: addressField
                label: app.tr("Address")
                placeholderText: app.tr("Enter address")
                text: poi.address ? poi.address : ""
                width: parent.width
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: postcodeField.focus = true
            }

            TextField {
                id: postcodeField
                label: app.tr("Postal code")
                placeholderText: app.tr("Enter postal code")
                text: poi.postcode ? poi.postcode : ""
                width: parent.width
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: phoneField.focus = true
            }

            SectionHeader {
                text: app.tr("Contact")
            }

            TextField {
                id: phoneField
                color: Theme.highlightColor
                inputMethodHints: Qt.ImhDialableCharactersOnly
                label: app.tr("Phone number")
                placeholderText: app.tr("Enter phone number")
                text: poi.phone ? poi.phone : ""
                width: parent.width
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: focus = false
            }

            TextField {
                id: linkField
                label: app.tr("URL")
                placeholderText: app.tr("Enter URL")
                text: poi.link ? poi.link : ""
                width: parent.width
                EnterKey.iconSource: "image://theme/icon-m-enter-next"
                EnterKey.onClicked: textArea.focus = true
            }

            SectionHeader {
                text: app.tr("Additional info")
            }

            TextArea {
                id: textArea
                label: app.tr("Additional info")
                placeholderText: app.tr("Enter additional info")
                text: poi.text ? poi.text : ""
                width: parent.width
            }
        }

        VerticalScrollDecorator {}

    }

    onAccepted: {
        poi.address = addressField.text;
        poi.link = linkField.text;
        poi.phone = phoneField.text;
        poi.poiType = typeField.text;
        poi.postcode = postcodeField.text;
        poi.text = textArea.text;
        poi.title = titleField.text;
    }

}
