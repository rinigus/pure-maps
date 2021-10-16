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
import "../qml"

FormLayoutPL {
    id: settingsBlock
    spacing: styler.themePaddingLarge

    property bool full: true // ignored for this router
    property string selectedFile
    property string router: "gpx_osmscout"

    ValueButtonPL {
        label: app.tr("File")
        value: selectedFile ? selectedFile : app.tr("None")
        width: parent.width
        onClicked: {
            var dialog = app.pages.push(Qt.resolvedUrl("../qml/platform/FileSelectorPL.qml"),
                                        {"nameFilters": [ '*.gpx' ]});
            dialog.selected.connect(function() {
                selectedFile = dialog.selectedFilepath;
                app.conf.set("routers.gpx_osmscout.file", settingsBlock.selectedFile);
            });
        }
    }

    TextSwitchPL {
        checked: False
        text: app.tr("Reverse")
        Component.onCompleted: checked = app.conf.get("routers.gpx_osmscout.reverse")
        onCheckedChanged: app.conf.set("routers.gpx_osmscout.reverse", checked ? 1 : 0)
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

    LanguageSelector {
        id: langComboBox
        key: app.conf.get("routers." + settingsBlock.router + ".language")
        // list generated using tools/generate-valhalla-lang.py
        languages: [
              { "key": "bg-BG", "name": app.tr("Bulgarian (Bulgaria)") },
              { "key": "ca-ES", "name": app.tr("Catalan (Spain)") },
              { "key": "cs-CZ", "name": app.tr("Czech (Czechia)") },
              { "key": "da-DK", "name": app.tr("Danish (Denmark)") },
              { "key": "de-DE", "name": app.tr("German (Germany)") },
              { "key": "el-GR", "name": app.tr("Greek (Greece)") },
              { "key": "en-GB", "name": app.tr("English (United Kingdom)") },
              { "key": "en-US", "name": app.tr("English (United States)") },
              { "key": "en-US-x-pirate", "name": app.tr("English Pirate") },
              { "key": "es-ES", "name": app.tr("Spanish (Spain)") },
              { "key": "et-EE", "name": app.tr("Estonian (Estonia)") },
              { "key": "fi-FI", "name": app.tr("Finnish (Finland)") },
              { "key": "fr-FR", "name": app.tr("French (France)") },
              { "key": "hi-IN", "name": app.tr("Hindi (India)") },
              { "key": "hu-HU", "name": app.tr("Hungarian (Hungary)") },
              { "key": "it-IT", "name": app.tr("Italian (Italy)") },
              { "key": "ja-JP", "name": app.tr("Japanese (Japan)") },
              { "key": "nb-NO", "name": app.tr("Norwegian Bokmål (Norway)") },
              { "key": "nl-NL", "name": app.tr("Dutch (Netherlands)") },
              { "key": "pl-PL", "name": app.tr("Polish (Poland)") },
              { "key": "pt-BR", "name": app.tr("Portuguese (Brazil)") },
              { "key": "pt-PT", "name": app.tr("Portuguese (Portugal)") },
              { "key": "ro-RO", "name": app.tr("Romanian (Romania)") },
              { "key": "ru-RU", "name": app.tr("Russian (Russia)") },
              { "key": "sk-SK", "name": app.tr("Slovak (Slovakia)") },
              { "key": "sl-SI", "name": app.tr("Slovenian (Slovenia)") },
              { "key": "sv-SE", "name": app.tr("Swedish (Sweden)") },
              { "key": "tr-TR", "name": app.tr("Turkish (Turkey)") },
              { "key": "uk-UA", "name": app.tr("Ukrainian (Ukraine)") }
          ]
        visible: full
        onKeyChanged: app.conf.set("routers." + settingsBlock.router + ".language", key)
    }

    Component.onCompleted: selectedFile = app.conf.get("routers.gpx_osmscout.file")

}
