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
import "."

Rectangle {
    id: panel
    anchors.left: parent.left
    color: app.styler.blockBg
    height: contentHeight >= parent.height - y ? contentHeight : parent.height - y
    width: parent.width
    y: parent.height
    z: 910

    property int contentHeight: column.height > 0 ? Math.max(column.height, actionColumn.height) + 2*Theme.paddingLarge : 0
    //property int contentHeight: column.height > 0 ? column.height + 2*Theme.paddingLarge : 0
    property bool bookmarked: false
    property string link
    property string text
    property string title
    property bool showMenu: false

    Behavior on y {
        NumberAnimation {
            duration: mouse.drag.active && !mouse.dragDone ? 0 : 100
            easing.type: Easing.Linear
        }
    }

    Column {
        id: column
        anchors.top: panel.top
        anchors.topMargin: Theme.paddingLarge
        anchors.left: parent.left
        anchors.right: actionColumn.left
        //anchors.right: parent.right

        Label {
            anchors.left: parent.left
            anchors.leftMargin: Theme.horizontalPageMargin
            anchors.right: parent.right
            anchors.rightMargin: Theme.horizontalPageMargin
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeLarge
            height: text ? implicitHeight + Theme.paddingLarge: 0
            text: panel.title
            verticalAlignment: Text.AlignTop
            wrapMode: Text.WordWrap
        }

        Label {
            anchors.left: parent.left
            anchors.leftMargin: Theme.horizontalPageMargin
            anchors.right: parent.right
            anchors.rightMargin: Theme.horizontalPageMargin
            color: Theme.highlightColor
            height: text ? implicitHeight + Theme.paddingMedium: 0
            text: panel.text.replace(/Theme.highlightColor/g, Theme.primaryColor)
            textFormat: Text.RichText
            verticalAlignment: Text.AlignTop
            wrapMode: Text.WordWrap
        }

        IconListItem {
            height: panel.link ? implicitHeight + Theme.paddingMedium : 0
            icon: panel.link ? "image://theme/icon-m-link" : ""
            label: panel.link
            MouseArea {
                anchors.fill: parent
                onClicked: Qt.openUrlExternally(panel.link)
            }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        drag.target: panel
        drag.axis: Drag.YAxis
        drag.minimumY: panel.parent.height - panel.height
        drag.maximumY: panel.parent.height

        property bool dragDone: true

        onPressed: {
            dragDone=false;
        }

        onReleased: {
            dragDone = true;
            var t = Math.min(panel.parent.height*0.1, panel.height * 0.5);
            var d = panel.y - drag.minimumY;
            if (d > t)
                panel.hide();
            else
                panel._show();
        }
    }

    Column {
        id: actionColumn
        anchors.top: panel.top
        anchors.topMargin: Theme.paddingLarge
        anchors.right: panel.right
        anchors.rightMargin: Theme.horizontalPageMargin
        width: Math.max(menuButton.width, bookmarkButton.width)

        IconButton {
            id: menuButton
            //height: panel.showMenu ? implicitHeight + Theme.paddingLarge : 0
            icon.source: panel.showMenu ? "image://theme/icon-m-menu" : 0
            visible: panel.showMenu
            //width: panel.showMenu ? implicitWidth : 0
            onClicked: app.showMenu();
        }

        IconButton {
            id: bookmarkButton
            icon.source: bookmarked ? "image://theme/icon-m-favorite-selected" : "image://theme/icon-m-favorite"
            onClicked: bookmarked = !bookmarked;
        }
    }

    Connections {
        target: column
        onHeightChanged: panel._show()
    }

    function _hide() {
        y = parent.height;
    }

    function hide() {
        _hide();
        panel.bookmarked = false;
        panel.link = "";
        panel.text = "";
        panel.title = "";
        panel.showMenu = false;
        app.poiActive = false;
    }

    function _show() {
        y = parent.height - panel.contentHeight;
    }

    function show(poi, menu) {
        app.poiActive = true;
        panel.bookmarked = poi.bookmarked || false;
        panel.link = poi.link || "";
        panel.text = poi.text || "";
        panel.title = poi.title || "";
        panel.showMenu = !!menu;
        _show();
    }
}
