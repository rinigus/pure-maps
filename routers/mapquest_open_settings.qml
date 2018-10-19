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

Column {

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
        visible: typeComboBox.currentIndex === 0
        onCheckedChanged: tollSwitch.checked ?
            app.conf.add("routers.mapquest_open.avoids", "Toll Road") :
            app.conf.remove("routers.mapquest_open.avoids", "Toll Road");
    }

    ComboBoxPL {
        id: langComboBox
        label: app.tr("Language")
        // XXX: We need something more complicated here in order to
        // have the languages in alphabetical order after translation.
        model: [ app.tr("English (UK)"), app.tr("English (US)"), app.tr("French (Canada)"),
            app.tr("French (France)"), app.tr("German"), app.tr("Russian"), app.tr("Spanish (Mexico)"),
            app.tr("Spanish (Spain)") ]
        property var keys: ["en_GB", "en_US", "fr_CA", "fr_FR", "de_DE", "ru_RU", "es_MX", "es_ES"]
        Component.onCompleted: {
            var key = app.conf.get("routers.mapquest_open.language");
            var index = langComboBox.keys.indexOf(key);
            langComboBox.currentIndex = index > -1 ? index : 1;
        }
        onCurrentIndexChanged: {
            var key = langComboBox.keys[langComboBox.currentIndex];
            app.conf.set("routers.mapquest_open.language", key);
        }
    }

}
