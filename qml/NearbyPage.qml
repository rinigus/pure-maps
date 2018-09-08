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
    allowedOrientations: app.defaultAllowedOrientations
    canNavigateForward: page.near &&
        (page.nearText !== app.tr("Current position") || gps.ready) &&
        page.query.length > 0

    property var    near: null
    property string nearText: ""
    property string query: ""
    property var    params: {}
    property real   radius: 1000

    // Offer a different selection of radii depending on the user's
    // preferred length units, but keep values as meters.

    property var radiusLabels: app.conf.units === "metric" ?
        ["500 m", "1 km", "2 km", "5 km", "10 km", "20 km", "50 km", "100 km"] :
        [ "¼ mi", "½ mi", "1 mi", "2 mi",  "5 mi", "10 mi", "20 mi",  "40 mi"]

    property var radiusValues: app.conf.units === "metric" ?
        [500, 1000, 2000, 5000, 10000, 20000, 50000, 100000] :
        [402,  805, 1609, 3219,  8047, 16093, 32187,  64374]

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.implicitHeight
        contentWidth: parent.width

        Column {
            id: column
            anchors.fill: parent
            property var settings: null

            PageHeader {
                title: app.tr("Nearby Venues")
            }

            ValueButton {
                id: usingButton
                label: app.tr("Using")
                height: Theme.itemSizeSmall
                value: py.evaluate("poor.app.guide.name")
                width: parent.width
                onClicked: {
                    var dialog = app.pageStack.push("GuidePage.qml");
                    dialog.accepted.connect(function() {
                        usingButton.value = py.evaluate("poor.app.guide.name");
                        column.addSetttings();
                    });
                }
            }

            ValueButton {
                id: nearButton
                label: app.tr("Near")
                height: Theme.itemSizeSmall
                value: page.nearText
                // Avoid putting label and value on different lines.
                width: 3 * parent.width

                BusyIndicator {
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.horizontalPageMargin + (parent.width - page.width)
                    anchors.verticalCenter: parent.verticalCenter
                    running: page.nearText === app.tr("Current position") && !gps.ready
                    size: BusyIndicatorSize.Small
                    z: parent.z + 1
                }

                onClicked: {
                    var dialog = app.pageStack.push("RoutePointPage.qml");
                    dialog.accepted.connect(function() {
                        if (dialog.selectedPoi && dialog.selectedPoi.coordinate) {
                            page.near = [dialog.selectedPoi.coordinate.longitude, dialog.selectedPoi.coordinate.latitude];
                            page.nearText = dialog.selectedPoi.title || app.tr("Unnamed point");
                        } else if (dialog.page === app.tr("Current position")) {
                            page.near = map.getPosition();
                            page.nearText = dialog.query;
                        } else {
                            page.near = dialog.query;
                            page.nearText = dialog.query;
                            py.call_sync("poor.app.history.add_place", [dialog.query]);
                        }
                    });
                }

            }

            ValueButton {
                id: typeButton
                label: app.tr("Type")
                height: Theme.itemSizeSmall
                value: page.query
                // Avoid putting label and value on different lines.
                width: 3 * parent.width
                onClicked: {
                    var dialog = app.pageStack.push("PlaceTypePage.qml");
                    dialog.accepted.connect(function() {
                        page.query = dialog.query;
                    });
                }
            }

            ComboBox {
                id: radiusComboBox
                label: app.tr("Radius")
                menu: ContextMenu {
                    MenuItem { text: page.radiusLabels[0] }
                    MenuItem { text: page.radiusLabels[1] }
                    MenuItem { text: page.radiusLabels[2] }
                    MenuItem { text: page.radiusLabels[3] }
                    MenuItem { text: page.radiusLabels[4] }
                    MenuItem { text: page.radiusLabels[5] }
                    MenuItem { text: page.radiusLabels[6] }
                    MenuItem { text: page.radiusLabels[7] }
                }
                Component.onCompleted: {
                    for (var i = 0; i < page.radiusValues.length; i++) {
                        if (page.radiusValues[i] === page.radius)
                            radiusComboBox.currentIndex = i;
                    }
                }
                onCurrentIndexChanged: {
                    page.radius = page.radiusValues[radiusComboBox.currentIndex];
                }
            }

            Component.onCompleted: column.addSetttings();

            function addSetttings() {
                // Add guide-specific settings from guide's own QML file.
                page.params = {};
                column.settings && column.settings.destroy();
                var uri = py.evaluate("poor.app.guide.settings_qml_uri");
                if (!uri) return;
                var component = Qt.createComponent(uri);
                column.settings = component.createObject(column);
                column.settings.anchors.left = column.left;
                column.settings.anchors.right = column.right;
                column.settings.width = column.width;
            }

        }

        VerticalScrollDecorator {}

    }

    Component.onCompleted: {
        if (!page.near) {
            page.near = map.getPosition();
            page.nearText = app.tr("Current position");
        }
    }

    onQueryChanged: {
        py.call_sync("poor.app.history.add_place_type", [page.query]);
    }

    onStatusChanged: {
        if (page.status === PageStatus.Active) {
            if (page.nearText === app.tr("Current position"))
                page.near = map.getPosition();
            var resultPage = app.pageStack.pushAttached("NearbyResultsPage.qml");
            resultPage.populated = false;
        }
    }

}
