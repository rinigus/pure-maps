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
    height: childrenRect.height

    property alias placeholderText: field.placeholderText
    property alias text: field.text
    property real  textLeftMargin: row.x + field.x

    signal search

    Image {
        id: searchImage
        anchors.left: parent.left
        anchors.leftMargin: app.styler.themeHorizontalPageMargin
        anchors.verticalCenter: field.verticalCenter
        fillMode: Image.PreserveAspectFit
        source: app.styler.iconSearch
        sourceSize.height: field.height * 0.8
    }

    TextField {
        id: field
        anchors.left: searchImage.right
        anchors.leftMargin: app.styler.themePaddingMedium
        anchors.right: clearButton.left
        anchors.rightMargin: app.styler.themePaddingMedium
        focus: true
        width: parent.width
        Keys.onReturnPressed: row.search()
    }

    IconButtonPL {
        id: clearButton
        anchors.right: parent.right
        anchors.rightMargin: app.styler.themeHorizontalPageMargin
        anchors.verticalCenter: field.verticalCenter
        icon.source: app.styler.iconDelete
        icon.sourceSize.height: field.height * 0.8
        onClicked: field.text = ""
    }
}
