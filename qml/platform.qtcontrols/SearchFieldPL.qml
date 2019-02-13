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

import QtQuick 2.9
import QtQuick.Controls 2.2
import "."

FocusScope {
    id: row
    height: field.height

    property alias placeholderText: field.placeholderText
    property alias text: field.text
    property real  textLeftMargin: row.x + field.x

    signal search

    SystemPalette {
        id: palette
        colorGroup: SystemPalette.Active
    }

    Rectangle {
        anchors.left: parent.left
        anchors.leftMargin: app.styler.themeHorizontalPageMargin
        anchors.right: parent.right
        anchors.rightMargin: app.styler.themeHorizontalPageMargin
        color: palette.base
        border.color: field.activeFocus ? palette.highlight : palette.midlight
        border.width: field.activeFocus ? 2 : 1
        height: 2*2 + field.height

        IconPL {
            id: searchImage
            anchors.left: parent.left
            anchors.leftMargin: app.styler.themePaddingMedium
            anchors.verticalCenter: field.verticalCenter
            iconName: app.styler.iconSearch
            iconHeight: app.style.themeFontSizeMedium //field.height * 0.7
        }

        TextField {
            id: field
            anchors.left: searchImage.right
            anchors.leftMargin: app.styler.themePaddingSmall
            anchors.right: clearButton.left
            anchors.rightMargin: app.styler.themePaddingSmall
            anchors.verticalCenter: parent.verticalCenter
            background: Rectangle {
                color: palette.base
                border.color: "transparent"
            }
            focus: true
            width: parent.width
            Keys.onReturnPressed: row.search()
        }

        IconButtonPL {
            id: clearButton
            anchors.right: parent.right
            anchors.rightMargin: app.styler.themePaddingMedium
            anchors.verticalCenter: field.verticalCenter
            iconName: app.styler.iconEditClear
            iconHeight: app.style.themeFontSizeMedium //field.height * 0.7
            visible: field.text
            onClicked: field.text = ""
        }
    }
}
