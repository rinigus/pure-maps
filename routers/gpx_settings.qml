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
import Sailfish.Silica 1.0
import Sailfish.Pickers 1.0

Column {
    id: settingsBlock

    property string selectedFile

    ValueButton {
        anchors.horizontalCenter: parent.horizontalCenter
        label: app.tr("File")
        value: selectedFile ? selectedFile : app.tr("None")
        onClicked: pageStack.push(filePickerPage)
    }

    Component {
        id: filePickerPage
        FilePickerPage {
            nameFilters: [ '*.gpx' ]
            onSelectedContentPropertiesChanged: {
                settingsBlock.selectedFile = selectedContentProperties.filePath
                app.conf.set("routers.gpx.file", settingsBlock.selectedFile);
            }
        }
    }

    ComboBox {
        id: typeComboBox
        label: app.tr("Type")
        menu: ContextMenu {
            MenuItem { text: app.tr("Car") }
            MenuItem { text: app.tr("Bicycle") }
            MenuItem { text: app.tr("Foot") }
        }
        property string current_key
        property var keys: ["car", "bicycle", "foot"]
        Component.onCompleted: {
            var key = app.conf.get("routers.gpx.type");
            var index = typeComboBox.keys.indexOf(key);
            typeComboBox.currentIndex = index > -1 ? index : 0;
            current_key = typeComboBox.keys[typeComboBox.currentIndex];
        }
        onCurrentIndexChanged: {
            var key = typeComboBox.keys[typeComboBox.currentIndex]
            current_key = key;
            app.conf.set("routers.gpx.type", key);
        }
    }

    Component.onCompleted: selectedFile = app.conf.get("routers.gpx.file")

}
