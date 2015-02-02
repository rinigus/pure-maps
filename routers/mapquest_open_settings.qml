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
        label: "Type"
        menu: ContextMenu {
            MenuItem { text: "Car" }
            MenuItem { text: "Bicycle" }
            MenuItem { text: "Pedestrian" }
        }
        property var keys: ["fastest", "bicycle", "pedestrian"]
        Component.onCompleted: {
            var key = app.conf.get("routers.mapquest_open.type");
            typeComboBox.currentIndex = typeComboBox.keys.indexOf(key);
        }
        onCurrentIndexChanged: {
            var option = "routers.mapquest_open.type";
            app.conf.set(option, typeComboBox.keys[typeComboBox.currentIndex]);
        }
    }
    TextSwitch {
        id: tollSwitch
        anchors.left: parent.left
        anchors.right: parent.right
        checked: app.conf.set_contains("routers.mapquest_open.avoids", "Toll Road")
        height: Theme.itemSizeSmall
        text: "Try to avoid tolls"
        visible: typeComboBox.currentIndex == 0
        onCheckedChanged: {
            tollSwitch.checked ?
                app.conf.set_add("routers.mapquest_open.avoids", "Toll Road") :
                app.conf.set_remove("routers.mapquest_open.avoids", "Toll Road");
        }
    }
}
