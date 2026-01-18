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

import QtQuick 2.11
import QtQuick.Controls 2.4
// for IconImage, see https://bugreports.qt.io/browse/QTBUG-66829
import QtQuick.Controls.impl 2.4

IconImage {
    id: image

    color: iconColorize ? styler.themeHighlightColor : "transparent"
    name: iconName
    source: iconSource
    sourceSize.height: iconHeight
    sourceSize.width: iconWidth

    property bool   iconColorize: true
    property int    iconHeight: 0
    property string iconName
    property string iconSource
    property int    iconWidth: 0
}
