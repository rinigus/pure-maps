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

import QtQuick 2.0
import Ubuntu.Components 1.3

Icon {
    id: image
    height: iconHeight ? iconHeight : undefined
    source: iconName ? iconName : iconSource
    width: iconWidth ? iconWidth : undefined

    property var    fillMode // unused, kept for compatibility
    property bool   iconColorize: true
    property int    iconHeight: 0
    property string iconName
    property string iconSource
    property int    iconWidth: 0

    Component.onCompleted: {
        if (iconColorize) color = styler.themeHighlightColor;
    }
}
