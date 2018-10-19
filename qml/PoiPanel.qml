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
import "."
import "platform"

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
        var h = 2*app.styler.themePaddingLarge;
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
        anchors.topMargin: app.styler.themePaddingLarge
        color: app.styler.themeHighlightColor
        font.pixelSize: app.styler.themeFontSizeLarge
        height: text ? implicitHeight + app.styler.themePaddingMedium: 0
        text: panel.title
        truncMode: truncModes.none
        verticalAlignment: Text.AlignTop
        wrapMode: Text.WordWrap
    }

    ListItemLabel {
        id: typeAddressItem
        anchors.top: titleItem.bottom
        color: app.styler.themeHighlightColor
        height: text ? implicitHeight + app.styler.themePaddingSmall: 0
        font.pixelSize: app.styler.themeFontSizeSmall
        text: {
            if (panel.poiType && panel.address)
                return app.tr("%1; %2", panel.poiType, panel.address);
            else if (panel.poiType)
                return panel.poiType;
            else if (panel.address)
                return panel.address;
            return "";
        }
        truncMode: truncModes.none
        verticalAlignment: Text.AlignTop
        wrapMode: Text.WordWrap
    }

    ListItemLabel {
        id: coorItem
        anchors.top: typeAddressItem.bottom
        color: app.styler.themeSecondaryHighlightColor
        font.pixelSize: app.styler.themeFontSizeSmall
        height: text ? implicitHeight + app.styler.themePaddingSmall: 0
        text: app.portrait && panel.coordinate? app.tr("Latitude: %1; Longitude: %2", panel.coordinate.latitude, panel.coordinate.longitude) : ""
        truncMode: truncModes.fade
        verticalAlignment: Text.AlignTop
    }

    ListItemLabel {
        id: textItem
        anchors.top: coorItem.bottom
        color: app.styler.themeHighlightColor
        font.pixelSize: app.styler.themeFontSizeSmall
        height: text ? implicitHeight + app.styler.themePaddingSmall: 0
        maximumLineCount: app.portrait ? 3 : 1;
        text: panel.text
        truncMode: truncModes.elide
        verticalAlignment: Text.AlignTop
        wrapMode: Text.WordWrap
    }

    ListItemLabel {
        id: additionalInfoItem
        anchors.top: textItem.bottom
        color: app.styler.themeSecondaryHighlightColor
        font.pixelSize: app.styler.themeFontSizeSmall
        height: text ? implicitHeight + app.styler.themePaddingSmall: 0
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
        truncMode: truncModes.fade
        verticalAlignment: Text.AlignTop
    }

    Rectangle {
        id: splitterItem
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: additionalInfoItem.bottom
        color: "transparent"
        height: app.styler.themePaddingLarge - app.styler.themePaddingSmall
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
        anchors.leftMargin: app.styler.themeHorizontalPageMargin
        anchors.top: splitterItem.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: app.styler.themePaddingLarge
        states: [
            State {
                // make space for the menu button if needed
                when: panel.showMenu && parent.width/2-mainButtons.width-app.styler.themeHorizontalPageMargin < menuButton.width
                AnchorChanges {
                    target: mainButtons
                    anchors.left: parent.left
                    anchors.horizontalCenter: undefined
                }
            }
        ]

        IconButtonPL {
            icon.source: app.styler.iconAbout
            icon.sourceSize.height: app.styler.themeIconSizeMedium
            onClicked: {
                app.push("PoiInfoPage.qml", {
                             "active": active,
                             "poi": panel.poi,
                         });
            }
        }

        IconButtonPL {
            enabled: panel.active
            icon.source: bookmarked ? app.styler.iconFavoriteSelected  : app.styler.iconFavorite
            icon.sourceSize.height: app.styler.themeIconSizeMedium
            onClicked: {
                bookmarked = !bookmarked;
                map.bookmarkPoi(poiId, bookmarked);
            }
        }

        IconButtonPL {
            icon.source: app.styler.iconNavigate
            icon.sourceSize.height: app.styler.themeIconSizeMedium
            onClicked: {
                if (coordinate === undefined) return;
                panel.showMenu = false;
                app.showMenu("RoutePage.qml", {
                                 "to": [coordinate.longitude, coordinate.latitude],
                                 "toText": title,
                             });
            }
        }

        IconButtonPL {
            icon.source: app.styler.iconNearby
            icon.sourceSize.height: app.styler.themeIconSizeMedium
            onClicked: {
                if (coordinate === undefined) return;
                panel.showMenu = false;
                app.showMenu("NearbyPage.qml", {
                                 "near": [coordinate.longitude, coordinate.latitude],
                                 "nearText": title,
                             });
            }
        }

        IconButtonPL {
            enabled: panel.active
            icon.source: !panel.showMenu ? app.styler.iconDelete : ""
            icon.sourceSize.height: app.styler.themeIconSizeMedium
            visible: !panel.showMenu
            onClicked: {
                if (coordinate === undefined) return;
                map.deletePoi(poiId, true);
                hide();
            }
        }

    }

    IconButtonPL {
        id: menuButton
        anchors.right: parent.right
        anchors.rightMargin: app.styler.themeHorizontalPageMargin
        anchors.top: splitterItem.bottom
        icon.source: panel.showMenu ? app.styler.iconMenu : ""
        icon.sourceSize.height: app.styler.themeIconSizeMedium
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
