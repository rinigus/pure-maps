/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2017 Osmo Salomaa, 2018 Rinigus
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

BackgroundItem {
    id: item
    height: image.height + label.height + 2*styler.themePaddingLarge

    property alias icon: image
    property alias text: label.text

    IconPL {
        id: image
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: styler.themePaddingLarge
        fillMode: Image.PreserveAspectFit
    }

    Label {
        id: label
        anchors.left: parent.left
        anchors.leftMargin: styler.themePaddingLarge
        anchors.right: parent.right
        anchors.rightMargin: styler.themePaddingLarge
        anchors.top: image.bottom
        anchors.topMargin: styler.themePaddingMedium
        color: item.highlighted ? styler.themeHighlightColor : styler.themePrimaryColor
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
    }

}
