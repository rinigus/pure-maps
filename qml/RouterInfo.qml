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
    id: routerInfo
    anchors.bottom: app.scaleBar.top
    anchors.bottomMargin: Theme.paddingLarge
    anchors.left: parent.left
    anchors.leftMargin: Theme.paddingLarge

    height: info.implicitHeight
    opacity: 0.9
    width: parent.width
    z: 100

    Text {
        id: info
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        color: "black"
        font.bold: true
        font.family: "sans-serif"
        font.pixelSize: Math.round(Theme.pixelRatio * 18)
        horizontalAlignment: Text.AlignLeft
        lineHeight: 1.25
        text: ""
    }

    Timer {
        id: timerCleanup
        interval: 10000
        running: false
        repeat: false
        onTriggered: routerInfo.clear()
    }

    function setInfo(txt) {
        info.text = txt
        timerCleanup.stop()
    }

    function setError(txt) {
        info.text = txt
        timerCleanup.restart()
    }

    function clear() {
        info.text = ""
    }
}
