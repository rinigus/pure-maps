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
    allowedOrientations: app.defaultAllowedOrientations

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.implicitHeight
        contentWidth: parent.width

        Column {
            id: column
            anchors.fill: parent

            PageHeader {
                title: qsTranslate("", "Preferences")
            }

            TextSwitch {
                id: downloadTilesItem
                checked: app.conf.get("allow_tile_download")
                description: qsTranslate("", "Uncheck to minimize data traffic. You will be left with previously downloaded and cached tiles.")
                text: qsTranslate("", "Allow downloading map tiles")
                onCheckedChanged: {
                    var value = downloadTilesItem.checked
                    if (value === app.conf.get("allow_tile_download")) return;
                    app.conf.set("allow_tile_download", value);
                    // Clear tiles to ensure no logo tiles remain.
                    value && map.clearTiles();
                }
            }

            TextSwitch {
                id: showNarrativeItem
                checked: map.showNarrative
                text: qsTranslate("", "Show navigation narrative")
                onCheckedChanged: {
                    map.showNarrative = showNarrativeItem.checked;
                    app.conf.set("show_routing_narrative", map.showNarrative);
                    map.showNarrative || app.setNavigationStatus(null);
                }
            }

            ComboBox {
                id: unitsComboBox
                label: qsTranslate("", "Units")
                menu: ContextMenu {
                    MenuItem { text: qsTranslate("", "Metric") }
                    MenuItem { text: qsTranslate("", "American") }
                    MenuItem { text: qsTranslate("", "British") }
                }
                property var values: ["metric", "american", "british"]
                Component.onCompleted: {
                    var value = app.conf.get("units");
                    unitsComboBox.currentIndex = unitsComboBox.values.indexOf(value);
                }
                onCurrentIndexChanged: {
                    var index = unitsComboBox.currentIndex;
                    app.conf.set("units", unitsComboBox.values[index]);
                    app.scaleBar.update(true);
                }
            }

            ComboBox {
                id: sleepComboBox
                description: qsTranslate("", "Only applies when Poor Maps is active. When minimized, sleep is controlled by normal device-level preferences.")
                label: qsTranslate("", "Prevent sleep")
                menu: ContextMenu {
                    MenuItem { text: qsTranslate("", "Never") }
                    MenuItem { text: qsTranslate("", "When navigating") }
                    MenuItem { text: qsTranslate("", "Always") }
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
                description: qsTranslate("", "Limiting tile caching ensures up-to-date maps and keeps disk use under control, but loads maps slower and causes more data traffic.")
                label: qsTranslate("", "Cache map tiles")
                menu: ContextMenu {
                    MenuItem { text: qsTranslate("", "For one week") }
                    MenuItem { text: qsTranslate("", "For one month") }
                    MenuItem { text: qsTranslate("", "For three months") }
                    MenuItem { text: qsTranslate("", "For six months") }
                    MenuItem { text: qsTranslate("", "For one year") }
                    MenuItem { text: qsTranslate("", "Forever") }
                }
                property var values: [7, 30, 90, 180, 365, 36500]
                Component.onCompleted: {
                    // Activate closest in case the user has edited the configuration file
                    // by hand using a value outside the combo box steps.
                    var value = app.conf.get("cache_max_age");
                    var minIndex = -1, minDiff = 36500;
                    for (var i = 0; i < cacheComboBox.values.length; i++) {
                        var diff = Math.abs(cacheComboBox.values[i] - value);
                        minIndex = diff < minDiff ? i : minIndex;
                        minDiff = Math.min(minDiff, diff);
                    }
                    cacheComboBox.currentIndex = minIndex;
                }
                onCurrentIndexChanged: {
                    var index = cacheComboBox.currentIndex;
                    app.conf.set("cache_max_age", cacheComboBox.values[index]);
                }
            }

            Spacer {
                height: Theme.paddingMedium
            }

            Button {
                id: examineButton
                anchors.horizontalCenter: parent.horizontalCenter
                preferredWidth: Theme.buttonWidthLarge
                text: qsTranslate("", "Examine map tile cache")
                onClicked: app.pageStack.push("CachePage.qml");
            }

            Spacer {
                height: Theme.paddingMedium
            }

        }

        VerticalScrollDecorator {}

    }

}
