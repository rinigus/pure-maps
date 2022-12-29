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
import Lomiri.Components 1.3 as UC

Item {
    id: row

    height: childrenRect.height
    width: parent.width

    property alias acceptableInput: entry.acceptableInput
    property alias description: desc.text
    property alias inputMethodHints: entry.inputMethodHints
    property alias label: lab.text
    property alias placeholderText: entry.placeholderText
    property string text
    property alias validator: entry.validator

    property bool  _ignoreTextUpdate: false

    signal enter

    Label {
        id: lab
        anchors.left: parent.left
        anchors.leftMargin: styler.themeHorizontalPageMargin
        anchors.verticalCenter: entry.verticalCenter
    }

    UC.TextField {
        id: entry
        anchors.left: lab.right
        anchors.leftMargin: styler.themePaddingMedium
        anchors.right: parent.right
        anchors.rightMargin: styler.themeHorizontalPageMargin
        Keys.onReturnPressed: row.enter()

        onDisplayTextChanged: {
            _ignoreTextUpdate = true;
            row.text = displayText;
            _ignoreTextUpdate = false;
        }
    }

    Label {
        id: desc
        anchors.left: lab.right
        anchors.leftMargin: styler.themePaddingMedium
        anchors.right: parent.right
        anchors.rightMargin: styler.themeHorizontalPageMargin
        anchors.top: entry.bottom
        anchors.topMargin: text ? styler.themePaddingSmall : 0
        font.pixelSize: styler.themeFontSizeSmall
        height: text ? implicitHeight : 0
        visible: text
        wrapMode: Text.WordWrap
    }

    Component.onCompleted: entry.text = row.text

    onTextChanged: {
        if (_ignoreTextUpdate) return;
        entry.text = row.text
    }
}
