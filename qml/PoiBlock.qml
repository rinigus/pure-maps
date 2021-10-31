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
import QtPositioning 5.4
import "."
import "platform"

// POI information shown in a panel under the map
Column {
    id: item
    anchors.left: parent.left
    anchors.right: parent.right
    height: visible ? implicitHeight : 0
    visible: false

    // properties of the item
    property bool  active: false
    property bool  navigationControls: false

    // poi properties
    property string address
    property bool   bookmarked: false
    property var    coordinate
    property string email
    property string link
    property string phone
    property string poiId
    property string poiType
    property string postcode
    property bool   shortlisted: false
    property string text
    property string title
    property var    poi

    // internal properties
    property bool  _fullMode: true
    property bool  _multipleIntermediatePossible: {
        if (!navigator.hasDestination) return false;
        if (navigator.hasOrigin)
            return navigator.locations.length > 2;
        return navigator.locations.length > 1;
    }
    property alias _optionalHeight: optional.height

    property var    poiAsRoutingDestination: {
        "text": title,
        "x": coordinate ? coordinate.longitude : 0,
        "y": coordinate ? coordinate.latitude : 0,
        "destination": true
    }
    property var    poiAsRoutingOrigin: {
        "text": title,
        "x": coordinate ? coordinate.longitude : 0,
        "y": coordinate ? coordinate.latitude : 0,
        "origin": true
    }

    ListItemLabel {
        // title
        color: styler.themeHighlightColor
        font.pixelSize: styler.themeFontSizeLarge
        height: text ? implicitHeight + styler.themePaddingMedium: 0
        text: item.title
        truncMode: truncModes.none
        verticalAlignment: Text.AlignTop
        wrapMode: Text.WordWrap
    }

    Column {
        id: optional
        anchors.left: parent.left
        anchors.right: parent.right
        visible: _fullMode

        ListItemLabel {
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
            color: styler.themeSecondaryHighlightColor
            font.pixelSize: styler.themeFontSizeSmall
            height: text ? implicitHeight + styler.themePaddingSmall: 0
            text: app.portrait && item.coordinate? app.tr("Latitude: %1; Longitude: %2", item.coordinate.latitude, item.coordinate.longitude) : ""
            truncMode: truncModes.fade
            verticalAlignment: Text.AlignTop
        }

        ListItemLabel {
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
            color: styler.themeSecondaryHighlightColor
            font.pixelSize: styler.themeFontSizeSmall
            height: text ? implicitHeight + styler.themePaddingSmall: 0
            horizontalAlignment: Text.AlignRight
            text: {
                var info = "";
                if (item.postcode) info += app.tr("Postal code") + "  ";
                if (item.link) info += app.tr("Web") + "  ";
                if (item.phone) info += app.tr("Phone") + "  ";
                if (item.email) info += app.tr("Email") + "  ";
                if (item.shortlisted) info += app.tr("Shortlisted") + "  ";
                if (item.text && textItem.truncated) info += app.tr("Text") + "  ";
                if (info)
                    return app.tr("More info: %1", info);
                return "";
            }
            truncMode: truncModes.fade
            verticalAlignment: Text.AlignTop
        }
    }

    Spacer {
        id: splitterItem
        height: styler.themePaddingLarge - styler.themePaddingSmall
    }

    Row {
        id: buttonRow
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: styler.themePaddingLarge * factor
        visible: !navigationControls

        property real factor: {
            // Assuming that icon width equals to height
            var l = children.length
            var w = item.width - styler.themeHorizontalPageMargin*2;
            var req = (l-1)*styler.themePaddingLarge +
                    l*(1+firstButton.padding)*styler.themeIconSizeMedium;
            if (w > req) return 1.0;
            if (w < req/4) return 1.0/4.0;
            return w / req;
        }
        property int iconHeight: styler.themeIconSizeMedium * factor

        IconButtonPL {
            id: firstButton
            iconHeight: buttonRow.iconHeight
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
            iconHeight: buttonRow.iconHeight
            iconName: bookmarked ? styler.iconFavoriteSelected  : styler.iconFavorite
            onClicked: {
                bookmarked = !bookmarked;
                pois.bookmark(poiId, bookmarked);
            }
        }

        IconButtonPL {
            iconHeight: buttonRow.iconHeight
            iconName: styler.iconNavigate
            onClicked: {
                if (coordinate === undefined) return;
                navigationControls = true;
            }
        }

        IconButtonPL {
            iconHeight: buttonRow.iconHeight
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
            iconHeight: buttonRow.iconHeight
            iconName: styler.iconDelete
            onClicked: {
                if (coordinate === undefined) return;
                pois.remove(poiId, true);
                hide();
            }
        }

    }

    // Navigation controls
    SectionHeaderPL {
        text: navigator.hasDestination || navigator.hasOrigin ? app.tr("Set as or Replace") : app.tr("Set as")
        visible: navigationControls
    }

    Grid {
        id: gridRepl
        columns: landscape ? 2 : 1
        anchors.left: parent.left
        anchors.right: parent.right
        visible: navigationControls

        property int  availableHalfWidth: width/2
        property bool landscape: gdest.visible && gorig.visible &&
                                 gdest.minWidth < availableHalfWidth &&
                                 gorig.minWidth < availableHalfWidth
        property int  cellTextSpace: width/2 - styler.themeHorizontalPageMargin -
                                     styler.themePaddingLarge

        ListItemLabelActive {
            id: gorig
            contentHeight: styler.themeItemSizeSmall
            label: app.tr("Origin")
            labelX: gridRepl.landscape ? styler.themePaddingLarge +
                                         gridRepl.cellTextSpace/2 - labelImplicitWidth/2 :
                                         styler.themeHorizontalPageMargin
            width: Math.max(minWidth, gridRepl.width / 2)
            property int minWidth: labelImplicitWidth + styler.themeHorizontalPageMargin +
                                   styler.themePaddingLarge

            onClicked: {
                var loc = navigator.locations;
                if (navigator.hasOrigin) loc[0] = poiAsRoutingOrigin;
                else loc.splice(0, 0, poiAsRoutingOrigin);
                navigator.locations = loc;
                finalizeRouting();
            }
        }

        ListItemLabelActive {
            id: gdest
            contentHeight: styler.themeItemSizeSmall
            label: app.tr("Final destination")
            labelX: gridRepl.landscape ? styler.themeHorizontalPageMargin +
                                         gridRepl.cellTextSpace/2 - labelImplicitWidth/2 :
                                         styler.themeHorizontalPageMargin
            width: Math.max(minWidth, gridRepl.width / 2)
            property int minWidth: labelImplicitWidth + styler.themeHorizontalPageMargin +
                                   styler.themePaddingLarge

            onClicked: {
                var loc = navigator.locations;
                if (navigator.hasDestination) loc[loc.length-1] = poiAsRoutingDestination;
                else loc.push(poiAsRoutingDestination);
                navigator.locations = loc;
                finalizeRouting();
            }
        }
    }

    SectionHeaderPL {
        text: app.tr("Insert as")
        visible: navigationControls && (navigator.hasOrigin || navigator.hasDestination)
    }

    ListItemLabelActive {
        label: app.tr("New origin")
        labelX: styler.themeHorizontalPageMargin
        visible: navigationControls && navigator.hasOrigin
        onClicked: {
            var loc = navigator.locations;
            loc[0].destination = true;
            loc.splice(0, 0, poiAsRoutingOrigin);
            navigator.locations = loc;
            finalizeRouting();
        }
    }

    ListItemLabelActive {
        label: app.tr("New final destination")
        labelX: styler.themeHorizontalPageMargin
        visible: navigationControls && navigator.hasDestination
        onClicked: {
            var loc = navigator.locations;
            loc.push(poiAsRoutingDestination);
            navigator.locations = loc;
            finalizeRouting();
        }
    }

    ListItemLabelActive {
        label: app.tr("First intermediate destination")
        labelX: styler.themeHorizontalPageMargin
        visible: navigationControls && _multipleIntermediatePossible
        onClicked: {
            var loc = navigator.locations;
            var i = navigator.hasOrigin ? 1 : 0;
            loc.splice(i, 0, poiAsRoutingDestination);
            navigator.locations = loc;
            finalizeRouting();
        }
    }

    ListItemLabelActive {
        label: _multipleIntermediatePossible ? app.tr("Last intermediate destination") :
                                               app.tr("Intermediate destination")
        labelX: styler.themeHorizontalPageMargin
        visible: navigationControls && navigator.hasDestination
        onClicked: {
            var loc = navigator.locations;
            loc.splice(loc.length-1, 0, poiAsRoutingDestination);
            navigator.locations = loc;
            finalizeRouting();
        }
    }


    Connections {
        target: pois
        onPoiChanged: {
            if (!poiId || item.poiId !== poiId) return;
            item.show(pois.getById(poiId));
        }
    }

    Connections {
        target: map
        onHeightChanged: checkMode()
    }

    onHeightChanged: checkMode()
    on_OptionalHeightChanged: checkMode()

    function checkMode() {
        // check if we have space to show all information
        var h = item.height + 2*styler.themePaddingLarge;
        if (_fullMode && h > map.height)
            _fullMode = false;
        else if (!_fullMode && h + _optionalHeight < map.height)
            _fullMode = true;
    }

    function finalizeRouting() {
        if (navigator.hasDestination)
            navigator.findRoute( false, {"save": true, "fitToView": true} );
        pois.hide();
    }

    function hide() {
        item.visible = false;
        item.active = false;
        item.poiId = "";
        navigationControls = false;
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
        item.email = poi.email || "";
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
