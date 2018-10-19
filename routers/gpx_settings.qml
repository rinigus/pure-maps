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
import "../qml/platform"

Column {
    id: settingsBlock
    spacing: app.styler.themePaddingLarge
    width: parent.width

    property string selectedFile

    ValueButtonPL {
        label: app.tr("File")
        value: selectedFile ? selectedFile : app.tr("None")
        width: parent.width
        onClicked: app.pages.push(filePickerPage)
    }

    Component {
        id: filePickerPage
        FilePickerPL {
            id: picker
            nameFilters: [ '*.gpx' ]
            onSelectedFilepathChanged: {
                settingsBlock.selectedFile = picker.selectedFilepath
                app.conf.set("routers.gpx.file", settingsBlock.selectedFile);
            }
        }
    }

    ComboBoxPL {
        id: typeComboBox
        label: app.tr("Type")
        model: [ app.tr("Car"), app.tr("Bicycle"), app.tr("Foot") ]
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
