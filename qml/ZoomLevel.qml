/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2018 Rinigus
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

Rectangle {
    id: master
    anchors.verticalCenter: attributionButton.verticalCenter
    anchors.left: attributionButton.right
    anchors.leftMargin: Theme.paddingLarge
    color: "transparent"
    height: visible ? cover.height : 0
    visible: app.conf.developmentShowZ
    z: 400

    Rectangle {
        id: cover
        anchors.centerIn: ztxt
        color: app.styler.streetBg
        height: ztxt.height
        opacity: 0.75
        radius: Theme.paddingMedium
        visible: parent.visible
        width: ztxt.width + 2*Theme.paddingMedium
        z: 450
    }

    Label {
        id: ztxt
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        color: app.styler.streetFg
        font.pixelSize: Theme.fontSizeLarge
        maximumLineCount: 1
        text: "z=%1".arg(map.zoomLevel.toFixed(2))
        z: 500
    }
}
