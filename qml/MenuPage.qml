/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2014 Osmo Salomaa
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

Page {
    id: page
    allowedOrientations: ~Orientation.PortraitInverse
    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.implicitHeight
        contentWidth: parent.width
        Column {
            id: column
            anchors.fill: parent
            PageHeader { title: "Poor Maps" }
            ListItem {
                id: searchItem
                contentHeight: Theme.itemSizeSmall
                Image {
                    id: searchImage
                    fillMode: Image.Pad
                    height: Theme.itemSizeSmall
                    horizontalAlignment: Image.AlignRight
                    source: "image://theme/icon-m-search"
                    width: implicitWidth + Theme.paddingLarge
                }
                ListItemLabel {
                    anchors.left: searchImage.right
                    anchors.leftMargin: Theme.paddingMedium
                    color: searchItem.highlighted ?
                        Theme.highlightColor : Theme.primaryColor
                    height: Theme.itemSizeSmall
                    text: "Search"
                }
                onClicked: {
                    app.pageStack.push("GeocodePage.qml");
                    app.pageStack.pushAttached("GeocodingResultsPage.qml");
                }
            }
            ListItem {
                id: navigationItem
                contentHeight: Theme.itemSizeSmall
                Image {
                    id: navigationImage
                    fillMode: Image.Pad
                    height: Theme.itemSizeSmall
                    horizontalAlignment: Image.AlignRight
                    source: "image://theme/icon-m-car"
                    width: implicitWidth + Theme.paddingLarge
                }
                ListItemLabel {
                    anchors.left: navigationImage.right
                    anchors.leftMargin: Theme.paddingMedium
                    color: navigationItem.highlighted ?
                        Theme.highlightColor : Theme.primaryColor
                    height: Theme.itemSizeSmall
                    text: "Navigation"
                }
                onClicked: app.pageStack.push("RoutePage.qml");
            }
            ListItem {
                id: findNearbyItem
                contentHeight: Theme.itemSizeSmall
                Image {
                    id: findNearbyImage
                    fillMode: Image.Pad
                    height: Theme.itemSizeSmall
                    horizontalAlignment: Image.AlignRight
                    source: "icons/nearby.png"
                    width: implicitWidth + Theme.paddingLarge
                }
                ListItemLabel {
                    anchors.left: findNearbyImage.right
                    anchors.leftMargin: Theme.paddingMedium
                    color: findNearbyItem.highlighted ?
                        Theme.highlightColor : Theme.primaryColor
                    height: Theme.itemSizeSmall
                    text: "Nearby venues"
                }
                onClicked: {
                    app.pageStack.push("NearbyPage.qml");
                    app.pageStack.pushAttached("NearbyResultsPage.qml");
                }
            }
            ListItem {
                id: findCurrentPositionItem
                contentHeight: Theme.itemSizeSmall
                Image {
                    id: findCurrentPositionImage
                    fillMode: Image.Pad
                    height: Theme.itemSizeSmall
                    horizontalAlignment: Image.AlignRight
                    source: "icons/center-position.png"
                    width: implicitWidth + Theme.paddingLarge
                }
                ListItemLabel {
                    anchors.left: findCurrentPositionImage.right
                    anchors.leftMargin: Theme.paddingMedium
                    color: findCurrentPositionItem.highlighted ?
                        Theme.highlightColor : Theme.primaryColor
                    height: Theme.itemSizeSmall
                    text: "Center on current position"
                }
                onClicked: {
                    map.centerOnPosition();
                    app.clearMenu();
                }
            }
            ListItem {
                id: shareCurrentPositionItem
                contentHeight: Theme.itemSizeSmall
                Image {
                    id: shareCurrentPositionImage
                    fillMode: Image.Pad
                    height: Theme.itemSizeSmall
                    horizontalAlignment: Image.AlignRight
                    smooth: true
                    source: "image://theme/icon-m-share"
                    width: implicitWidth + Theme.paddingLarge
                }
                ListItemLabel {
                    anchors.left: shareCurrentPositionImage.right
                    anchors.leftMargin: Theme.paddingMedium
                    color: shareCurrentPositionItem.highlighted ?
                        Theme.highlightColor : Theme.primaryColor
                    height: Theme.itemSizeSmall
                    text: "Share current position"
                }
                onClicked: app.pageStack.push("SharePage.qml", {
                    "coordinate": QtPositioning.coordinate(
                        gps.position.coordinate.latitude,
                        gps.position.coordinate.longitude),
                    "title": "Share Current Position"
                });
            }
            ListItem {
                id: clearMapItem
                contentHeight: Theme.itemSizeSmall
                Image {
                    id: clearMapImage
                    fillMode: Image.Pad
                    height: Theme.itemSizeSmall
                    horizontalAlignment: Image.AlignRight
                    source: "image://theme/icon-m-clear"
                    width: implicitWidth + Theme.paddingLarge
                }
                ListItemLabel {
                    anchors.left: clearMapImage.right
                    anchors.leftMargin: Theme.paddingMedium
                    color: clearMapItem.highlighted ?
                        Theme.highlightColor : Theme.primaryColor
                    height: Theme.itemSizeSmall
                    text: "Clear map"
                }
                onClicked: {
                    map.clear();
                    app.clearMenu();
                }
            }
            ListItem {
                id: basemapItem
                contentHeight: Theme.itemSizeSmall
                Image {
                    id: basemapImage
                    fillMode: Image.Pad
                    height: Theme.itemSizeSmall
                    horizontalAlignment: Image.AlignRight
                    source: "image://theme/icon-m-levels"
                    width: implicitWidth + Theme.paddingLarge
                }
                ListItemLabel {
                    anchors.left: basemapImage.right
                    anchors.leftMargin: Theme.paddingMedium
                    color: basemapItem.highlighted ?
                        Theme.highlightColor : Theme.primaryColor
                    height: Theme.itemSizeSmall
                    text: "Basemaps"
                }
                onClicked: app.pageStack.push("BasemapPage.qml");
            }
            ListItem {
                id: overlayItem
                contentHeight: Theme.itemSizeSmall
                Image {
                    id: overlayImage
                    fillMode: Image.Pad
                    height: Theme.itemSizeSmall
                    horizontalAlignment: Image.AlignRight
                    opacity: 0.5
                    source: "image://theme/icon-m-levels"
                    width: implicitWidth + Theme.paddingLarge
                }
                ListItemLabel {
                    anchors.left: overlayImage.right
                    anchors.leftMargin: Theme.paddingMedium
                    color: overlayItem.highlighted ?
                        Theme.highlightColor : Theme.primaryColor
                    height: Theme.itemSizeSmall
                    text: "Overlays"
                }
                onClicked: app.pageStack.push("OverlayPage.qml");
            }
            TextSwitch {
                id: autoCenterItem
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingLarge + Theme.paddingSmall
                checked: map.autoCenter
                height: Theme.itemSizeSmall
                text: "Auto-center on position"
                Component.onCompleted: {
                    page.onStatusChanged.connect(function() {
                        autoCenterItem.checked = map.autoCenter;
                    });
                }
                onCheckedChanged: {
                    map.autoCenter = autoCenterItem.checked;
                    map.autoCenter && map.centerOnPosition();
                }
            }
            TextSwitch {
                id: autoRotateItem
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingLarge + Theme.paddingSmall
                checked: map.autoRotate
                height: Theme.itemSizeSmall
                text: "Auto-rotate on bearing"
                Component.onCompleted: {
                    page.onStatusChanged.connect(function() {
                        autoRotateItem.checked = map.autoRotate;
                    });
                }
                onCheckedChanged: {
                    map.autoRotate = autoRotateItem.checked;
                }
            }
            ListItem {
                id: preferencesItem
                contentHeight: Theme.itemSizeSmall
                ListItemLabel {
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingLarge + 64 + Theme.paddingMedium
                    color: preferencesItem.highlighted ?
                        Theme.highlightColor : Theme.primaryColor
                    height: Theme.itemSizeSmall
                    text: "Preferences"
                }
                onClicked: app.pageStack.push("PreferencesPage.qml");
            }
        }
        VerticalScrollDecorator {}
    }
}
