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
    height: val.height +
            styler.themeFontSizeLarge + styler.themePaddingSmall +
            desc.height + desc.anchors.topMargin

    property alias description: desc.text
    property alias label: lab.text
    property alias maximumValue: val.to
    property alias minimumValue: val.from
    property alias stepSize: val.stepSize
    property alias value: val.value
    property real  valueText
    property int   valueTextDecimalPlaces: stepSize > 1 ? 0 : Math.round( Math.log(1.0 / stepSize) / Math.LN10 )

    Label {
        id: lab
        anchors.left: parent.left
        anchors.leftMargin: styler.themeHorizontalPageMargin
        anchors.verticalCenter: val.verticalCenter
    }

    Slider {
        id: val
        anchors.left: lab.right
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
        anchors.left: lab.right
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
