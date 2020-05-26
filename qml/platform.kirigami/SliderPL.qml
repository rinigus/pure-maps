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
    implicitHeight: val.height +
                    styler.themeFontSizeLarge + styler.themePaddingSmall +
                    desc.height + desc.anchors.topMargin
    Kirigami.FormData.buddyFor: val
    Kirigami.FormData.label: label
    Layout.fillWidth: true
    Layout.preferredWidth: parent.width

    property alias  description: desc.text
    property bool   inForm: parent.isFormLayout ? true : false
    property string label
    property alias  maximumValue: val.to
    property alias  minimumValue: val.from
    property alias  stepSize: val.stepSize
    property alias  value: val.value
    property real   valueText
    property int    valueTextDecimalPlaces: stepSize > 1 ? 0 : Math.round( Math.log(1.0 / stepSize) / Math.LN10 )

    Label {
        id: lab
        anchors.left: parent.left
        anchors.leftMargin: styler.themeHorizontalPageMargin
        anchors.verticalCenter: val.verticalCenter
        height: inForm ? 0 : implicitHeight
        width: inForm ? 0 : implicitWidth
        text: !inForm ? label : ""
        visible: text
    }

    Slider {
        id: val
        anchors.left: inForm ? parent.left : lab.right
        anchors.leftMargin: styler.themePaddingMedium
        anchors.right: parent.right
        anchors.rightMargin: styler.themeHorizontalPageMargin
        anchors.top: parent.top
        anchors.topMargin: styler.themeFontSizeSmall + styler.themePaddingMedium
    }

    Label {
        id: valTxt
        anchors.bottom: val.top
        anchors.bottomMargin: val.pressed ? styler.themePaddingSmall : 0
        x: val.x + val.handle.x + val.handle.width/2 - width/2
        text: valueText.toFixed(valueTextDecimalPlaces)
        font.pixelSize: val.pressed ? styler.themeFontSizeLarge : styler.themeFontSizeMedium
    }

    Label {
        id: desc
        anchors.left: val.left
        anchors.right: parent.right
        anchors.rightMargin: styler.themeHorizontalPageMargin
        anchors.top: val.bottom
        anchors.topMargin: text ? styler.themePaddingSmall : 0
        font.pixelSize: styler.themeFontSizeSmall
        height: text ? implicitHeight : 0
        visible: text
        wrapMode: Text.WordWrap
    }
}
