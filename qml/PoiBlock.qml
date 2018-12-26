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

// POI information shown in a panel under the map
Item {
    id: item
    anchors.left: parent.left
    anchors.right: parent.right
    height: {
        if (!visible) return 0;
        var h = 0;
        h += titleItem.height;
        h += typeAddressItem.height;
        h += coorItem.height;
        h += textItem.height;
        h += additionalInfoItem.height;
        h += splitterItem.height;
        h += mainButtons.height;
        return h;
    }
    visible: false

    // properties of the item
    property bool active: false
    property int  contentHeight: height

    // poi properties
    property string address
    property bool   bookmarked: false
    property var    coordinate
    property string link
    property string phone
    property string poiId
    property string poiType
    property string postcode
    property bool   shortlisted: false
    property string text
    property string title
    property var    poi

    ListItemLabel {
        // title and overall anchor to the top
        id: titleItem
        anchors.top: item.top
        color: app.styler.themeHighlightColor
        font.pixelSize: app.styler.themeFontSizeLarge
        height: text ? implicitHeight + app.styler.themePaddingMedium: 0
        text: item.title
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
            if (item.poiType && item.address)
                return app.tr("%1; %2", item.poiType, item.address);
            else if (item.poiType)
                return item.poiType;
            else if (item.address)
                return item.address;
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
        text: app.portrait && item.coordinate? app.tr("Latitude: %1; Longitude: %2", item.coordinate.latitude, item.coordinate.longitude) : ""
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
        text: item.text
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
            if (item.postcode) info += app.tr("Postal code") + "  ";
            if (item.link) info += app.tr("Web") + "  ";
            if (item.phone) info += app.tr("Phone") + "  ";
            if (item.shortlisted) info += app.tr("Shortlisted") + "  ";
            if (item.text && textItem.truncated) info += app.tr("Text") + "  ";
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

    Row {
        id: mainButtons
        anchors.leftMargin: app.styler.themeHorizontalPageMargin
        anchors.top: splitterItem.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: app.styler.themePaddingLarge

        IconButtonPL {
            icon.source: app.styler.iconAbout
            icon.sourceSize.height: app.styler.themeIconSizeMedium
            onClicked: {
                app.push("PoiInfoPage.qml", {
                             "active": active,
                             "poi": item.poi,
                         });
            }
        }

        IconButtonPL {
            enabled: item.active
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
                app.showMenu("NearbyPage.qml", {
                                 "near": [coordinate.longitude, coordinate.latitude],
                                 "nearText": title,
                             });
            }
        }

        IconButtonPL {
            enabled: item.active
            icon.source: app.styler.iconDelete
            icon.sourceSize.height: app.styler.themeIconSizeMedium
            onClicked: {
                if (coordinate === undefined) return;
                map.deletePoi(poiId, true);
                hide();
            }
        }

    }

    Connections {
        target: map
        onPoiChanged: {
            if (!poi || poi.poiId !== poiId) return;
            item.show(map.getPoiById(poiId));
        }
    }

    function hide() {
        item.visible = false;
        item.active = false;
        item.poiId = "";
        app.poiActive = false;
        map.setSelectedPoi()
    }

    function show(poi) {
        if (!poi) {
            hide();
            return;
        }
        app.poiActive = true;
        // fill poi data
        item.address = poi.address || "";
        item.bookmarked = poi.bookmarked || false;
        item.coordinate = poi.coordinate || QtPositioning.coordinate(poi.y, poi.x);
        item.link = poi.link || "";
        item.phone = poi.phone || "";
        item.poiId = poi.poiId || "";
        item.poiType = poi.poiType || "";
        item.postcode = poi.postcode || "";
        item.shortlisted = poi.shortlisted || false;
        item.text = poi.text || "";
        item.title = poi.title || app.tr("Unnamed point");
        item.poi = poi;
        // fill item vars
        item.active = (item.poiId.length > 0);
        item.visible = true;
        map.setSelectedPoi(item.coordinate)
    }
}
