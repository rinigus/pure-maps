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

import QtQuick 2.11
import QtQuick.Controls 2.4
// for IconImage, see https://bugreports.qt.io/browse/QTBUG-66829
import QtQuick.Controls.impl 2.4

Item {
    id: item
    height: (iconName ? iconimage.height : image.height)*(1 + padding)
    width: (iconName ? iconimage.width : image.width)*(1 + padding)

    property bool   iconColorize: true
    property int    iconHeight: 0
    property alias  iconName: iconimage.name
    property real   iconOpacity: 1.0
    property real   iconRotation
    property alias  iconSource: image.source
    property int    iconWidth: 0
    property real   padding: 0.5
    property alias  pressed: mouse.pressed

    signal clicked

    IconImage {
        id: iconimage
        anchors.centerIn: parent
        color: iconColorize ? styler.themeHighlightColor : "transparent"
        opacity: iconOpacity
        rotation: iconRotation
        smooth: false
        sourceSize.height: iconHeight
        sourceSize.width: iconWidth
        visible: name
    }

    Image {
        id: image
        anchors.centerIn: parent
        fillMode: Image.PreserveAspectFit
        opacity: iconOpacity
        rotation: iconRotation
        sourceSize.height: iconHeight
        sourceSize.width: iconWidth
        visible: source && !iconName
    }

    Rectangle {
        anchors.fill: parent
        color: mouse.pressed ? styler.themePrimaryColor : "transparent"
        opacity: 0.2
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        onClicked: item.clicked()
    }
}
