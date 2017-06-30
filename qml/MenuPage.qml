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
import QtPositioning 5.3
import Sailfish.Silica 1.0
import "."

Page {
    id: page
    allowedOrientations: app.defaultAllowedOrientations

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.implicitHeight
        contentWidth: parent.width

        Column {
            id: column
            anchors.fill: parent

            PageHeader {
                title: "Poor Maps"
            }

            IconListItem {
                icon: "image://theme/icon-m-search"
                label: qsTranslate("", "Search")
                onClicked: {
                    app.pageStack.push("GeocodePage.qml");
                    app.pageStack.pushAttached("GeocodingResultsPage.qml");
                }
            }

            IconListItem {
                icon: "image://theme/icon-m-car"
                label: qsTranslate("", "Navigation")
                onClicked: {
                    app.pageStack.push("RoutePage.qml");
                }
            }

            IconListItem {
                icon: "image://theme/icon-m-whereami"
                label: qsTranslate("", "Nearby venues")
                onClicked: {
                    app.pageStack.push("NearbyPage.qml");
                }
            }

            IconListItem {
                icon: "image://theme/icon-m-share"
                label: qsTranslate("", "Share current position")
                BusyIndicator {
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.horizontalPageMargin
                    anchors.verticalCenter: parent.verticalCenter
                    running: !gps.ready
                    size: BusyIndicatorSize.Small
                    z: parent.z + 1
                }
                onClicked: {
                    if (!gps.ready) return;
                    app.pageStack.push("SharePage.qml", {
                        "coordinate": QtPositioning.coordinate(
                            gps.position.coordinate.latitude,
                            gps.position.coordinate.longitude),
                        "title": qsTranslate("", "Share Current Position")
                    });
                }
            }

            IconListItem {
                icon: "image://theme/icon-m-dot"
                label: qsTranslate("", "Center on current position")
                onClicked: {
                    map.centerOnPosition();
                    app.clearMenu();
                }
            }

            IconListItem {
                icon: "image://theme/icon-m-clear"
                label: qsTranslate("", "Clear map")
                onClicked: {
                    map.clear();
                    app.clearMenu();
                }
            }

            IconListItem {
                icon: "image://theme/icon-m-levels"
                label: qsTranslate("", "Basemaps and overlays")
                onClicked: {
                    app.pageStack.push("BasemapPage.qml");
                }
            }

            TextSwitch {
                id: autoCenterItem
                checked: map.autoCenter
                height: Theme.itemSizeSmall
                leftMargin: Theme.horizontalPageMargin + Theme.paddingLarge + Theme.paddingSmall
                text: qsTranslate("", "Auto-center on position")
                Component.onCompleted: {
                    page.onStatusChanged.connect(function() {
                        autoCenterItem.checked = map.autoCenter;
                    });
                }
                onCheckedChanged: {
                    map.autoCenter = autoCenterItem.checked;
                    map.autoCenter && map.centerOnPosition();
                }
            }

            TextSwitch {
                id: autoRotateItem
                checked: map.autoRotate
                height: Theme.itemSizeSmall
                leftMargin: Theme.horizontalPageMargin + Theme.paddingLarge + Theme.paddingSmall
                text: qsTranslate("", "Auto-rotate on direction")
                Component.onCompleted: {
                    page.onStatusChanged.connect(function() {
                        autoRotateItem.checked = map.autoRotate;
                    });
                }
                onCheckedChanged: {
                    map.autoRotate = autoRotateItem.checked;
                }
            }

        }

        PullDownMenu {
            MenuItem {
                text: qsTranslate("", "About")
                onClicked: app.pageStack.push("AboutPage.qml");
            }
            MenuItem {
                text: qsTranslate("", "Preferences")
                onClicked: app.pageStack.push("PreferencesPage.qml");
            }
        }

        VerticalScrollDecorator {}

    }

}
