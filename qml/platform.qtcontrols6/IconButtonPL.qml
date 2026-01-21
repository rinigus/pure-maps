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
