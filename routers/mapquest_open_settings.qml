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
import "../qml/platform"
import "../qml"

FormLayoutPL {
    property bool full: true

    ComboBoxPL {
        id: typeComboBox
        label: app.tr("Type")
        model: [ app.tr("Car"), app.tr("Bicycle"), app.tr("Foot") ]
        property var keys: ["fastest", "bicycle", "pedestrian"]
        Component.onCompleted: {
            var key = app.conf.get("routers.mapquest_open.type");
            typeComboBox.currentIndex = typeComboBox.keys.indexOf(key);
        }
        onCurrentIndexChanged: {
            var key = typeComboBox.keys[typeComboBox.currentIndex];
            app.conf.set("routers.mapquest_open.type", key);
        }
    }

    TextSwitchPL {
        id: tollSwitch
        anchors.left: parent.left
        anchors.right: parent.right
        checked: app.conf.contains("routers.mapquest_open.avoids", "Toll Road")
        text: app.tr("Try to avoid tolls")
        visible: full && typeComboBox.currentIndex === 0
        onCheckedChanged: tollSwitch.checked ?
            app.conf.add("routers.mapquest_open.avoids", "Toll Road") :
            app.conf.remove("routers.mapquest_open.avoids", "Toll Road");
    }

    LanguageSelector {
        id: langComboBox
        key: app.conf.get("routers.mapquest_open.language")
        languages: [
            { "key": "de_DE", "name": app.tr("German (Germany)") },
            { "key": "en_GB", "name": app.tr("English (United Kingdom)") },
            { "key": "en_US", "name": app.tr("English (United States)") },
            { "key": "es_ES", "name": app.tr("Spanish (Spain)") },
            { "key": "es_MX", "name": app.tr("Spanish (Mexico)") },
            { "key": "fr_CA", "name": app.tr("French (Canada)") },
            { "key": "fr_FR", "name": app.tr("French (France)") },
            { "key": "ru_RU", "name": app.tr("Russian (Russia)") }
          ]
        onKeyChanged: app.conf.set("routers.mapquest_open.language", key)
    }
}
