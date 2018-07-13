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

Column {

    ComboBox {
        id: typeComboBox
        label: app.tr("Type")
        menu: ContextMenu {
            MenuItem { text: app.tr("Car") }
            MenuItem { text: app.tr("Bicycle") }
            MenuItem { text: app.tr("Foot") }
        }
        property var keys: ["auto", "bicycle", "pedestrian"]
        Component.onCompleted: {
            var key = app.conf.get("routers.osmscout.type");
            typeComboBox.currentIndex = typeComboBox.keys.indexOf(key);
        }
        onCurrentIndexChanged: {
            var key = typeComboBox.keys[typeComboBox.currentIndex]
            app.conf.set("routers.osmscout.type", key);
        }
    }

    ComboBox {
        id: langComboBox
        label: app.tr("Language")
        menu: ContextMenu {
            // XXX: We need something more complicated here in order to
            // have the languages in alphabetical order after translation.
            MenuItem { text: app.tr("Catalan") }
            MenuItem { text: app.tr("Czech") }
            MenuItem { text: app.tr("English") }
            MenuItem { text: app.tr("English Pirate") }
            MenuItem { text: app.tr("German") }
            MenuItem { text: app.tr("Hindi") }
            MenuItem { text: app.tr("Italian") }
            MenuItem { text: app.tr("Russian") }
            MenuItem { text: app.tr("Slovenian") }
            MenuItem { text: app.tr("Spanish") }
            MenuItem { text: app.tr("Swedish") }
        }
        property var keys: ["ca", "cs", "en", "en-US-x-pirate", "de", "hi", "it", "ru", "sl", "es", "sv"]
        Component.onCompleted: {
            var key = app.conf.get("routers.osmscout.language");
            var index = langComboBox.keys.indexOf(key);
            langComboBox.currentIndex = index > -1 ? index : 2;
        }
        onCurrentIndexChanged: {
            var key = langComboBox.keys[langComboBox.currentIndex]
            app.conf.set("routers.osmscout.language", key);
        }
    }

}
