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
        color: styler.themeHighlightColor
        font.pixelSize: styler.themeFontSizeLarge
        height: text ? implicitHeight + styler.themePaddingMedium: 0
        text: item.title
        truncMode: truncModes.none
        verticalAlignment: Text.AlignTop
        wrapMode: Text.WordWrap
    }

    ListItemLabel {
        id: typeAddressItem
        anchors.top: titleItem.bottom
        color: styler.themeHighlightColor
        height: text ? implicitHeight + styler.themePaddingSmall: 0
        font.pixelSize: styler.themeFontSizeSmall
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
        color: styler.themeSecondaryHighlightColor
        font.pixelSize: styler.themeFontSizeSmall
        height: text ? implicitHeight + styler.themePaddingSmall: 0
        text: app.portrait && item.coordinate? app.tr("Latitude: %1; Longitude: %2", item.coordinate.latitude, item.coordinate.longitude) : ""
        truncMode: truncModes.fade
        verticalAlignment: Text.AlignTop
    }

    ListItemLabel {
        id: textItem
        anchors.top: coorItem.bottom
        color: styler.themeHighlightColor
        font.pixelSize: styler.themeFontSizeSmall
        height: text ? implicitHeight + styler.themePaddingSmall: 0
        maximumLineCount: app.portrait ? 3 : 1;
        text: item.text
        truncMode: truncModes.elide
        verticalAlignment: Text.AlignTop
        wrapMode: Text.WordWrap
    }

    ListItemLabel {
        id: additionalInfoItem
        anchors.top: textItem.bottom
        color: styler.themeSecondaryHighlightColor
        font.pixelSize: styler.themeFontSizeSmall
        height: text ? implicitHeight + styler.themePaddingSmall: 0
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
        height: styler.themePaddingLarge - styler.themePaddingSmall
    }

    Row {
        id: mainButtons
        anchors.leftMargin: styler.themeHorizontalPageMargin
        anchors.top: splitterItem.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: styler.themePaddingLarge

        IconButtonPL {
            iconHeight: styler.themeIconSizeMedium
            iconName: styler.iconAbout
            onClicked: {
                app.push(Qt.resolvedUrl("PoiInfoPage.qml"), {
                             "active": active,
                             "poi": item.poi,
                         });
            }
        }

        IconButtonPL {
            enabled: item.active
            iconHeight: styler.themeIconSizeMedium
            iconName: bookmarked ? styler.iconFavoriteSelected  : styler.iconFavorite
            onClicked: {
                bookmarked = !bookmarked;
                pois.bookmark(poiId, bookmarked);
            }
        }

        IconButtonPL {
            iconHeight: styler.themeIconSizeMedium
            iconName: styler.iconNavigate
            onClicked: {
                if (coordinate === undefined) return;
                app.showMenu(Qt.resolvedUrl("RoutePage.qml"), {
                                 "to": [coordinate.longitude, coordinate.latitude],
                                 "toText": title,
                             });
            }
        }

        IconButtonPL {
            iconHeight: styler.themeIconSizeMedium
            iconName: styler.iconNearby
            onClicked: {
                if (coordinate === undefined) return;
                app.showMenu(Qt.resolvedUrl("NearbyPage.qml"), {
                                 "near": [coordinate.longitude, coordinate.latitude],
                                 "nearText": title,
                             });
            }
        }

        IconButtonPL {
            enabled: item.active
            iconHeight: styler.themeIconSizeMedium
            iconName: styler.iconDelete
            onClicked: {
                if (coordinate === undefined) return;
                pois.remove(poiId, true);
                hide();
            }
        }

    }

    Connections {
        target: pois
        onPoiChanged: {
            if (!poiId || item.poiId !== poiId) return;
            item.show(pois.getById(poiId));
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
