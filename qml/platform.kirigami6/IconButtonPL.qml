/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2018-2026 Rinigus
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
import org.kde.kirigami as Kirigami

RoundButton {
    id: item

    background: Rectangle {
        color: item.down ? styler.themePrimaryColor : "transparent"
        opacity: 0.2
        radius: width / 2
    }
    display: AbstractButton.IconOnly
    flat: true
    height: Math.max(iconHeight, iconWidth) * (1 + padding)
    padding: 0.5
    opacity: iconOpacity
    //rotation: iconRotation
    width: height

    readonly property real _iconHeight: iconHeight > 0 ? iconHeight : iconWidth
    readonly property real _iconWidth: iconWidth > 0 ? iconWidth : iconHeight

    contentItem: Item {
        implicitHeight: item._iconHeight
        implicitWidth: item._iconWidth

        Image {
            anchors.centerIn: parent
            height: item._iconHeight
            rotation: item.iconRotation
            smooth: true
            source: item.iconColorize ? "" : item.iconSource
            sourceSize.height: item._iconHeight
            sourceSize.width: item._iconWidth
            visible: !item.iconColorize && item.iconSource
            width: item._iconWidth
        }

        Kirigami.Icon {
            anchors.centerIn: parent
            color: styler.themeHighlightColor
            height: item._iconHeight
            rotation: item.iconRotation
            source: item.iconName || item.iconSource
            visible: item.iconColorize || !item.iconSource
            width: item._iconWidth
        }
    }

    icon {
        color: iconColorize ? styler.themeHighlightColor : "transparent"
        height: iconHeight
        name: iconName
        source: iconSource
        width: iconWidth
    }

    property bool   iconColorize: true
    property int    iconHeight: 0
    property var    iconName
    property real   iconOpacity: 1.0
    property real   iconRotation
    property var    iconSource
    property int    iconWidth: 0
}
