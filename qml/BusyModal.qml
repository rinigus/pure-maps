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

Item {
    id: busy
    anchors.fill: parent
    property string error: ""
    property bool running: false
    property string text: ""
    Label {
        anchors.bottom: indicator.top
        color: Theme.highlightColor
        font.pixelSize: Theme.fontSizeLarge
        height: Theme.itemSizeLarge
        horizontalAlignment: Text.AlignHCenter
        text: busy.error || busy.text
        verticalAlignment: Text.AlignVCenter
        visible: busy.running || busy.error
        width: parent.width
    }
    BusyIndicator {
        id: indicator
        anchors.centerIn: parent
        running: busy.running
        size: BusyIndicatorSize.Large
        visible: busy.running
    }
    onErrorChanged: busy.error && (busy.text = "");
    onTextChanged: busy.text && (busy.error = "");
}
