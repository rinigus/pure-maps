/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2026 Rinigus
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

import QtCore
import QtQuick
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import org.puremaps 1.0
import pm.platform 1.0

Kirigami.ApplicationWindow {
    id: appWindow

    // contextDrawer: Kirigami.ContextDrawer {
    //     id: contextDrawer
    // }
    height: 480
    pageStack.initialPage: initialPage
    pageStack.globalToolBar.style: pages && pages.currentIndex > 0
                                   ? Kirigami.ApplicationHeaderStyle.Auto
                                   : Kirigami.ApplicationHeaderStyle.None
    pageStack.globalToolBar.showNavigationButtons: pages && pages.currentIndex > 0
                                                   ? Kirigami.ApplicationHeaderStyle.ShowBackButton
                                                   : Kirigami.ApplicationHeaderStyle.NoNavigationButtons
    visible: true
    width: 640

    property real   compassOrientationOffset: 0
    property var    initialPage
    property bool   isConvergent: true
    property bool   keepAlive: false
    property bool   keepAliveBackground: false // not used
    property string menuPageUrl
    property var    pages: StackPL { }
    property bool   running: visible || keepAliveBackground
    property int    screenHeight: height
    property bool   screenLarge: false
    property int    screenWidth: width

    // Hide shared QML children from Kirigami.ApplicationWindow.contentData.
    default property var _content

    ScreenSaverInhibitor {
        active: appWindow.active && appWindow.keepAlive
    }

    Settings {
        property alias height: appWindow.height
        property alias width: appWindow.width
        property alias x: appWindow.x
        property alias y: appWindow.y
    }

    Component.onCompleted: {
        pages.ps = pageStack;
        updateOrientation();
    }

    function activate() {
        appWindow.raise();
    }

    function initPages() {
        if (!menuPageUrl) return;
        globalDrawer = app.createObject(menuPageUrl);
        globalDrawer.edge = Qt.RightEdge;
        globalDrawer.clip = true;
        globalDrawer.enabled = Qt.binding(() => pages.currentIndex === 0);
    }

    function sendSms(text) {
        console.log("Sending SMS is not implemented");
    }

    function showMainMenu() {
        globalDrawer.open();
    }

    function updateOrientation() {
        // Desktop is not expected to change screen orientation.
    }
}
