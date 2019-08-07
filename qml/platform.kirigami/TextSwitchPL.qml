/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2018-2019 Rinigus, 2019 Purism SPC
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
    id: item
    implicitHeight: sw.height + desc.height + desc.anchors.topMargin
    width: parent.width
    Layout.fillWidth: true
    Layout.preferredWidth: parent.width

    property alias  checked: sw.checked
    property alias  description: desc.text
    property bool   inForm: parent.isFormLayout ? true : false
    property string text

    property real leftMargin // ignoring this property

    Switch {
        id: sw
        anchors.left: parent.left
        anchors.leftMargin: !inForm ? styler.themeHorizontalPageMargin : undefined
        anchors.right: parent.right
        anchors.rightMargin: !inForm ? styler.themeHorizontalPageMargin : undefined
        anchors.top: parent.top
        font.pixelSize: styler.themeFontSizeMedium
        text: item.text
    }

    Label {
        id: desc
        anchors.left: parent.left
        anchors.leftMargin: styler.themeHorizontalPageMargin
        anchors.right: parent.right
        anchors.rightMargin: styler.themeHorizontalPageMargin
        anchors.top: sw.bottom
        anchors.topMargin: text ? styler.themePaddingSmall : 0
        font.pixelSize: styler.themeFontSizeSmall
        height: text ? implicitHeight : 0
        visible: text
        wrapMode: Text.WordWrap
    }
}
