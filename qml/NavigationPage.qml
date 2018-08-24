/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2017 Osmo Salomaa, 2018 Rinigus
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

    property bool partOfNavigationStack: true

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.implicitHeight
        contentWidth: parent.width

        Column {
            id: column
            anchors.fill: parent

            PageHeader {
                title: app.tr("Navigation")
            }

            Row {
                id: row
                height: Math.max(beginItem.height, rerouteItem.height, clearItem.height)
                width: parent.width

                property real contentWidth: width - 2 * Theme.horizontalPageMargin
                property real itemWidth: contentWidth / 3

                ToolItem {
                    id: beginItem
                    width: row.itemWidth + Theme.horizontalPageMargin
                    icon: app.navigationActive ? "image://theme/icon-m-pause" : "image://theme/icon-m-play"
                    text: app.navigationActive ? app.tr("Pause") :
                        (app.navigationStarted ? app.tr("Resume") : app.tr("Begin"))
                    onClicked: {
                        app.navigationActive ? map.endNavigating() : map.beginNavigating();
                        app.hideMenu();
                    }
                }

                ToolItem {
                    id: rerouteItem
                    width: row.itemWidth
                    icon: "image://theme/icon-m-refresh"
                    text: app.tr("Reroute")
                    onClicked: {
                        app.reroute();
                        map.beginNavigating();
                        app.hideMenu();
                    }
                }

                ToolItem {
                    id: clearItem
                    width: row.itemWidth + Theme.horizontalPageMargin
                    icon: "image://theme/icon-m-clear"
                    text: app.tr("Clear")
                    onClicked: {
                        map.endNavigating();
                        map.clearRoute();
                        app.hideMenu();
                    }
                }

            }

            SectionHeader {
                text: app.tr("Status")
            }

            Spacer {
                height: Theme.paddingLarge
            }

            Item {
                id: progress
                anchors.left: parent.left
                anchors.right: parent.right
                height: Theme.paddingSmall
                Rectangle {
                    id: progressTotal
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.horizontalPageMargin
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.horizontalPageMargin
                    color: Theme.primaryColor
                    height: Theme.paddingSmall
                    opacity: 0.15
                    radius: height / 2
                }
                Rectangle {
                    id: progressComplete
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.horizontalPageMargin
                    color: Theme.highlightColor
                    height: Theme.paddingSmall
                    radius: height / 2
                    width: app.navigationStatus.progress * progressTotal.width
                }
            }

            Spacer {
                height: Theme.paddingLarge + Theme.paddingSmall
            }

            Row {
                // Distance and time remaining
                anchors.left: parent.left
                anchors.leftMargin: Theme.horizontalPageMargin
                anchors.right: parent.right
                anchors.rightMargin: Theme.horizontalPageMargin
                height: Theme.itemSizeExtraSmall
                Label {
                    id: remaining1
                    height: Theme.itemSizeExtraSmall
                    text: app.tr("Remaining")
                    truncationMode: TruncationMode.Fade
                    verticalAlignment: Text.AlignVCenter
                    width: parent.width / 3
                }
                Label {
                    anchors.baseline: remaining1.baseline
                    horizontalAlignment: Text.AlignRight
                    text: app.navigationStatus.destDist
                    truncationMode: TruncationMode.Fade
                    width: parent.width / 3
                }
                Label {
                    anchors.baseline: remaining1.baseline
                    horizontalAlignment: Text.AlignRight
                    text: app.navigationStatus.destTime
                    truncationMode: TruncationMode.Fade
                    width: parent.width / 3
                }
            }

            Row {
                // Total distance and time
                anchors.left: parent.left
                anchors.leftMargin: Theme.horizontalPageMargin
                anchors.right: parent.right
                anchors.rightMargin: Theme.horizontalPageMargin
                height: Theme.itemSizeExtraSmall
                Label {
                    id: total1
                    height: Theme.itemSizeExtraSmall
                    text: app.tr("Total")
                    truncationMode: TruncationMode.Fade
                    verticalAlignment: Text.AlignVCenter
                    width: parent.width / 3
                }
                Label {
                    anchors.baseline: total1.baseline
                    horizontalAlignment: Text.AlignRight
                    text: app.navigationStatus.totalDist
                    truncationMode: TruncationMode.Fade
                    width: parent.width / 3
                }
                Label {
                    anchors.baseline: total1.baseline
                    horizontalAlignment: Text.AlignRight
                    text: app.navigationStatus.totalTime
                    truncationMode: TruncationMode.Fade
                    width: parent.width / 3
                }
            }

            SectionHeader {
                text: app.tr("Options")
            }

            TextSwitch {
                id: showNarrativeSwitch
                checked: app.conf.get("show_narrative")
                text: app.tr("Show navigation instructions")
                onCheckedChanged: {
                    app.conf.set("show_narrative", showNarrativeSwitch.checked);
                    app.showNarrative = showNarrativeSwitch.checked;
                }
            }

            TextSwitch {
                id: voiceNavigationSwitch
                checked: app.conf.get("voice_navigation")
                enabled: map.route.mode !== "transit"
                text: app.tr("Voice navigation instructions")
                onCheckedChanged: {
                    if (!voiceNavigationSwitch.enabled) return;
                    if (voiceNavigationSwitch.checked === app.conf.get("voice_navigation")) return;
                    app.conf.set("voice_navigation", voiceNavigationSwitch.checked);
                    app.navigationActive && map.initVoiceNavigation();
                }
            }

            TextSwitch {
                id: rerouteSwitch
                checked: enabled && app.conf.get("reroute")
                enabled: map.route.mode !== "transit"
                text: app.tr("Reroute automatically")
                onCheckedChanged: {
                    if (!rerouteSwitch.enabled) return;
                    app.conf.set("reroute", rerouteSwitch.checked);
                }
            }

            TextSwitch {
                id: mapmatchingSwitch
                checked: enabled && app.conf.get("map_matching_when_navigating")
                enabled: map.route.mode !== "transit"
                text: app.tr("Snap position to road")
                visible: app.hasMapMatching
                onCheckedChanged: {
                    if (!mapmatchingSwitch.enabled) return;
                    app.conf.set("map_matching_when_navigating", mapmatchingSwitch.checked);
                    if (mapmatchingSwitch.checked) app.mapMatchingModeNavigation=map.route.mode;
                    else app.mapMatchingModeNavigation="none";
                }
            }

            Slider {
                id: scaleSlider
                label: app.tr("Map scale")
                maximumValue: 4.0
                minimumValue: 0.5
                stepSize: 0.1
                value: map.route.mode != null ? app.conf.get("map_scale_navigation_" + map.route.mode) : 1
                valueText: value
                visible: map.route.mode != null
                width: parent.width
                onValueChanged: {
                    if (map.route.mode == null) return;
                    app.conf.set("map_scale_navigation_" + map.route.mode, scaleSlider.value);
                    app.navigationActive && map.setScale(scaleSlider.value);
                }
            }

            TextSwitch {
                id: directionsSwitch
                checked: app.conf.get("show_navigation_sign")
                text: app.tr("Show direction signs")
                onCheckedChanged: {
                    app.conf.set("show_navigation_sign", directionsSwitch.checked);
                    app.showNavigationSign = directionsSwitch.checked;
                }
            }

            ComboBox {
                id: speedLimitComboBox
                description: app.tr("Show speed limit sign")
                enabled: mapmatchingSwitch.checked
                label: app.tr("Speed limit")
                menu: ContextMenu {
                    MenuItem { text: app.tr("Always") }
                    MenuItem { text: app.tr("Only when exceeding") }
                    MenuItem { text: app.tr("Never") }
                }

                property var values: ["always", "exceeding", "never"]

                Component.onCompleted: {
                    var value = app.conf.get("show_speed_limit");
                    speedLimitComboBox.currentIndex = speedLimitComboBox.values.indexOf(value);
                }

                onCurrentIndexChanged: {
                    var index = speedLimitComboBox.currentIndex;
                    var v = speedLimitComboBox.values[index];
                    app.conf.set("show_speed_limit", v);
                    app.showSpeedLimit = v;
                }
            }

            Spacer {
                height: Theme.paddingMedium
            }

        }

        VerticalScrollDecorator {}

    }

    onStatusChanged: {
        if (page.status === PageStatus.Active)
            app.navigationPageSeen = true;
    }

}
