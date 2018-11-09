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

    property alias description: desc.text
    property alias label: lab.text
    property alias value: val.text

    signal clicked

    Label {
        id: lab
        anchors.verticalCenter: val.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: app.styler.themeHorizontalPageMargin
    }

    ItemDelegate {
        id: val
        anchors.left: lab.right
        anchors.leftMargin: app.styler.themePaddingMedium
        anchors.right: parent.right
        anchors.top: parent.top
        font.pixelSize: app.styler.themeFontSizeMedium
        onClicked: row.clicked()
    }

    Label {
        id: desc
        anchors.left: lab.right
        anchors.top: val.bottom
        anchors.topMargin: app.styler.themePaddingSmall
        anchors.right: parent.right
        anchors.rightMargin: app.styler.themeHorizontalPageMargin
        font.pixelSize: app.styler.themeFontSizeSmall
        visible: text
        wrapMode: Text.WordWrap
    }
}
