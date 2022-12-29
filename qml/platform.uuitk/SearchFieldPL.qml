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
import Lomiri.Components 1.3
import "."

TextField {
    id: field
    anchors.left: parent.left
    anchors.leftMargin: styler.themeHorizontalPageMargin
    anchors.right: parent.right
    anchors.rightMargin: styler.themeHorizontalPageMargin
    inputMethodHints: Qt.ImhNoPredictiveText
    focus: true
    Keys.onReturnPressed: field.search()

    property real  textLeftMargin: field.x + leftPadding

    signal search

    primaryItem: IconButtonPL {
        id: searchButton
        iconName: styler.iconSearch
        iconHeight: styler.themeFontSizeMedium
        onClicked: field.search()
    }

    secondaryItem: IconButtonPL {
        id: clearButton
        iconHeight: styler.themeFontSizeMedium
        visible: field.text
        onClicked: field.text = ""
    }
}
