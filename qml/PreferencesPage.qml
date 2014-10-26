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
                property var keys: ["never", "navigating", "always"]
                Component.onCompleted: {
                    var key = py.evaluate("poor.conf.keep_alive");
                    sleepComboBox.currentIndex = sleepComboBox.keys.indexOf(key);
                }
                onCurrentIndexChanged: {
                    var value = sleepComboBox.keys[sleepComboBox.currentIndex];
                    py.call_sync("poor.conf.set", ["keep_alive", value]);
                    app.updateKeepAlive();
                }
            }
        }
        VerticalScrollDecorator {}
    }
}
