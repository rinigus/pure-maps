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
    allowedOrientations: Orientation.Portrait
    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.implicitHeight
        contentWidth: parent.width
        Column {
            id: column
            anchors.fill: parent
            PageHeader { title: "Preferences" }
            ComboBox {
                id: sleepComboBox
                description: "Only applies when Poor Maps is active. When minimized, sleep is controlled by normal device-level preferences."
                label: "Prevent sleep"
                menu: ContextMenu {
                    MenuItem { text: "Never" }
                    MenuItem { text: "When navigating" }
                    MenuItem { text: "Always" }
                }
                property var values: ["never", "navigating", "always"]
                Component.onCompleted: {
                    var value = app.conf.get("keep_alive");
                    sleepComboBox.currentIndex = sleepComboBox.values.indexOf(value);
                }
                onCurrentIndexChanged: {
                    var index = sleepComboBox.currentIndex;
                    app.conf.set("keep_alive", sleepComboBox.values[index]);
                    app.updateKeepAlive();
                }
            }
            ComboBox {
                id: cacheComboBox
                description: "Allowing auto-removal of old tiles will ensure up-to-date maps and will keep disk use under control, but will cause more data traffic."
                label: "Remove map tiles"
                menu: ContextMenu {
                    MenuItem { text: "After one week" }
                    MenuItem { text: "After one month" }
                    MenuItem { text: "After three months" }
                    MenuItem { text: "After six months" }
                    MenuItem { text: "After one year" }
                    MenuItem { text: "Never" }
                }
                property var values: [7, 30, 90, 180, 365, 36500]
                Component.onCompleted: {
                    // Activate closest in case the user has edited the configuration file
                    // by hand using a value outside the combo box steps.
                    var value = app.conf.get("cache_max_age");
                    var minItem = 0;
                    var minDiff = 36500;
                    for (var i = 0; i < cacheComboBox.values.length; i++) {
                        var diff = Math.abs(cacheComboBox.values[i] - value);
                        if (diff < minDiff) {
                            minItem = i;
                            minDiff = diff;
                        }
                    }
                    cacheComboBox.currentIndex = minItem;
                }
                onCurrentIndexChanged: {
                    var index = cacheComboBox.currentIndex;
                    app.conf.set("cache_max_age", cacheComboBox.values[index]);
                }
            }
            ListItem {
                id: examineCacheItem
                contentHeight: Theme.itemSizeSmall
                ListItemLabel {
                    color: examineCacheItem.highlighted ?
                        Theme.highlightColor : Theme.primaryColor
                    height: Theme.itemSizeSmall
                    text: "Examine tile cache"
                }
                onClicked: app.pageStack.push("CachePage.qml");
            }
        }
        VerticalScrollDecorator {}
    }
}
