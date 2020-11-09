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
import "."
import "platform"

PagePL {
    title: app.tr("Attribution")

    Column {
        width: parent.width

        Column {
            width: parent.width

            SectionHeaderPL {
                text: app.tr("Maps")
                visible: mapRepeater.model > 0
            }

            Repeater {
                id: mapRepeater
                model: items.length
                property var items: py.evaluate("poor.app.basemap.attribution")
                delegate: ListItemPL {
                    id: listItem
                    contentHeight: styler.themeItemSizeSmall
                    property var item: mapRepeater.items[index]
                    ListItemLabel {
                        id: li
                        color: listItem.highlighted ?
                                   styler.themeHighlightColor : styler.themePrimaryColor;
                        height: styler.themeItemSizeSmall
                        text: item.text || ""
                    }
                    onClicked: item.url &&
                               Qt.openUrlExternally(item.url);
                }
            }
        }

        Column {
            width: parent.width
            SectionHeaderPL {
                text: app.tr("Search")
                visible: geocodeRepeater.model > 0
            }

            Repeater {
                id: geocodeRepeater
                model: items.length
                property var items: py.call_sync(
                                        "poor.app.get_attribution",
                                        ["geocoder", pois.getProviders("geocode")])
                delegate: ListItemPL {
                    id: listItem
                    contentHeight: styler.themeItemSizeSmall
                    property var item: geocodeRepeater.items[index]
                    ListItemLabel {
                        color: listItem.highlighted ?
                                   styler.themeHighlightColor : styler.themePrimaryColor;
                        height: styler.themeItemSizeSmall
                        text: item.text || ""
                    }
                    onClicked: item.url &&
                               Qt.openUrlExternally(item.url);
                }
            }
        }

        Column {
            width: parent.width
            SectionHeaderPL {
                text: app.tr("Venues")
                visible: venueRepeater.model > 0
            }

            Repeater {
                id: venueRepeater
                model: items.length
                property var items: py.call_sync(
                                        "poor.app.get_attribution",
                                        ["guide", pois.getProviders("venue")])
                delegate: ListItemPL {
                    id: listItem
                    contentHeight: styler.themeItemSizeSmall
                    property var item: venueRepeater.items[index]
                    ListItemLabel {
                        color: listItem.highlighted ?
                                   styler.themeHighlightColor : styler.themePrimaryColor;
                        height: styler.themeItemSizeSmall
                        text: item.text || ""
                    }
                    onClicked: item.url &&
                               Qt.openUrlExternally(item.url);
                }
            }
        }

        Column {
            width: parent.width
            SectionHeaderPL {
                text: app.tr("Navigation")
                visible: routeRepeater.model > 0
            }

            Repeater {
                id: routeRepeater
                model: items.length
                property var items: navigator.provider ?
                                        py.call_sync("poor.app.get_attribution", ["router", [navigator.provider]]) : []
                delegate: ListItemPL {
                    id: listItem
                    contentHeight: styler.themeItemSizeSmall
                    property var item: routeRepeater.items[index]
                    ListItemLabel {
                        color: listItem.highlighted ?
                                   styler.themeHighlightColor : styler.themePrimaryColor;
                        height: styler.themeItemSizeSmall
                        text: item.text || ""
                    }
                    onClicked: item.url &&
                               Qt.openUrlExternally(item.url);
                }
            }
        }
    }
}
