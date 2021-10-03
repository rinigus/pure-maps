/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2019 Rinigus, 2019 Purism SPC
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
import QtGraphicalEffects 1.0
import "platform"

Item {
    id: item
    height: bg.height + 2*styler.themePaddingLarge
    width: bg.width + 2*styler.themePaddingLarge

    property alias  enabled: mouse.enabled
    property alias  iconColorize: button.iconColorize
    property alias  iconHeight: button.iconHeight
    property alias  iconName: button.iconName
    property alias  iconRotation: button.iconRotation
    property alias  iconSource: button.iconSource
    property alias  iconWidth: button.iconWidth
    property bool   indicator: false
    property alias  pressed: mouse.pressed

    signal clicked

    Rectangle {
        id: bg
        anchors.centerIn: parent
        color: item.pressed ? styler.itemPressed : styler.itemBg
        height: wh
        layer.enabled: true
        layer.effect: DropShadow {
            color: item.pressed ? "transparent" : styler.shadowColor
            opacity: styler.shadowOpacity
            radius: styler.shadowRadius
            samples: 1 + radius*2
        }
        opacity: item.enabled ? 1.0 : 0.75
        radius: wh/2
        width: wh

        property real wh: Math.max(button.height, button.width) * 1.4142*(1 + 0.2)

        IconButtonPL {
            id: button
            anchors.centerIn: parent
            iconColorize: false
            padding: 0
            onClicked: item.clicked()
        }

        Image {
            height: sourceSize.height
            smooth: true
            source: app.getIcon("icons/indicator", true)
            sourceSize.height: styler.indicatorSize
            sourceSize.width: styler.indicatorSize
            visible: item.indicator
            width: sourceSize.width
            x: bg.width/2 + bg.wh/2*0.70711 - width/2
            y: bg.width/2 - bg.wh/2*0.70711 - height/2
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        onClicked: item.clicked()
    }
}
