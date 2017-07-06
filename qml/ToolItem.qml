/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2016 Osmo Salomaa
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
import "."

ListItem {
    id: item
    contentHeight: Theme.itemSizeSmall
    width: parent.width / parent.count

    property string text: ""

    Rectangle {
        anchors.fill: parent
        color: Theme.highlightColor
        opacity: 0.1
    }

    ListItemLabel {
        anchors.fill: parent
        anchors.leftMargin: Theme.paddingMedium
        anchors.rightMargin: Theme.paddingMedium
        color: item.highlighted ? Theme.highlightColor : Theme.primaryColor
        height: Theme.itemSizeSmall
        horizontalAlignment: Text.AlignHCenter
        text: item.text
    }

}
