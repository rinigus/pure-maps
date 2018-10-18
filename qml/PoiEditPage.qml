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
import "."
import "platform"

DialogPL {
    id: page
    title: app.tr("Edit POI")

    acceptText: app.tr("Save")

    property var poi

    Column {
        id: column
        spacing: app.styler.themePaddingMedium
        width: page.width

        SectionHeaderPL {
            text: app.tr("General")
        }

        TextFieldPL {
            id: titleField
            focus: true
            label: app.tr("Title")
            placeholderText: app.tr("Enter title")
            text: poi.title ? poi.title : ""
            width: parent.width
            onEnter: typeField.focus = true
        }

        TextFieldPL {
            id: typeField
            label: app.tr("Type")
            placeholderText: app.tr("Enter type, such as Restaurant")
            text: poi.poiType ? poi.poiType : ""
            width: parent.width
            onEnter: addressField.focus = true
        }

        Spacer {
            height: app.styler.themePaddingMedium
        }

        SectionHeaderPL {
            text: app.tr("Address")
        }

        TextFieldPL {
            id: addressField
            label: app.tr("Address")
            placeholderText: app.tr("Enter address")
            text: poi.address ? poi.address : ""
            width: parent.width
            onEnter: postcodeField.focus = true
        }

        TextFieldPL {
            id: postcodeField
            label: app.tr("Postal code")
            placeholderText: app.tr("Enter postal code")
            text: poi.postcode ? poi.postcode : ""
            width: parent.width
            onEnter: phoneField.focus = true
        }

        Spacer {
            height: app.styler.themePaddingMedium
        }

        SectionHeaderPL {
            text: app.tr("Contact")
        }

        TextFieldPL {
            id: phoneField
            inputMethodHints: Qt.ImhDialableCharactersOnly
            label: app.tr("Phone number")
            placeholderText: app.tr("Enter phone number")
            text: poi.phone ? poi.phone : ""
            width: parent.width
            onEnter: focus = false
        }

        TextFieldPL {
            id: linkField
            label: app.tr("URL")
            placeholderText: app.tr("Enter URL")
            text: poi.link ? poi.link : ""
            width: parent.width
            onEnter: textArea.focus = true
        }

        Spacer {
            height: app.styler.themePaddingMedium
        }

        SectionHeaderPL {
            text: app.tr("Additional info")
        }

        TextAreaPL {
            id: textArea
            placeholderText: app.tr("Enter additional info")
            text: poi.text ? poi.text : ""
        }

        function accepted() {
            poi.address = addressField.text;
            poi.link = linkField.text;
            poi.phone = phoneField.text;
            poi.poiType = typeField.text;
            poi.postcode = postcodeField.text;
            poi.text = textArea.text;
            poi.title = titleField.text;
        }
    }

    onAccepted: column.accepted()
}
