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
import "platform"

ListItemPL {
    id: item
    anchors.left: parent.left
    anchors.right: parent.right
    contentHeight: app.styler.themeItemSizeSmall

    property string icon: ""
    property string label: ""

    Image {
        id: icon
        anchors.left: parent.left
        anchors.leftMargin: app.styler.themeHorizontalPageMargin
        fillMode: Image.Pad
        height: app.styler.themeItemSizeSmall
        source: item.icon
    }

    LabelPL {
        id: label
        anchors.left: icon.right
        anchors.leftMargin: app.styler.themePaddingMedium
        anchors.right: parent.right
        anchors.rightMargin: app.styler.themeHorizontalPageMargin
        color: item.highlighted ? app.styler.themeHighlightColor : app.styler.themePrimaryColor
        height: app.styler.themeItemSizeSmall
        text: item.label
        truncMode: truncModes.fade
        verticalAlignment: Text.AlignVCenter
    }

}
