/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2014 Osmo Salomaa, 2018 Rinigus
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
    allowedOrientations: app.defaultAllowedOrientations

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.implicitHeight
        contentWidth: parent.width

        Column {
            id: column
            anchors.fill: parent

            PageHeader {
                title: app.tr("Preferences")
            }

            ExpandingSectionGroup {
                currentIndex: -1

                ExpandingSection {
                    id: sectionGeneral
                    title: app.tr("General")
                    content.sourceComponent: Column {
                        width: sectionGeneral.width

                        ComboBox {
                            id: unitsComboBox
                            label: app.tr("Units")
                            menu: ContextMenu {
                                MenuItem { text: app.tr("Metric") }
                                MenuItem { text: app.tr("American") }
                                MenuItem { text: app.tr("British") }
                            }
                            property var values: ["metric", "american", "british"]
                            Component.onCompleted: {
                                var value = app.conf.units;
                                unitsComboBox.currentIndex = unitsComboBox.values.indexOf(value);
                            }
                            onCurrentIndexChanged: {
                                var index = unitsComboBox.currentIndex;
                                app.conf.set("units", unitsComboBox.values[index]);
                            }
                        }

                        ComboBox {
                            id: sleepComboBox
                            description: app.tr("Only applies when Pure Maps is active. When minimized, sleep is controlled by normal device-level preferences.")
                            label: app.tr("Prevent sleep")
                            menu: ContextMenu {
                                MenuItem { text: app.tr("Never") }
                                MenuItem { text: app.tr("When navigating") }
                                MenuItem { text: app.tr("Always") }
                            }
                            property var values: ["never", "navigating", "always"]
                            Component.onCompleted: {
                                var value = app.conf.get("keep_alive");
                                sleepComboBox.currentIndex = sleepComboBox.values.indexOf(value);
                            }
                            onCurrentIndexChanged: {
                                var index = sleepComboBox.currentIndex;
                                app.conf.set("keep_alive", sleepComboBox.values[index]);
                                app.updateKeepAlive();
                            }
                        }

                        TextSwitch {
                            id: autocompleteSwitch
                            checked: app.conf.autoCompleteGeo
                            description: app.tr("Fetch autocompleted search results while typing a search string.")
                            text: app.tr("Autocomplete while searching")
                            onCheckedChanged: app.conf.set("auto_complete_geo", autocompleteSwitch.checked)
                        }

                        Spacer {
                            height: Theme.paddingLarge
                        }

                        Button {
                            anchors.horizontalCenter: parent.horizontalCenter
                            preferredWidth: Theme.buttonWidthLarge
                            text: app.tr("Clear cache")
                            onClicked: map.clearCache();
                        }

                        Spacer {
                            height: Theme.paddingLarge
                        }
                    }
                }

                ExpandingSection {
                    id: sectionExplore
                    title: app.tr("Map view")
                    content.sourceComponent: Column {
                        width: sectionExplore.width

                        ComboBox {
                            id: mapmatchingComboBox
                            description: app.tr("Select mode of transportation. Only applies when Pure Maps is not navigating.")
                            label: app.tr("Snap position to road")
                            menu: ContextMenu {
                                MenuItem { text: app.tr("None") }
                                MenuItem { text: app.tr("Car") }
                                MenuItem { text: app.tr("Bicycle") }
                                MenuItem { text: app.tr("Foot") }
                            }
                            visible: app.hasMapMatching
                            property var values: ["none", "car", "bicycle", "foot"]
                            Component.onCompleted: {
                                var value = app.conf.mapMatchingWhenIdle;
                                mapmatchingComboBox.currentIndex = mapmatchingComboBox.values.indexOf(value);
                            }
                            onCurrentIndexChanged: {
                                var index = mapmatchingComboBox.currentIndex;
                                app.conf.set("map_matching_when_idle", mapmatchingComboBox.values[index]);
                            }
                        }

                        Slider {
                            id: scaleSlider
                            label: app.tr("Map scale")
                            maximumValue: 2.0
                            minimumValue: 0.5
                            stepSize: 0.1
                            value: app.conf.get("map_scale")
                            valueText: value
                            width: parent.width
                            onValueChanged: {
                                app.conf.set("map_scale", scaleSlider.value);
                                app.mode !== modes.navigate && map.setScale(scaleSlider.value);
                            }
                        }

                        Spacer {
                            height: Theme.paddingLarge
                        }
                    }
                }

                ExpandingSection {
                    id: sectionNavigate
                    title: app.tr("Navigation")
                    content.sourceComponent: Column {
                        width: sectionNavigate.width

                        TextSwitch {
                            id: showNarrativeSwitch
                            checked: app.conf.showNarrative
                            text: app.tr("Show navigation instructions")
                            onCheckedChanged: {
                                if (app.conf.showNarrative!==showNarrativeSwitch.checked)
                                    app.conf.set("show_narrative", showNarrativeSwitch.checked);
                            }
                        }

                        TextSwitch {
                            id: voiceNavigationSwitch
                            checked: app.conf.voiceNavigation
                            text: app.tr("Voice navigation instructions")
                            onCheckedChanged: {
                                if (voiceNavigationSwitch.checked === app.conf.voiceNavigation) return;
                                app.conf.set("voice_navigation", voiceNavigationSwitch.checked);
                                if (app.mode === modes.navigate) map.initVoiceNavigation();
                            }
                        }

                        TextSwitch {
                            id: rerouteSwitch
                            checked: app.conf.reroute
                            text: app.tr("Reroute automatically")
                            onCheckedChanged: {
                                if (rerouteSwitch.checked===app.conf.reroute) return;
                                app.conf.set("reroute", rerouteSwitch.checked);
                            }
                        }

                        TextSwitch {
                            id: mapmatchingSwitch
                            checked: app.conf.mapMatchingWhenNavigating
                            text: app.tr("Snap position to road")
                            visible: app.hasMapMatching
                            onCheckedChanged: {
                                if (mapmatchingSwitch.checked===app.conf.mapMatchingWhenNavigating) return;
                                app.conf.set("map_matching_when_navigating", mapmatchingSwitch.checked);
                            }
                        }

                        TextSwitch {
                            id: directionsSwitch
                            checked: app.conf.showNavigationSign
                            text: app.tr("Show direction signs")
                            onCheckedChanged: {
                                if (directionsSwitch.checked===app.conf.showNavigationSign) return;
                                app.conf.set("show_navigation_sign", directionsSwitch.checked);
                            }
                        }

                        TextSwitch {
                            id: autorotateSwitch
                            checked: app.conf.autoRotateWhenNavigating
                            description: app.tr("Set rotation of the map in the direction of movement when starting navigation.")
                            text: app.tr("Rotate map when navigating")
                            onCheckedChanged: {
                                app.conf.set("auto_rotate_when_navigating", autorotateSwitch.checked);
                            }
                        }

                        TextSwitch {
                            id: tiltSwitch
                            checked: app.conf.tiltWhenNavigating
                            description: app.tr("Only applies to vector maps.")
                            enabled: autorotateSwitch.checked
                            text: app.tr("Tilt map when navigating")
                            onCheckedChanged: {
                                app.conf.set("tilt_when_navigating", tiltSwitch.checked);
                            }
                        }

                        ComboBox {
                            id: voiceGenderComboBox
                            description: app.tr("Preferred gender for voice navigation. Only supported by some engines and languages.")
                            label: app.tr("Voice gender")
                            menu: ContextMenu {
                                MenuItem { text: app.tr("Male") }
                                MenuItem { text: app.tr("Female") }
                            }
                            property var values: ["male", "female"]
                            Component.onCompleted: {
                                var value = app.conf.voiceGender;
                                voiceGenderComboBox.currentIndex = voiceGenderComboBox.values.indexOf(value);
                            }
                            onCurrentIndexChanged: {
                                var index = voiceGenderComboBox.currentIndex;
                                app.conf.set("voice_gender", voiceGenderComboBox.values[index]);
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
                                var value = app.conf.showSpeedLimit;
                                speedLimitComboBox.currentIndex = speedLimitComboBox.values.indexOf(value);
                            }

                            onCurrentIndexChanged: {
                                var index = speedLimitComboBox.currentIndex;
                                var v = speedLimitComboBox.values[index];
                                if (v !== app.conf.showSpeedLimit)
                                    app.conf.set("show_speed_limit", v);
                            }
                        }

                        Spacer {
                            height: Theme.paddingLarge
                        }
                    }
                }

                ExpandingSection {
                    id: sectionDevelop
                    title: app.tr("Development")
                    content.sourceComponent: Column {
                        width: sectionDevelop.width

                        ListItemLabel {
                            font.pixelSize: Theme.fontSizeSmall
                            height: implicitHeight
                            text: app.tr("The following options are for development only. Please don't change them unless you know what you are doing.")
                            wrapMode: Text.WordWrap
                        }

                        TextSwitch {
                            id: develCoorSwitch
                            checked: app.conf.developmentCoordinateCenter
                            description: app.tr("Sets current position to the center of the current map view. Remember to disable GPS positioning when using this option.")
                            text: app.tr("Set position to the map center")
                            onCheckedChanged: app.conf.set("devel_coordinate_center", develCoorSwitch.checked)
                        }

                        TextSwitch {
                            id: develShowZSwitch
                            checked: app.conf.developmentShowZ
                            text: app.tr("Show current zoom level")
                            onCheckedChanged: app.conf.set("devel_show_z", develShowZSwitch.checked)
                        }

                        Spacer {
                            height: Theme.paddingLarge
                        }
                    }
                }
            }
        }

        VerticalScrollDecorator {}

    }

}
