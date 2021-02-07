/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2021 Rinigus
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
import "platform"

ListItemPL {
    id: item
    contentHeight: styler.themeItemSizeSmall
    width: parent.width

    property alias label: lab.text
    property alias labelX: lab.x
    property alias labelImplicitWidth: lab.implicitWidth

    LabelPL {
        id: lab
        anchors.verticalCenter: parent.verticalCenter
        color: {
            if (!item.enabled) return styler.themeSecondaryHighlightColor;
            if (item.highlighted) return styler.themeHighlightColor;
            return styler.themePrimaryColor;
        }
    }
}
