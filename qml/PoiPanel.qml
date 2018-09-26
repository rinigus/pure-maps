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
import QtPositioning 5.3
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

    // internal properties
    property bool active: false
    property int  contentHeight: {
        if (!hasData) return 0;
        var h = 2*Theme.paddingLarge;
        h += titleItem.height;
        h += typeAddressItem.height;
        h += coorItem.height;
        h += textItem.height;
        h += additionalInfoItem.height;
        h += splitterItem.height;
//        h += phoneItem.height;
//        h += linkItem.height;
        h += Math.max(mainButtons.height, menuButton.height);
        return h;
    }
    property bool hasData: false
    property bool noAnimation: false
    property bool showMenu: false

    // poi properties
    property string address
    property bool   bookmarked: false
    property var    coordinate
    property string link
    property string phone
    property string poiId
    property string poiType
    property string postcode
    property string text
    property string title
    property var    poi

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
        height: text ? implicitHeight + Theme.paddingMedium: 0
        text: panel.title
        truncationMode: TruncationMode.None
        verticalAlignment: Text.AlignTop
        wrapMode: Text.WordWrap
    }

    ListItemLabel {
        id: typeAddressItem
        anchors.top: titleItem.bottom
        color: Theme.highlightColor
        height: text ? implicitHeight + Theme.paddingSmall: 0
        font.pixelSize: Theme.fontSizeSmall
        text: {
            if (panel.poiType && panel.address)
                return app.tr("%1; %2", panel.poiType, panel.address);
            else if (panel.poiType)
                return panel.poiType;
            else if (panel.address)
                return panel.address;
            return "";
        }
        truncationMode: TruncationMode.None
        verticalAlignment: Text.AlignTop
        wrapMode: Text.WordWrap
    }

    ListItemLabel {
        id: coorItem
        anchors.top: typeAddressItem.bottom
        color: Theme.secondaryHighlightColor
        font.pixelSize: Theme.fontSizeSmall
        height: text ? implicitHeight + Theme.paddingSmall: 0
        text: app.portrait && panel.coordinate? app.tr("Latitude: %1; Longitude: %2", panel.coordinate.latitude, panel.coordinate.longitude) : ""
        truncationMode: TruncationMode.Fade
        verticalAlignment: Text.AlignTop
    }

    ListItemLabel {
        id: textItem
        anchors.top: coorItem.bottom
        color: Theme.highlightColor
        font.pixelSize: Theme.fontSizeSmall
        height: text ? implicitHeight + Theme.paddingSmall: 0
        maximumLineCount: app.portrait ? 3 : 1;
        text: panel.text
        truncationMode: TruncationMode.Elide
        verticalAlignment: Text.AlignTop
        wrapMode: Text.WordWrap
    }

    ListItemLabel {
        id: additionalInfoItem
        anchors.top: textItem.bottom
        color: Theme.secondaryHighlightColor
        font.pixelSize: Theme.fontSizeSmall
        height: text ? implicitHeight + Theme.paddingSmall: 0
        horizontalAlignment: Text.AlignRight
        text: {
            var info = "";
            if (panel.postcode) info += app.tr("Postal code") + "  ";
            if (panel.link) info += app.tr("Web") + "  ";
            if (panel.phone) info += app.tr("Phone") + "  ";
            if (panel.text && textItem.truncated) info += app.tr("Text") + "  ";
            if (info)
                return app.tr("More info: %1", info);
            return "";
        }
        truncationMode: TruncationMode.Fade
        verticalAlignment: Text.AlignTop
    }

    Rectangle {
        id: splitterItem
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: additionalInfoItem.bottom
        color: "transparent"
        height: Theme.paddingLarge - Theme.paddingSmall
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
            icon.source: "image://theme/icon-m-about"
            onClicked: {
                app.push("PoiInfoPage.qml", {
                             "active": active,
                             "poi": panel.poi,
                         });
            }
        }

        IconButton {
            enabled: panel.active
            icon.source: bookmarked ? "image://theme/icon-m-favorite-selected" : "image://theme/icon-m-favorite"
            onClicked: {
                bookmarked = !bookmarked;
                map.bookmarkPoi(poiId, bookmarked);
            }
        }

        IconButton {
            icon.source: "image://theme/icon-m-car"
            onClicked: {
                if (coordinate === undefined) return;
                panel.showMenu = false;
                app.showMenu("RoutePage.qml", {
                                 "to": [coordinate.longitude, coordinate.latitude],
                                 "toText": title,
                             });
            }
        }

        IconButton {
            icon.source: "image://theme/icon-m-whereami"
            onClicked: {
                if (coordinate === undefined) return;
                panel.showMenu = false;
                app.showMenu("NearbyPage.qml", {
                                 "near": [coordinate.longitude, coordinate.latitude],
                                 "nearText": title,
                             });
            }
        }

        IconButton {
            enabled: panel.active
            icon.source: !panel.showMenu ? "image://theme/icon-m-delete" : ""
            visible: !panel.showMenu
            onClicked: {
                if (coordinate === undefined) return;
                map.deletePoi(poiId, true);
                hide();
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
        onClicked: {
            app.showMenu();
            hide();
        }
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
        panel.active = false;
        panel.hasData = false;
        panel.poiId = "";
        app.poiActive = false;
        map.setSelectedPoi()
    }

    function _show() {
        y = parent.height - panel.contentHeight;
    }

    function show(poi, menu) {
        app.poiActive = true;
        panel.noAnimation = panel.hasData;
        // fill poi data
        panel.address = poi.address || "";
        panel.bookmarked = poi.bookmarked || false;
        panel.coordinate = poi.coordinate || QtPositioning.coordinate(poi.y, poi.x);
        panel.link = poi.link || "";
        panel.phone = poi.phone || "";
        panel.poiId = poi.poiId || "";
        panel.poiType = poi.poiType || "";
        panel.postcode = poi.postcode || "";
        panel.text = poi.text || "";
        panel.title = poi.title || app.tr("Unnamed point");
        panel.poi = poi;
        // fill panel vars
        panel.showMenu = !!menu;
        panel.active = (panel.poiId.length > 0);
        panel.hasData = true;
        _show();
        panel.noAnimation = false;
        map.setSelectedPoi(panel.coordinate)
    }
}
