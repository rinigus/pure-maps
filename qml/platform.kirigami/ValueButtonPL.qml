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
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.4 as Kirigami

Item {
    id: row

    anchors.left: inForm ? undefined : parent.left
    anchors.right: inForm ? undefined : parent.right
    implicitHeight: childrenRect.height
    Kirigami.FormData.buddyFor: val
    Kirigami.FormData.label: label
    Layout.fillWidth: true
    Layout.preferredWidth: parent.width

    property alias  description: desc.text
    property bool   inForm: parent.isFormLayout ? true : false
    property string label
    property alias  value: val.text

    signal clicked

    ItemDelegate {
        id: val
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: Math.max(styler.themeItemSizeSmall, implicitHeight)
        font.pixelSize: styler.themeFontSizeMedium
        leftPadding: lab.width + lab.anchors.leftMargin + styler.themePaddingMedium
        onClicked: row.clicked()

        Label {
            id: lab
            anchors.left: parent.left
            anchors.leftMargin: inForm ? 0 : styler.themeHorizontalPageMargin
            anchors.verticalCenter: val.verticalCenter
            height: inForm ? 0 : implicitHeight
            width: inForm ? 0 : implicitWidth
            text: !inForm ? label : ""
            visible: text
        }
    }

    Label {
        id: desc
        anchors.left: parent.left
        anchors.leftMargin: lab.anchors.leftMargin + lab.width
        anchors.top: val.bottom
        anchors.topMargin: text ? styler.themePaddingSmall : 0
        anchors.right: parent.right
        anchors.rightMargin: styler.themeHorizontalPageMargin
        font.pixelSize: styler.themeFontSizeSmall
        height: text ? implicitHeight : 0
        visible: text
        wrapMode: Text.WordWrap
    }
}
