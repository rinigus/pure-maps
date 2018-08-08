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
    ValueButton {
        id: nameButton
        label: app.tr("Name")
        height: Theme.itemSizeSmall
        value: ""
        onClicked: {
            var dialog = app.pageStack.push("osmscout_name.qml");
            dialog.accepted.connect(function() {
                nameButton.value = dialog.query;
                page.params.name = dialog.query;
                py.call_sync("poor.app.history.add_place_name", [dialog.query]);
            });
        }

        Component.onCompleted: {
            page.params.name = ""
        }
    }

    TextSwitch {
        id: routeSwitch
        anchors.left: parent.left
        anchors.right: parent.right
        checked: page.params.alongRoute
        text: app.tr("Search along the route")
        visible: map.hasRoute

        function update() {
            if (!map.hasRoute) {
                routeSwitch.checked = false;
            }
            if (routeSwitch.checked) {
                page.params.alongRoute = true;
                page.params.route = { "route_lng": map.route.x, "route_lat": map.route.y };
            } else {
                page.params.alongRoute = false;
            }
        }

        onCheckedChanged: routeSwitch.update()
        Component.onCompleted: routeSwitch.update()
    }

    TextSwitch {
        id: fromRefSwitch
        anchors.left: parent.left
        anchors.right: parent.right
        checked: page.params.fromReference
        text: app.tr("Search starting from the reference point")
        visible: map.hasRoute && routeSwitch.checked

        function update() {
            page.params.fromReference = fromRefSwitch.checked;
        }

        onCheckedChanged: fromRefSwitch.update()
        Component.onCompleted: {
            fromRefSwitch.checked = true;
            fromRefSwitch.update();
        }
    }
}
