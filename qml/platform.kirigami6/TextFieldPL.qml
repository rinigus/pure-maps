/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2026 Rinigus
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

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import pm.platform 1.0

Item {
    id: row

    Kirigami.FormData.buddyFor: entry
    Kirigami.FormData.label: label
    Layout.fillWidth: true
    Layout.preferredWidth: parent.width
    implicitHeight: childrenRect.height
    width: parent.isFormLayout ? undefined : parent.width

    property alias  acceptableInput: entry.acceptableInput
    property alias  description: desc.text
    property bool   inForm: parent.isFormLayout ? true : false
    property alias  inputMethodHints: entry.inputMethodHints
    property string label
    property alias  placeholderText: entry.placeholderText
    property alias  text: entry.text
    property alias  validator: entry.validator

    signal enter

    Label {
        id: lab

        anchors.baseline: entry.baseline
        anchors.left: parent.left
        anchors.leftMargin: styler.themeHorizontalPageMargin
        height: inForm ? 0 : implicitHeight
        text: !inForm ? label : ""
        visible: text
        width: inForm ? 0 : implicitWidth
    }

    TextField {
        id: entry

        anchors.left: inForm ? undefined : lab.right
        anchors.leftMargin: styler.themePaddingMedium
        anchors.right: inForm ? undefined : parent.right
        anchors.rightMargin: styler.themeHorizontalPageMargin
        rightPadding: clearButton.width + clearButton.anchors.leftMargin + styler.themePaddingMedium
        width: parent.width

        Keys.onReturnPressed: row.enter()

        IconButtonPL {
            id: clearButton

            anchors.right: parent.right
            anchors.rightMargin: styler.themePaddingMedium
            anchors.verticalCenter: parent.verticalCenter
            iconHeight: styler.themeFontSizeMedium
            iconName: styler.iconEditClear
            visible: parent.text && entry.activeFocus

            onClicked: parent.text = ""
        }
    }

    Label {
        id: desc

        anchors.left: entry.left
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
}
