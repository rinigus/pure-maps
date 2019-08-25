/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2018-2019 Rinigus
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

import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    id: item
    height: image.height*(1 + padding)
    width: image.width*(1 + padding)

    property bool   iconColorize: true // for compatibility, not used
    property int    iconHeight: 0
    property string iconName
    property real   iconOpacity: 1.0
    property alias  iconRotation: image.rotation
    property string iconSource
    property int    iconWidth: 0
    property real   padding: 0.2

    signal clicked

    Image {
        id: image
        anchors.centerIn: parent
        source: iconName || iconSource
        sourceSize.height: iconHeight
        sourceSize.width: iconWidth
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
