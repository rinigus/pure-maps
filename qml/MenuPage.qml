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

    // To make TextSwitch text line up with IconListItem's text label.
    property real switchLeftMargin: Theme.horizontalPageMargin + Theme.paddingLarge + Theme.paddingSmall

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.implicitHeight
        contentWidth: parent.width

        Column {
            id: column
            anchors.fill: parent

            PageHeader {
                title: "Pure Maps"
            }

            IconListItem {
                icon: "image://theme/icon-m-search"
                label: app.tr("Search")
                onClicked: {
                    app.pushMain("GeocodePage.qml");
                    app.pushAttachedMain("GeocodingResultsPage.qml");
                }
            }

            IconListItem {
                icon: "image://theme/icon-m-car"
                label: app.tr("Navigation")
                onClicked: app.pushMain("RoutePage.qml");
            }

            IconListItem {
                icon: "image://theme/icon-m-whereami"
                label: app.tr("Nearby venues")
                onClicked: app.pushMain("NearbyPage.qml");
            }

            IconListItem {
                icon: "image://theme/icon-m-favorite"
                label: app.tr("Points of interest")
                onClicked: app.pushMain("PoiPage.qml");
            }

            IconListItem {
                icon: "image://theme/icon-m-share"
                label: app.tr("Share current position")
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
                    var y = gps.position.coordinate.latitude;
                    var x = gps.position.coordinate.longitude;
                    app.push("SharePage.qml", {
                        "coordinate": QtPositioning.coordinate(y, x),
                        "title": app.tr("Share Current Position"),
                    });
                }
            }

            IconListItem {
                icon: "image://theme/icon-m-dot"
                label: app.tr("Center on current position")
                onClicked: {
                    app.map.centerOnPosition();
                    app.showMap();
                }
            }

            IconListItem {
                icon: "image://theme/icon-m-clear"
                label: app.tr("Clear map")
                onClicked: {
                    if (app.mode !== modes.explore) app.setModeExplore();
                    app.map.clear(true);
                    app.showMap();
                }
            }

            IconListItem {
                icon: "image://theme/icon-m-levels"
                label: app.tr("Maps")
                onClicked: app.pushMain("BasemapPage.qml");
            }

            TextSwitch {
                id: autoCenterItem
                checked: app.map.autoCenter
                height: Theme.itemSizeSmall
                leftMargin: page.switchLeftMargin
                text: app.tr("Auto-center on position")
                Component.onCompleted: {
                    page.onStatusChanged.connect(function() {
                        autoCenterItem.checked = app.map.autoCenter;
                    });
                }
                onCheckedChanged: {
                    app.map.autoCenter = autoCenterItem.checked;
                    app.map.autoCenter && app.map.centerOnPosition();
                }
            }

            TextSwitch {
                id: autoRotateItem
                checked: app.map.autoRotate
                height: Theme.itemSizeSmall
                leftMargin: page.switchLeftMargin
                text: app.tr("Auto-rotate on direction")
                Component.onCompleted: {
                    page.onStatusChanged.connect(function() {
                        autoRotateItem.checked = app.map.autoRotate;
                    });
                }
                onCheckedChanged: {
                    app.map.autoRotate = autoRotateItem.checked;
                }
            }

        }

        PullDownMenu {
            MenuItem {
                text: app.tr("About")
                onClicked: app.push("AboutPage.qml");
            }
            MenuItem {
                text: app.tr("Preferences")
                onClicked: app.push("PreferencesPage.qml");
            }
        }

        VerticalScrollDecorator {}

    }

}
