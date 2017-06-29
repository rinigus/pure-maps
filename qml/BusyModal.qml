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
import "."

Item {
    id: busy
    anchors.fill: parent

    property string description: ""
    property string error: ""
    property bool   running: false
    property string text: ""

    BusyIndicator {
        id: indicator
        anchors.centerIn: parent
        running: busy.running
        size: BusyIndicatorSize.Large
        visible: busy.running
    }

    Label {
        anchors.bottom: indicator.top
        anchors.bottomMargin: Math.round(indicator.height/4)
        color: Theme.highlightColor
        font.pixelSize: Theme.fontSizeLarge
        horizontalAlignment: Text.AlignHCenter
        text: busy.error || busy.text
        visible: busy.running || busy.error
        width: parent.width
    }

    ListItemLabel {
        anchors.top: indicator.bottom
        anchors.topMargin: Math.round(indicator.height/4)
        color: Theme.secondaryColor
        horizontalAlignment: Text.AlignHCenter
        text: busy.error ? "" : busy.description
        visible: busy.running
        wrapMode: Text.WordWrap
    }

    onErrorChanged: busy.error && (busy.text = "");
    onTextChanged: busy.text && (busy.error = "");

}
