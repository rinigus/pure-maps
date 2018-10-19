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
                app.conf.set("routers.gpx_osmscout.file", settingsBlock.selectedFile);
            }
        }
    }

    ComboBoxPL {
        id: typeComboBox
        label: app.tr("Type")
        model: [ app.tr("Car"), app.tr("Bicycle"), app.tr("Foot"), app.tr("Bus"),
            app.tr("High-occupancy vehicle (HOV)"), app.tr("Motorcycle"), app.tr("Motor Scooter") ]
        property string current_key
        property var keys: ["auto", "bicycle", "pedestrian", "bus", "hov", "motorcycle", "motor_scooter"]
        Component.onCompleted: {
            var key = app.conf.get("routers.gpx_osmscout.type");
            var index = typeComboBox.keys.indexOf(key);
            typeComboBox.currentIndex = index > -1 ? index : 0;
            current_key = typeComboBox.keys[typeComboBox.currentIndex];
        }
        onCurrentIndexChanged: {
            var key = typeComboBox.keys[typeComboBox.currentIndex]
            current_key = key;
            app.conf.set("routers.gpx_osmscout.type", key);
        }
    }

    ComboBoxPL {
        id: langComboBox
        label: app.tr("Language")
        model: [ app.tr("Catalan"), app.tr("Czech"), app.tr("English"), app.tr("English Pirate"),
            app.tr("French"), app.tr("German"), app.tr("Hindi"), app.tr("Italian"), app.tr("Portuguese"),
            app.tr("Russian"), app.tr("Slovenian"), app.tr("Spanish"), app.tr("Swedish") ]
        property var keys: ["ca", "cs", "en", "en-US-x-pirate", "fr", "de", "hi", "it", "pt", "ru", "sl", "es", "sv"]
        Component.onCompleted: {
            var key = app.conf.get("routers.gpx_osmscout.language");
            var index = langComboBox.keys.indexOf(key);
            langComboBox.currentIndex = index > -1 ? index : 2;
        }
        onCurrentIndexChanged: {
            var key = langComboBox.keys[langComboBox.currentIndex]
            app.conf.set("routers.gpx_osmscout.language", key);
        }
    }

    Component.onCompleted: selectedFile = app.conf.get("routers.gpx_osmscout.file")

}
