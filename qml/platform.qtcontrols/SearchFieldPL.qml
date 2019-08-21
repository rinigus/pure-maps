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

TextField {
    id: field
    anchors.left: parent.left
    anchors.leftMargin: styler.themeHorizontalPageMargin
    anchors.right: parent.right
    anchors.rightMargin: styler.themeHorizontalPageMargin
    inputMethodHints: Qt.ImhNoPredictiveText
    focus: true
    leftPadding: searchButton.width + searchButton.anchors.leftMargin + styler.themePaddingMedium
    rightPadding: clearButton.width + clearButton.anchors.leftMargin + styler.themePaddingMedium
    Keys.onReturnPressed: field.search()

    property real  textLeftMargin: field.x + leftPadding

    signal search

    IconButtonPL {
        id: searchButton
        anchors.left: parent.left
        anchors.leftMargin: styler.themePaddingMedium
        anchors.verticalCenter: field.verticalCenter
        iconName: styler.iconSearch
        iconHeight: styler.themeFontSizeMedium
        onClicked: field.search()
    }

    IconButtonPL {
        id: clearButton
        anchors.right: parent.right
        anchors.rightMargin: styler.themePaddingMedium
        anchors.verticalCenter: field.verticalCenter
        iconName: styler.iconEditClear
        iconHeight: styler.themeFontSizeMedium
        visible: field.text
        onClicked: field.text = ""
    }
}
