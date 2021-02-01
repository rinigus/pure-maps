/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2018-2020 Rinigus, 2019 Purism SPC
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
import org.kde.kirigami 2.5 as Kirigami
import "."

Kirigami.ApplicationWindow {
    id: appWindow

    contextDrawer: Kirigami.ContextDrawer {
        id: contextDrawer
    }
    height: 480
    width: 640
    visible: true
    pageStack.initialPage: initialPage
    pageStack.globalToolBar.showNavigationButtons: pages && pages.currentIndex > 0 ?
                                                       Kirigami.ApplicationHeaderStyle.ShowBackButton :
                                                       Kirigami.ApplicationHeaderStyle.NoNavigationButtons

    property real   compassOrientationOffset: 0
    property bool   isConvergent: true
    property var    initialPage
    property string menuPageUrl
    property var    pages: StackPL { }
    property bool   running: visible || keepAliveBackground
    property int    screenHeight: height
    property bool   screenLarge: false
    property int    screenWidth: width
    property bool   keepAlive: false
    property bool   keepAliveBackground: false // not used

    // hide from Kirigami
    default property var _content

    ScreenSaver {
        name: "Pure Maps"
        preventBlanking: active && keepAlive
        reason: "Showing Maps"
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

    function initPages() {
        if (menuPageUrl) {
            globalDrawer = app.createObject(menuPageUrl);
            globalDrawer.edge = Qt.RightEdge;
            globalDrawer.clip = true;
            globalDrawer.enabled = Qt.binding(function () { return pages.currentIndex === 0; })
        }
    }

    function sendSms(text) {
        console.log("Sending SMS is not implemented");
    }
    
    function showMainMenu() {
        globalDrawer.open();
    }

    function updateOrientation() {
        // blank - desktop is not expected to be changing screen orientation
    }
}
