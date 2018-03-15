/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2018 Osmo Salomaa
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
    allowedOrientations: app.defaultAllowedOrientations

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.implicitHeight
        contentWidth: parent.width

        Column {
            id: column
            anchors.fill: parent

            PageHeader {
                title: app.tr("Attribution")
            }

            SectionHeader {
                text: app.tr("Maps")
                visible: mapRepeater.model > 0
            }

            Repeater {
                id: mapRepeater
                model: items.length
                property var items: py.evaluate("poor.app.basemap.attribution")
                delegate: ListItem {
                    id: listItem
                    contentHeight: Theme.itemSizeSmall
                    property var item: mapRepeater.items[index]
                    ListItemLabel {
                        color: listItem.highlighted ?
                            Theme.highlightColor : Theme.primaryColor;
                        height: Theme.itemSizeSmall
                        text: item.text || ""
                    }
                    onClicked: item.url &&
                        Qt.openUrlExternally(item.url);
                }
            }

            SectionHeader {
                text: app.tr("Search")
                visible: geocodeRepeater.model > 0
            }

            Repeater {
                id: geocodeRepeater
                model: items.length
                property var items: py.call_sync(
                    "poor.app.get_attribution",
                    ["geocoder", map.getPoiProviders("geocode")])
                delegate: ListItem {
                    id: listItem
                    contentHeight: Theme.itemSizeSmall
                    property var item: geocodeRepeater.items[index]
                    ListItemLabel {
                        color: listItem.highlighted ?
                            Theme.highlightColor : Theme.primaryColor;
                        height: Theme.itemSizeSmall
                        text: item.text || ""
                    }
                    onClicked: item.url &&
                        Qt.openUrlExternally(item.url);
                }
            }

            SectionHeader {
                text: app.tr("Venues")
                visible: venueRepeater.model > 0
            }

            Repeater {
                id: venueRepeater
                model: items.length
                property var items: py.call_sync(
                    "poor.app.get_attribution",
                    ["guide", map.getPoiProviders("venue")])
                delegate: ListItem {
                    id: listItem
                    contentHeight: Theme.itemSizeSmall
                    property var item: venueRepeater.items[index]
                    ListItemLabel {
                        color: listItem.highlighted ?
                            Theme.highlightColor : Theme.primaryColor;
                        height: Theme.itemSizeSmall
                        text: item.text || ""
                    }
                    onClicked: item.url &&
                        Qt.openUrlExternally(item.url);
                }
            }

            SectionHeader {
                text: app.tr("Navigation")
                visible: routeRepeater.model > 0
            }

            Repeater {
                id: routeRepeater
                model: items.length
                property var items: map.route && map.route.provider ?
                    py.call_sync("poor.app.get_attribution", ["router", [map.route.provider]]) : []
                delegate: ListItem {
                    id: listItem
                    contentHeight: Theme.itemSizeSmall
                    property var item: routeRepeater.items[index]
                    ListItemLabel {
                        color: listItem.highlighted ?
                            Theme.highlightColor : Theme.primaryColor;
                        height: Theme.itemSizeSmall
                        text: item.text || ""
                    }
                    onClicked: item.url &&
                        Qt.openUrlExternally(item.url);
                }
            }

        }

        VerticalScrollDecorator {}

    }

}
