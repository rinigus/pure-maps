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
                title: app.tr("Preferences")
            }

            TextSwitch {
                id: downloadTilesItem
                checked: app.conf.get("allow_tile_download")
                description: app.tr("Uncheck to minimize data traffic. You will be left with previously downloaded and cached tiles.")
                text: app.tr("Allow downloading map tiles")
                onCheckedChanged: {
                    var value = downloadTilesItem.checked
                    if (value === app.conf.get("allow_tile_download")) return;
                    app.conf.set("allow_tile_download", value);
                    // Clear tiles to ensure no logo tiles remain.
                    value && map.clearTiles();
                }
            }

            ComboBox {
                id: unitsComboBox
                label: app.tr("Units")
                menu: ContextMenu {
                    MenuItem { text: app.tr("Metric") }
                    MenuItem { text: app.tr("American") }
                    MenuItem { text: app.tr("British") }
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
                description: app.tr("Only applies when Poor Maps is active. When minimized, sleep is controlled by normal device-level preferences.")
                label: app.tr("Prevent sleep")
                menu: ContextMenu {
                    MenuItem { text: app.tr("Never") }
                    MenuItem { text: app.tr("When navigating") }
                    MenuItem { text: app.tr("Always") }
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
                description: app.tr("Limiting tile caching ensures up-to-date maps and keeps disk use under control, but loads maps slower and causes more data traffic.")
                label: app.tr("Cache map tiles")
                menu: ContextMenu {
                    MenuItem { text: app.tr("One week") }
                    MenuItem { text: app.tr("One month") }
                    MenuItem { text: app.tr("One year") }
                    MenuItem { text: app.tr("Forever") }
                }
                property bool ready: false
                property var  values: [7, 30, 365, 36500]
                Component.onCompleted: {
                    // Activate the closest value in case the user has edited the configuration file
                    // by hand using a value outside the combo box steps or used values 90 or 180
                    // supported in Poor Maps < 0.31. Note that this only changes what is displayed,
                    // the actual configuration value is only changed on user input.
                    var value = app.conf.get("cache_max_age");
                    var minIndex = -1, minDiff = 36500;
                    for (var i = 0; i < cacheComboBox.values.length; i++) {
                        var diff = Math.abs(cacheComboBox.values[i] - value);
                        minIndex = diff < minDiff ? i : minIndex;
                        minDiff = Math.min(minDiff, diff);
                    }
                    cacheComboBox.currentIndex = minIndex;
                    cacheComboBox.ready = true;
                }
                onCurrentIndexChanged: {
                    if (!cacheComboBox.ready) return;
                    var index = cacheComboBox.currentIndex;
                    app.conf.set("cache_max_age", cacheComboBox.values[index]);
                }
            }

            Spacer {
                height: Theme.paddingLarge
            }

            Button {
                id: examineButton
                anchors.horizontalCenter: parent.horizontalCenter
                preferredWidth: Theme.buttonWidthLarge
                text: app.tr("Examine map tile cache")
                onClicked: app.pageStack.push("CachePage.qml");
            }

            Spacer {
                height: 2 * Theme.paddingLarge
            }

        }

        VerticalScrollDecorator {}

    }

}
