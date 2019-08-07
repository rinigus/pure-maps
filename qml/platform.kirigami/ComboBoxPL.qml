/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2018 Rinigus, 2019 Purism SPC
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
    anchors.left: inForm ? undefined : parent.left
    anchors.leftMargin: inForm ? undefined : styler.themeHorizontalPageMargin
    anchors.right: inForm ? undefined : parent.right
    anchors.rightMargin: inForm ? undefined : styler.themeHorizontalPageMargin
    implicitHeight: (inForm ? val.height : Math.max(lab.height, val.height)) + desc.height + desc.anchors.topMargin
    Kirigami.FormData.buddyFor: val
    Kirigami.FormData.label: label
    Layout.fillWidth: true
    Layout.preferredWidth: parent.width

    property int    currentIndex
    property alias  description: desc.text
    property bool   inForm: parent.isFormLayout ? true : false
    property alias  model: val.model
    property string label
    property alias  value: val.currentText

    Label {
        id: lab
        anchors.verticalCenter: val.verticalCenter
        anchors.left: parent.left
        height: inForm ? 0 : implicitHeight
        width: inForm ? 0 : implicitWidth
        text: !inForm ? label : ""
        visible: text
    }

    ComboBox {
        id: val
        anchors.left: inForm ? parent.left : lab.right
        anchors.leftMargin: styler.themePaddingMedium
        anchors.right: parent.right
        anchors.rightMargin: styler.themePaddingMedium
        anchors.top: parent.top
        font.pixelSize: styler.themeFontSizeMedium
        property bool initialized: false
        onCurrentIndexChanged: {
            if (initialized && currentIndex != item.currentIndex)
                item.currentIndex = currentIndex;
        }
        Component.onCompleted: {
            currentIndex = item.currentIndex;
            initialized = true;
        }
    }

    Label {
        id: desc
        anchors.left: val.left
        anchors.right: parent.right
        anchors.top: val.bottom
        anchors.topMargin: text ? styler.themePaddingSmall : 0
        font.pixelSize: styler.themeFontSizeSmall
        height: text ? implicitHeight : 0
        visible: text
        wrapMode: Text.WordWrap
    }

    function activate() {
        // pass
    }
}
