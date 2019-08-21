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
    _defaultPageOrientations: defaultAllowedOrientations // required to fix issue #219
    cover: Cover {}
    initialPage: null

    property string menuPageUrl
    property var    pages: StackPL { }
    property bool   running: applicationActive || (cover && cover.active)
    property int    screenHeight: Screen.height
    property bool   screenLarge: Screen.sizeCategory >= Screen.Large
    property int    screenWidth: Screen.width
    property string title
    property bool   keepAlive: false

    Component.onCompleted: {
        pages.ps = pageStack;
        updateOrientation()
        DisplayBlanking.preventBlanking = Qt.binding(function() { return applicationActive && keepAlive })
    }

    Keys.onPressed: {
        // Allow zooming with plus and minus keys on the emulator.
        (event.key === Qt.Key_Plus)  && map.setZoomLevel(map.zoomLevel+1);
        (event.key === Qt.Key_Minus) && map.setZoomLevel(map.zoomLevel-1);
    }

    onDeviceOrientationChanged: updateOrientation()

    function clearPages() {
        // not used in the platforms with menu shown
        // as a page in a stack
    }

    function initPages() {
    }

    function sendSms(text) {
        // XXX: SMS links don't work without a recipient.
        // https://together.jolla.com/question/84134/
        clipboard.copy(text);
        py.call("poor.util.popen", [
                    "/usr/bin/invoker",
                    "--type=silica-qt5",
                    "/usr/bin/jolla-messages",
                ], null);
        return [1, 0];
    }

    function showMainMenu() {
        app.push(menuPageUrl);
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
