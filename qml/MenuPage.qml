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
import "."
import "platform"

PagePL {
    id: page
    title: "Pure Maps"

    pageMenu: PageMenuPL {
        PageMenuItemPL {
            text: app.tr("About")
            onClicked: app.push(Qt.resolvedUrl("AboutPage.qml"))
        }
    }

    // To make TextSwitch text line up with IconListItem's text label.
    property real switchLeftMargin: app.styler.themeHorizontalPageMargin + app.styler.themePaddingLarge + app.styler.themePaddingSmall

    Column {
        id: column
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width

        IconListItem {
            icon: app.styler.iconSearch
            label: app.tr("Search")
            onClicked: app.pushMain(Qt.resolvedUrl("GeocodePage.qml"))
        }

        IconListItem {
            icon: app.styler.iconNavigate
            label: app.tr("Navigation")
            onClicked: app.pushMain(Qt.resolvedUrl("RoutePage.qml"))
        }

        IconListItem {
            icon: app.styler.iconNearby
            label: app.tr("Nearby venues")
            onClicked: app.pushMain(Qt.resolvedUrl("NearbyPage.qml"))
        }

        IconListItem {
            icon: app.styler.iconFavorite
            label: app.tr("Bookmarks")
            onClicked: app.pushMain(Qt.resolvedUrl("PoiPage.qml"))
        }

        IconListItem {
            icon: app.styler.iconShare
            label: app.tr("Share current position")
            BusyIndicatorSmallPL {
                anchors.right: parent.right
                anchors.rightMargin: app.styler.themeHorizontalPageMargin
                anchors.verticalCenter: parent.verticalCenter
                running: !gps.ready
                z: parent.z + 1
            }
            onClicked: {
                if (!gps.ready) return;
                var y = gps.position.coordinate.latitude;
                var x = gps.position.coordinate.longitude;
                app.push(Qt.resolvedUrl("SharePage.qml"), {
                             "coordinate": QtPositioning.coordinate(y, x),
                             "title": app.tr("Share Current Position"),
                         });
            }
        }

        IconListItem {
            icon: app.styler.iconDot
            label: app.tr("Center on current position")
            onClicked: {
                app.map.centerOnPosition();
                app.showMap();
            }
        }

        IconListItem {
            icon: app.styler.iconMaps
            label: app.tr("Maps")
            onClicked: app.pushMain(Qt.resolvedUrl("BasemapPage.qml"))
        }

        IconListItem {
            icon: app.styler.iconPreferences
            label: app.tr("Preferences")
            onClicked: app.push(Qt.resolvedUrl("PreferencesPage.qml"))
        }

        // We use icon+combobox only here, hence no separate class
        ListItemPL {
            id: item
            anchors.left: parent.left
            anchors.right: parent.right
            contentHeight: Math.max(app.styler.themeItemSizeSmall, profileComboBox.height)

            Image {
                id: icon
                anchors.left: parent.left
                anchors.leftMargin: app.styler.themeHorizontalPageMargin
                anchors.verticalCenter: label.verticalCenter
                fillMode: Image.PreserveAspectFit
                height: app.styler.themeItemSizeSmall*0.8
                source: app.styler.iconProfile
            }

            LabelPL {
                id: label
                anchors.left: icon.right
                anchors.leftMargin: app.styler.themePaddingMedium
                color: {
                    if (!item.enabled) return app.styler.themeSecondaryHighlightColor;
                    if (item.highlighted) return app.styler.themeHighlightColor;
                    return app.styler.themePrimaryColor;
                }
                height: app.styler.themeItemSizeSmall
                text: app.tr("Profile")
                truncMode: truncModes.fade
                verticalAlignment: Text.AlignVCenter
            }

            ComboBoxPL {
                id: profileComboBox
                anchors.left: label.right
                anchors.leftMargin: app.styler.themePaddingMedium
                anchors.right: parent.right
                anchors.top: parent.top
                model: [ app.tr("Online"), app.tr("Offline"), app.tr("Mixed") ]
                property var values: ["online", "offline", "mixed"]
                Component.onCompleted: {
                    var value = app.conf.profile;
                    profileComboBox.currentIndex = profileComboBox.values.indexOf(value);
                }
                onCurrentIndexChanged: {
                    var index = profileComboBox.currentIndex;
                    py.call_sync("poor.app.set_profile", [profileComboBox.values[index]]);
                }
            }

            onClicked: profileComboBox.activate()
        }

        TextSwitchPL {
            id: autoCenterItem
            checked: app.map.autoCenter
            height: app.styler.themeItemSizeSmall
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

        TextSwitchPL {
            id: autoRotateItem
            checked: app.map.autoRotate
            height: app.styler.themeItemSizeSmall
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
}
