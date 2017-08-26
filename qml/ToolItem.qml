/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2017 Osmo Salomaa
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

BackgroundItem {
    id: item
    height: image.height + label.height
    width: image.width

    property string icon: ""
    property string text: ""

    Image {
        id: image
        fillMode: Image.Pad
        height: sourceSize.height + Theme.paddingLarge + Theme.paddingMedium
        source: item.icon
        width: item.width
    }

    Label {
        id: label
        anchors.left: parent.left
        anchors.leftMargin: Theme.paddingSmall
        anchors.right: parent.right
        anchors.rightMargin: Theme.paddingSmall
        anchors.top: image.bottom
        color: item.highlighted ? Theme.highlightColor : Theme.primaryColor
        height: implicitHeight + Theme.paddingLarge
        horizontalAlignment: Text.AlignHCenter
        text: item.text
        wrapMode: Text.WordWrap
    }

}
