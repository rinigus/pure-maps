/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2018-2020 Rinigus
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

    property real   compassOrientationOffset: 0
    property alias  initialPage: pageStack.initialItem
    property string menuPageUrl
    property var    pages: StackPL { }
    property bool   running: visible || keepAliveBackground
    property int    screenHeight: height
    property bool   screenLarge: false
    property int    screenWidth: width
    property bool   keepAlive: false           // not used
    property bool   keepAliveBackground: false // not used

    StackView {
        id: pageStack
        anchors.fill: parent
    }

    Settings {
        property alias x: appWindow.x
        property alias y: appWindow.y
        property alias width: appWindow.width
        property alias height: appWindow.height
    }

    Component.onCompleted: {
        pages.ps = pageStack;
        updateOrientation();
    }

    function activate() {
        appWindow.raise();
    }

    function clearPages() {
        // not used in the platforms with menu shown
        // as a page in a stack
    }

    function initPages() {
    }

    function sendSms(text) {
        console.log("Sending SMS is not implemented");
    }

    function showMainMenu() {
        app.push(menuPageUrl);
    }

    function updateOrientation() {
        // blank - desktop is not expected to be changing screen orientation
    }
}
