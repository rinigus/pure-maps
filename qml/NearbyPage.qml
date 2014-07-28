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
import "."

Page {
    id: page
    allowedOrientations: Orientation.All
    canNavigateForward: page.near && page.query != ""
    property var near: null
    property string nearText: ""
    property string query: ""
    property var radius: 1000
    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.implicitHeight
        contentWidth: parent.width
        Column {
            id: column
            anchors.fill: parent
            PageHeader { title: "Find Nearby" }
            ValueButton {
                id: usingButton
                label: "Using"
                height: Theme.itemSizeSmall
                value: py.evaluate("poor.app.guide.name")
                width: parent.width
                onClicked: {
                    var dialog = app.pageStack.push("GuidePage.qml");
                    dialog.accepted.connect(function() {
                        usingButton.value = py.evaluate("poor.app.guide.name");
                    });
                }
            }
            ValueButton {
                id: nearButton
                label: "Near"
                height: Theme.itemSizeSmall
                value: page.nearText
                // Avoid putting label and value on different lines.
                width: 3*parent.width
                onClicked: {
                    var dialog = app.pageStack.push("RoutePointPage.qml");
                    dialog.accepted.connect(function() {
                        page.nearText = dialog.query;
                    });
                }
            }
            ValueButton {
                id: typeButton
                label: "Type"
                height: Theme.itemSizeSmall
                value: page.query
                // Avoid putting label and value on different lines.
                width: 3*parent.width
                onClicked: {
                    var dialog = app.pageStack.push("PlaceTypePage.qml");
                    dialog.accepted.connect(function() {
                        page.query = dialog.query;
                    });
                }
            }
            ComboBox {
                id: radiusComboBox
                label: "Radius"
                menu: ContextMenu {
                    MenuItem { text:  "1 km" }
                    MenuItem { text:  "2 km" }
                    MenuItem { text:  "5 km" }
                    MenuItem { text: "10 km" }
                    MenuItem { text: "20 km" }
                    MenuItem { text: "50 km" }
                }
                property var radii: [1000, 2000, 5000, 10000, 20000, 50000]
                Component.onCompleted: {
                    for (var i = 0; i < radiusComboBox.radii.length; i++) {
                        if (radiusComboBox.radii[i] == page.radius)
                            radiusComboBox.currentIndex = i;
                    }
                }
                onCurrentIndexChanged: {
                    page.radius = radiusComboBox.radii[radiusComboBox.currentIndex];
                }
            }
        }
        VerticalScrollDecorator {}
    }
    Component.onCompleted: {
        page.near = map.getPosition();
        page.nearText = "Current position";
    }
    onNearTextChanged: {
        if (page.nearText == "Current position") {
            page.near = map.getPosition();
        } else {
            page.near = page.nearText;
            py.call_sync("poor.app.history.add_place", [page.nearText]);
        }
    }
    onQueryChanged: {
        py.call_sync("poor.app.history.add_place_type", [page.query]);
    }
}
