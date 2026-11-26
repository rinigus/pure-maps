/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2026 Boris Solodki
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
import pm.platform 1.0
import pm 1.0

FormLayoutPL {
    id: settingsBlock
    spacing: styler.themePaddingLarge

    property bool full: true

    ComboBoxPL {
        id: typeComboBox
        label: app.tr("Type")
        model: [ app.tr("Car"), app.tr("Motorcycle"), app.tr("Bicycle"), app.tr("Foot") ]
        property string current_key
        property var keys: ["car", "motorcycle", "bicycle", "pedestrian"]
        Component.onCompleted: {
            var key = app.conf.get("routers.tomtom.type");
            var index = typeComboBox.keys.indexOf(key);
            typeComboBox.currentIndex = index > -1 ? index : 0;
            current_key = typeComboBox.keys[typeComboBox.currentIndex];
        }
        onCurrentIndexChanged: {
            var key = typeComboBox.keys[typeComboBox.currentIndex]
            current_key = key;
            app.conf.set("routers.tomtom.type", key);
        }
    }

    TextSwitchPL {
        anchors.left: parent.left
        anchors.right: parent.right
        text: app.tr("Traffic")
        visible: full && (typeComboBox.current_key == "car" ||
                          typeComboBox.current_key == "motorcycle")
        Component.onCompleted: checked = app.conf.get("routers.tomtom.traffic")
        onCheckedChanged: {
            if (!visible) return;
            app.conf.set("routers.tomtom.traffic", checked ? 1 : 0);
        }
    }

    TextSwitchPL {
        anchors.left: parent.left
        anchors.right: parent.right
        text: app.tr("Prefer shorter route")
        visible: full
        Component.onCompleted: checked = app.conf.get("routers.tomtom.shorter")
        onCheckedChanged: {
            if (!visible) return;
            app.conf.set("routers.tomtom.shorter", checked ? 1 : 0);
        }
    }

    TextSwitchPL {
        anchors.left: parent.left
        anchors.right: parent.right
        text: app.tr("Avoid tolls")
        visible: full
        Component.onCompleted: checked = app.conf.get("routers.tomtom.avoid_toll")
        onCheckedChanged: {
            if (!visible) return;
            app.conf.set("routers.tomtom.avoid_toll", checked ? 1 : 0);
        }
    }

    TextSwitchPL {
        anchors.left: parent.left
        anchors.right: parent.right
        text: app.tr("Avoid highways")
        visible: full
        Component.onCompleted: checked = app.conf.get("routers.tomtom.avoid_highway")
        onCheckedChanged: {
            if (!visible) return;
            app.conf.set("routers.tomtom.avoid_highway", checked ? 1 : 0);
        }
    }

    TextSwitchPL {
        anchors.left: parent.left
        anchors.right: parent.right
        text: app.tr("Avoid ferries")
        visible: full
        Component.onCompleted: checked = app.conf.get("routers.tomtom.avoid_ferry")
        onCheckedChanged: {
            if (!visible) return;
            app.conf.set("routers.tomtom.avoid_ferry", checked ? 1 : 0);
        }
    }

    TextSwitchPL {
        anchors.left: parent.left
        anchors.right: parent.right
        text: app.tr("Avoid dirt roads")
        visible: full
        Component.onCompleted: checked = app.conf.get("routers.tomtom.avoid_dirt")
        onCheckedChanged: {
            if (!visible) return;
            app.conf.set("routers.tomtom.avoid_dirt", checked ? 1 : 0);
        }
    }
}
