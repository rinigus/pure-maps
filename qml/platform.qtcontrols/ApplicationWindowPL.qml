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

import QtQuick 2.9
import QtQuick.Controls 2.2
import Qt.labs.settings 1.0
import "."

ApplicationWindow {
    id: appWindow
    width: 640
    height: 480
    visible: true

    property alias initialPage: pageStack.initialItem

    property var   pages: null // initialized later to ensure the same path for object creation
    property bool  running: visible
    property int   screenHeight: height
    property bool  screenLarge: true
    property int   screenWidth: width

    // Emitted when keep alive requirements could have changed
    signal checkKeepAlive

    StackView {
        id: pageStack
        initialItem: appWindow.initialPage
        anchors.fill: parent
    }

    Component.onCompleted: updateOrientation()

    function initPages() {
        pages.ps = pageStack;
    }

    function keepAlive(alive) {
        // blank - desktop is not expected to be falling asleep
    }

    function updateOrientation() {
        // blank - desktop is not expected to be changing screen orientation
    }

    Settings {
        property alias x: appWindow.x
        property alias y: appWindow.y
        property alias width: appWindow.width
        property alias height: appWindow.height
    }

}
