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
import Sailfish.Silica 1.0
import "."

Page {
    allowedOrientations: Orientation.All
    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.implicitHeight
        contentWidth: parent.width
        Column {
            id: column
            anchors.fill: parent
            PageHeader { title: "Poor Maps" }
            ListTitleLabel { text: "Actions" }
            ListItem {
                id: findPlaceItem
                contentHeight: Theme.itemSizeSmall
                ListItemLabel {
                    color: findPlaceItem.highlighted ?
                        Theme.highlightColor : Theme.primaryColor
                    height: Theme.itemSizeSmall
                    text: "Find place"
                }
                onClicked: {
                    app.pageStack.push("GeocodePage.qml");
                    app.pageStack.pushAttached("GeocodingResultsPage.qml");
                }
            }
            ListItem {
                id: findRouteItem
                contentHeight: Theme.itemSizeSmall
                ListItemLabel {
                    color: findRouteItem.highlighted ?
                        Theme.highlightColor : Theme.primaryColor
                    height: Theme.itemSizeSmall
                    text: "Find route"
                }
                onClicked: app.pageStack.push("RoutePage.qml");
            }
            ListItem {
                id: findCurrentPositionItem
                contentHeight: Theme.itemSizeSmall
                ListItemLabel {
                    color: findCurrentPositionItem.highlighted ?
                        Theme.highlightColor : Theme.primaryColor
                    height: Theme.itemSizeSmall
                    text: "Find current position"
                }
                onClicked: {
                    map.centerOnPosition();
                    app.pageStack.pop(mapPage, PageStackAction.Immediate);
                }
            }
            ListItem {
                id: clearMapItem
                contentHeight: Theme.itemSizeSmall
                ListItemLabel {
                    color: clearMapItem.highlighted ?
                        Theme.highlightColor : Theme.primaryColor
                    height: Theme.itemSizeSmall
                    text: "Clear map"
                }
                onClicked: {
                    map.clear();
                    app.pageStack.pop(mapPage, PageStackAction.Immediate);
                }
            }
            ListTitleLabel { text: "Preferences" }
            ListItem {
                id: mapTilesItem
                contentHeight: Theme.itemSizeSmall
                ListItemLabel {
                    color: mapTilesItem.highlighted ?
                        Theme.highlightColor : Theme.primaryColor
                    height: Theme.itemSizeSmall
                    text: "Map tiles"
                }
                onClicked: app.pageStack.push("TileSourcePage.qml");
            }
            ListItemSwitch {
                id: autoCenterItem
                checked: map.autoCenter
                height: Theme.itemSizeSmall
                text: "Auto-center on position"
                onCheckedChanged: {
                    map.setAutoCenter(autoCenterItem.checked);
                    py.call_sync("poor.conf.set", ["auto_center", map.autoCenter]);
                    map.autoCenter && map.centerOnPosition();
                }
            }
            ListItem {
                id: aboutItem
                contentHeight: Theme.itemSizeSmall
                ListItemLabel {
                    color: aboutItem.highlighted ?
                        Theme.highlightColor : Theme.primaryColor
                    height: Theme.itemSizeSmall
                    text: "About Poor Maps"
                }
                onClicked: app.pageStack.push("AboutPage.qml");
            }
        }
        VerticalScrollDecorator {}
    }
}
