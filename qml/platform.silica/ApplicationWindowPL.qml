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
import Nemo.KeepAlive 1.1
import "."

ApplicationWindow {
    allowedOrientations: defaultAllowedOrientations
    cover: null
    initialPage: null

    // Default vertical margin for various multiline list items
    // such that it would be consistent with single-line list items
    // and the associated constant Theme.itemSizeSmall.
    property real   listItemVerticalMargin: (Theme.itemSizeSmall - 1.125 * Theme.fontSizeMedium) / 2
    property var    pages: null // initialized later to ensure the same path for object creation
    property real   pixelRatio: Theme.pixelRatio
    property bool   running: applicationActive || (cover && cover.active)
    property int    screenHeight: Screen.height
    property int    screenWidth: Screen.width

    // Emitted when keep alive requirements could have changed
    signal checkKeepAlive

    Component.onCompleted: updateOrientation()

    onApplicationActiveChanged: checkKeepAlive()

    onDeviceOrientationChanged: updateOrientation()

    function initPages() {
        pages.ps = pageStack;
    }

    function keepAlive(alive) {
        DisplayBlanking.preventBlanking = app.applicationActive && alive;
    }

    function updateOrientation() {
        if (!(deviceOrientation & allowedOrientations)) return;
        switch (deviceOrientation) {
        case Orientation.Portrait:
            screenWidth = Screen.width;
            screenHeight = Screen.height;
            break;
        case Orientation.PortraitInverted:
            screenWidth = Screen.width;
            screenHeight = Screen.height;
            break;
        case Orientation.Landscape:
            screenWidth = Screen.height;
            screenHeight = Screen.width;
            break;
        case Orientation.LandscapeInverted:
            screenWidth = Screen.height;
            screenHeight = Screen.width;
            break;
        }
    }

}
