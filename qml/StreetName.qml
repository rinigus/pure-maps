/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2015 Osmo Salomaa
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

Text {
    id: streetname
    anchors.bottom: app.navigationActive ? navigationInfoBlock.top : menuButton.top
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.bottomMargin: app.navigationActive ? Theme.paddingSmall : 0
    color: "black"
    elide: Text.ElideRight
    //font.bold: true
    font.pixelSize: Theme.fontSizeLarge
    horizontalAlignment: Text.AlignHCenter
    maximumLineCount: 1
    style: Text.Outline
    styleColor: "white"
    text: gps.streetName
    visible: app.navigationActive && (text !== undefined && text !== null && text.length>0)
    width: parent.width - 2*Theme.paddingLarge
    z: 400
}
