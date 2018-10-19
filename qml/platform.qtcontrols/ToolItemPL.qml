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

import QtQuick 2.9
import QtQuick.Controls 2.2

Item {
    id: host
    height: childrenRect.height

    property alias icon: image
    property alias text: label.text

    signal clicked

    ItemDelegate {
        id: item
        height: image.height + label.height + 2*app.styler.themePaddingLarge
        width: parent.width

        Image {
            id: image
            anchors.horizontalCenter: item.horizontalCenter
            anchors.top: item.top
            anchors.topMargin: app.styler.themePaddingLarge
            fillMode: Image.PreserveAspectFit
        }

        Label {
            id: label
            anchors.left: parent.left
            anchors.leftMargin: app.styler.themePaddingLarge
            anchors.right: parent.right
            anchors.rightMargin: app.styler.themePaddingLarge
            anchors.top: image.bottom
            anchors.topMargin: app.styler.themePaddingMedium
            color: item.highlighted ? app.styler.themeHighlightColor : app.styler.themePrimaryColor
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
        }

        onClicked: host.clicked()
    }
}
