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

Item {
    id: row

    height: childrenRect.height

    property alias inputMethodHints: entry.inputMethodHints
    property alias label: lab.text
    property alias placeholderText: entry.placeholderText
    property alias text: entry.text

    signal enter

    Label {
        id: lab
        anchors.left: parent.left
        anchors.leftMargin: app.styler.themeHorizontalPageMargin
        anchors.baseline: entry.baseline
    }

    TextField {
        id: entry
        anchors.left: lab.right
        anchors.leftMargin: app.styler.themePaddingMedium
        anchors.right: parent.right
        anchors.rightMargin: app.styler.themeHorizontalPageMargin
        Keys.onReturnPressed: row.enter()
    }
}
