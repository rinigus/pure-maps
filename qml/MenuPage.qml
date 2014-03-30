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
    SilicaFlickable {
        anchors.fill: parent
        Column {
            anchors.fill: parent
            PageHeader { title: "Poor Maps" }
            ListTitleLabel { text: "Actions" }
            ListItem {
                id: findCurrentPositionItem
                contentHeight: Theme.itemSizeSmall
                ListItemLabel {
                    color: findCurrentPositionItem.highlighted ?
                        Theme.highlightColor : Theme.primaryColor
                    text: "Find current position"
                }
                onClicked: {
                    map.centerOnPosition();
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
                    text: "Map tiles"
                }
                onClicked: app.pageStack.push("TileSourcePage.qml");
            }
            ListItemSwitch {
                id: autoCenterItem
                checked: map.autoCenter
                text: "Auto-center on position"
                onCheckedChanged: {
                    map.autoCenter = autoCenterItem.checked;
                    py.call_sync("poor.conf.set", ["auto_center", map.autoCenter]);
                    map.autoCenter && map.centerOnPosition();
                }
            }
        }
    }
}
