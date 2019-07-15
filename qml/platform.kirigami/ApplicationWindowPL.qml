/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2018-2019 Rinigus, 2019 Purism SPC
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

    property bool   isConvergent: true
    property var    initialPage
    property string menuPageUrl
    property var    pages: StackPL { }
    property bool   running: visible
    property int    screenHeight: height
    property bool   screenLarge: true
    property int    screenWidth: width
    property bool   keepAlive: false // not used - desktop is not expected to be falling asleep

    // hide from Kirigami
    default property var _content

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
        // called when we need to drop all pages
        // except the page with a map and start
        // adding new ones

        // this implementation takes into account
        // we clear pages when we get to page 0
        app.pages.ps.currentIndex = 0;
    }

    function initPages() {
        if (menuPageUrl) {
            globalDrawer = app.createObject(menuPageUrl);
        }
    }

    function showMainMenu() {
        globalDrawer.open();
    }

    function updateOrientation() {
        // blank - desktop is not expected to be changing screen orientation
    }
}
