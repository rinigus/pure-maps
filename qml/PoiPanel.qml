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

    // interanal properties
    property int  contentHeight: {
        if (!hasData) return 0;
        var h = 2*Theme.paddingLarge;
        h += titleItem.height;
        h += textItem.height;
        h += splitterItem.height;
        h += linkItem.height;
        h += Math.max(mainButtons.height, menuButton.height);
        return h;
    }
    property bool hasData: false
    property bool noAnimation: false

    // poi properties
    property bool   bookmarked: false
    property var    coordinate
    property string link
    property string poiId
    property string text
    property string title
    property bool showMenu: false

    Behavior on y {
        enabled: !noAnimation && (!mouse.drag.active || mouse.dragDone)
        NumberAnimation {
            duration: 100
            easing.type: Easing.Linear
            onRunningChanged: panel.noAnimation = !panel.hasData;
        }
    }

    // Declare non-interactive elements before MouseArea
    // and all interactive elements after MouseArea
    // This will preserve dragging and interaction with
    // the elements. Use anchors to position the elements

    ListItemLabel {
        // title and overall anchor to the top
        id: titleItem
        anchors.top: panel.top
        anchors.topMargin: Theme.paddingLarge
        color: Theme.highlightColor
        font.pixelSize: Theme.fontSizeLarge
        height: text ? implicitHeight + Theme.paddingLarge: 0
        text: panel.title
        truncationMode: TruncationMode.None
        verticalAlignment: Text.AlignTop
        wrapMode: Text.WordWrap
    }

    ListItemLabel {
        id: textItem
        anchors.top: titleItem.bottom
        color: Theme.highlightColor
        height: text ? implicitHeight + Theme.paddingMedium: 0
        text: panel.text
        textFormat: Text.RichText
        truncationMode: TruncationMode.None
        verticalAlignment: Text.AlignTop
        wrapMode: Text.WordWrap
    }

    Rectangle {
        id: splitterItem
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: linkItem.bottom
        color: "transparent"
        height: Theme.paddingLarge - Theme.paddingMedium
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

    IconListItem {
        id: linkItem
        anchors.top: textItem.bottom
        height: panel.link ? implicitHeight + Theme.paddingMedium : 0
        icon: panel.link ? "image://theme/icon-m-link" : ""
        label: panel.link
        MouseArea {
            anchors.fill: parent
            onClicked: Qt.openUrlExternally(panel.link)
        }
    }

    Row {
        id: mainButtons
        anchors.leftMargin: Theme.horizontalPageMargin
        anchors.top: splitterItem.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: Theme.paddingLarge
        states: [
            State {
                // make space for the menu button if needed
                when: panel.showMenu && parent.width/2-mainButtons.width-Theme.horizontalPageMargin < menuButton.width
                AnchorChanges {
                    target: mainButtons
                    anchors.left: parent.left
                    anchors.horizontalCenter: undefined
                }
            }
        ]

        IconButton {
            enabled: coordinate !== undefined
            icon.source: bookmarked ? "image://theme/icon-m-favorite-selected" : "image://theme/icon-m-favorite"
            onClicked: bookmarked = !bookmarked;
        }

        IconButton {
            enabled: coordinate !== undefined
            icon.source: "image://theme/icon-m-car"
            onClicked: {
                if (coordinate === undefined) return;
                app.showMenu("RoutePage.qml", {
                                 "to": [coordinate.longitude, coordinate.latitude],
                                 "toText": title,
                             });
            }
        }

        IconButton {
            enabled: coordinate !== undefined
            icon.source: "image://theme/icon-m-whereami"
            onClicked: {
                if (coordinate === undefined) return;
                app.showMenu("NearbyPage.qml", {
                                 "near": [coordinate.longitude, coordinate.latitude],
                                 "nearText": title,
                             });
            }
        }

        IconButton {
            enabled: coordinate !== undefined
            icon.source: "image://theme/icon-m-share"
            onClicked: {
                if (coordinate === undefined) return;
                app.showMenu("SharePage.qml", {
                                 "coordinate": coordinate,
                                 "title": title,
                             });
            }
        }
    }

    IconButton {
        id: menuButton
        anchors.right: parent.right
        anchors.rightMargin: Theme.horizontalPageMargin
        anchors.top: splitterItem.bottom
        icon.source: panel.showMenu ? "image://theme/icon-m-menu" : ""
        visible: panel.showMenu
        onClicked: app.showMenu();
    }

    Connections {
        target: panel
        onContentHeightChanged: panel.hasData && panel._show()
    }

    Connections {
        target: parent
        onHeightChanged: {
            if (panel.hasData) panel._show();
            else panel._hide();
        }
    }

    function _hide() {
        y = parent.height;
    }

    function hide() {
        _hide();
        panel.bookmarked = false;
        panel.coordinate = undefined;
        panel.hasData = false;
        panel.link = "";
        panel.poiId = "";
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
        panel.noAnimation = panel.hasData;
        panel.bookmarked = poi.bookmarked || false;
        panel.coordinate = poi.coordinate || undefined;
        panel.hasData = true;
        panel.link = poi.link || "";
        panel.poiId = poi.poiId || "";
        panel.text = poi.text || "";
        panel.title = poi.title || "";
        panel.showMenu = !!menu;
        _show();
        panel.noAnimation = false;
    }
}
