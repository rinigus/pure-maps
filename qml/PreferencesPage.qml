/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2014 Osmo Salomaa, 2018-2019 Rinigus
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
import "."
import "platform"

PagePL {
    id: page
    title: app.tr("Preferences")

    Column {
        id: column
        width: page.width

        ExpandingSectionGroupPL {
            currentIndex: -1

            ExpandingSectionPL {
                id: sectionGeneral
                title: app.tr("General")
                content.sourceComponent: Column {
                    spacing: styler.themePaddingMedium
                    width: sectionGeneral.width
                    FormLayoutPL {
                        spacing: styler.themePaddingMedium

                        ComboBoxPL {
                            id: unitsComboBox
                            label: app.tr("Units")
                            model: [ app.tr("Metric"), app.tr("American"), app.tr("British") ]
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

                        LanguageSelector {
                            description: app.tr("Preferred map language.")
                            key: app.conf.basemapLang
                            languages: [
                                { "key": "local", "name": app.tr("Local") },
                                { "key": "ar", "name": app.tr("Arabic") },
                                { "key": "eu", "name": app.tr("Basque") },
                                { "key": "ca", "name": app.tr("Catalan") },
                                { "key": "zh-simpl", "name": app.tr("Chinese (simplified)") },
                                { "key": "zh", "name": app.tr("Chinese (traditional)") },
                                { "key": "cs", "name": app.tr("Czech") },
                                { "key": "da", "name": app.tr("Danish") },
                                { "key": "nl", "name": app.tr("Dutch") },
                                { "key": "en", "name": app.tr("English") },
                                { "key": "fi", "name": app.tr("Finnish") },
                                { "key": "fr", "name": app.tr("French") },
                                { "key": "de", "name": app.tr("German") },
                                { "key": "ga", "name": app.tr("Gaelic") },
                                { "key": "el", "name": app.tr("Greek") },
                                { "key": "he", "name": app.tr("Hebrew") },
                                { "key": "hi", "name": app.tr("Hindi") },
                                { "key": "id", "name": app.tr("Indonesian") },
                                { "key": "it", "name": app.tr("Italian") },
                                { "key": "ja", "name": app.tr("Japanese") },
                                { "key": "ko", "name": app.tr("Korean") },
                                { "key": "no", "name": app.tr("Norwegian") },
                                { "key": "fa", "name": app.tr("Persian") },
                                { "key": "pl", "name": app.tr("Polish") },
                                { "key": "pt", "name": app.tr("Portuguese") },
                                { "key": "ru", "name": app.tr("Russian") },
                                { "key": "si", "name": app.tr("Sinhalese") },
                                { "key": "es", "name": app.tr("Spanish") },
                                { "key": "sv", "name": app.tr("Swedish") },
                                { "key": "th", "name": app.tr("Thai") },
                                { "key": "tr", "name": app.tr("Turkish") },
                                { "key": "uk", "name": app.tr("Ukrainian") },
                                { "key": "ur", "name": app.tr("Urdu") },
                                { "key": "vi", "name": app.tr("Vietnamese") },
                                { "key": "cy", "name": app.tr("Welsh") }
                            ]
                            onKeyChanged: {
                                app.conf.set("basemap_lang", key);
                                py.call_sync("poor.app.basemap.update", []);
                            }
                        }


                        ComboBoxPL {
                            description: app.tr("Switching between day/night modes of the map. " +
                                                "Note that not all providers have all maps with day/night " +
                                                "pairs available.")
                            label: app.tr("Day/night mode")
                            model: [
                                app.tr("Manual"),
                                app.tr("Sunrise and sunset")
                            ]
                            property var values: [
                                "none",
                                "sunrise/sunset"
                            ]
                            Component.onCompleted: {
                                var value = app.conf.basemapAutoLight;
                                currentIndex = values.indexOf(value);
                            }
                            onCurrentIndexChanged: {
                                var index = currentIndex;
                                app.conf.set("basemap_auto_light", values[index]);
                            }
                        }

                        TextSwitchPL {
                            checked: app.conf.basemapAutoMode
                            description: app.tr("Automatically switch between map types of the provider according to the current task. " +
                                                "For example, show map designed for navigation while routing.")
                            text: app.tr("Switch map modes")
                            onCheckedChanged: {
                                app.conf.set("basemap_auto_mode", checked);
                                py.call_sync("poor.app.basemap.update", []);
                            }
                        }

                        TextSwitchPL {
                            id: autocompleteSwitch
                            checked: app.conf.autoCompleteGeo
                            description: app.tr("Fetch autocompleted search results while typing a search string.")
                            text: app.tr("Autocomplete while searching")
                            onCheckedChanged: app.conf.set("auto_complete_geo", checked)
                        }

                    }

                    Spacer {
                        height: styler.themePaddingLarge
                    }
                }
            }

            ExpandingSectionPL {
                id: sectionDevice
                title: app.tr("Device")
                content.sourceComponent: Column {
                    spacing: styler.themePaddingMedium
                    width: sectionDevice.width

                    ListItemLabel {
                        color: styler.themeHighlightColor
                        text: app.tr("You can control if and when " +
                                     "Pure Maps keeps display active and works in the background. " +
                                     "It is recommended to allow Pure Maps to prevent screensaver " +
                                     "during navigation and never prevent the device suspend directly. " +
                                     "The latter is useful if you wish to receive voice navigation commands " +
                                     "while keeping device in the pocket.")
                        truncMode: truncModes.none
                        wrapMode: Text.WordWrap
                    }

                    FormLayoutPL {
                        spacing: styler.themePaddingMedium

                        ComboBoxPL {
                            description: app.tr("Only applies when Pure Maps is active. When minimized, screensaver " +
                                                "is controlled by normal device-level preferences.")
                            label: app.tr("Prevent screensaver")
                            model: [ app.tr("Never"), app.tr("When navigating"), app.tr("Always") ]
                            property var values: ["never", "navigating", "always"]
                            Component.onCompleted: {
                                var value = app.conf.get("keep_alive");
                                currentIndex = values.indexOf(value);
                            }
                            onCurrentIndexChanged: {
                                var index = currentIndex;
                                app.conf.set("keep_alive", values[index]);
                            }
                        }

                        ComboBoxPL {
                            description: app.tr("Allows to keep positioning and navigation instructions spoken even " +
                                                "when the screen is switched off. If set to 'never', usual device suspend " +
                                                "policy is applied.")
                            label: app.tr("Prevent sleep")
                            model: [ app.tr("Never"), app.tr("When navigating"), app.tr("Always") ]
                            property var values: ["never", "navigating", "always"]
                            Component.onCompleted: {
                                var value = app.conf.get("keep_alive_background");
                                currentIndex = values.indexOf(value);
                            }
                            onCurrentIndexChanged: {
                                var index = currentIndex;
                                app.conf.set("keep_alive_background", values[index]);
                            }
                        }
                    }

                    Spacer {
                        height: styler.themePaddingLarge
                    }
                }
            }

            ExpandingSectionPL {
                id: sectionPrivacy
                title: app.tr("Privacy")
                content.sourceComponent: Column {
                    spacing: styler.themePaddingMedium
                    width: sectionControls.width

                    ListItemLabel {
                        color: styler.themeHighlightColor
                        text: app.tr("Clear all history, including search, routes, and destinations. " +
                                     "Please note that the bookmarks will be kept.")
                        truncMode: truncModes.none
                        wrapMode: Text.WordWrap
                    }

                    ListItemLabel {
                        id: historyClearedNote
                        color: styler.themeHighlightColor
                        text: app.tr("History cleared")
                        truncMode: truncModes.none
                        visible: false
                        wrapMode: Text.WordWrap
                    }

                    ButtonPL {
                        anchors.horizontalCenter: parent.horizontalCenter
                        preferredWidth: styler.themeButtonWidthLarge
                        text: app.tr("Clear history")
                        onClicked: {
                            py.call_sync("poor.app.history.clear", []);
                            historyClearedNote.visible = true;
                        }
                    }

                    Spacer {
                        height: styler.themePaddingLarge
                    }

                    ListItemLabel {
                        text: app.tr("Clear map tiles stored in a cache")
                        truncMode: truncModes.none
                        wrapMode: Text.WordWrap
                    }

                    ButtonPL {
                        anchors.horizontalCenter: parent.horizontalCenter
                        preferredWidth: styler.themeButtonWidthLarge
                        text: app.tr("Clear cache")
                        onClicked: map.clearCache();
                    }

                    Spacer {
                        height: styler.themePaddingLarge
                    }
                }
            }

            ExpandingSectionPL {
                id: sectionLicenses
                title: app.tr("Licenses")
                content.sourceComponent: Column {
                    spacing: styler.themePaddingMedium
                    width: sectionLicenses.width

                    ListItemLabel {
                        color: styler.themeHighlightColor
                        text: app.tr("List of the licenses and whether they are accepted or declined. " +
                                     "Here you can change the acceptance of each license.")
                        truncMode: truncModes.none
                        wrapMode: Text.WordWrap
                    }

                    ListItemLabel {
                        color: styler.themeHighlightColor
                        text: app.tr("Please restart application after changing the acceptance state of the license(s).")
                        truncMode: truncModes.none
                        wrapMode: Text.WordWrap
                    }

                    Column {
                        anchors.left: parent.left
                        anchors.right: parent.right

                        Repeater {
                            id: licenseRep
                            delegate: ListItemPL {
                                id: listItem
                                contentHeight: licenseItemColumn.height
                                Column {
                                    id: licenseItemColumn
                                    anchors.left: parent.left
                                    anchors.right: parent.right
                                    spacing: styler.themePaddingSmall

                                    Spacer {
                                        height: Math.max(0, styler.themePaddingLarge / 2 - styler.themePaddingSmall)
                                    }

                                    ListItemLabel {
                                        color: listItem.highlighted ? styler.themeHighlightColor :
                                                                      styler.themePrimaryColor
                                        text: model.title
                                    }

                                    ListItemLabel {
                                        color: listItem.highlighted ? styler.themeHighlightColor :
                                                                      styler.themePrimaryColor
                                        horizontalAlignment: Text.AlignRight
                                        text: {
                                            if (model.status === -1) return app.tr("Declined")
                                            if (model.status === 1) return app.tr("Accepted")
                                            return app.tr("Unset")
                                        }
                                    }

                                    Spacer {
                                        height: Math.max(0, styler.themePaddingLarge / 2 - styler.themePaddingSmall)
                                    }
                                }

                                onClicked: {
                                    var d = app.push(Qt.resolvedUrl("LicensePage.qml"), {
                                                         "title": model.title,
                                                         "key": model.key,
                                                         "text": model.text,
                                                         "acceptLicense": model.status!==-1
                                                     });
                                    d.accepted.connect(licenseRep.load)
                                }
                            }
                            model: ListModel {}

                            Component.onCompleted: load()

                            function load() {
                                model.clear();
                                py.call("poor.key.licenses", [], function(licenses) {
                                    for (var i = 0; i < licenses.length; i++)
                                        model.append({
                                                         "key": licenses[i].id,
                                                         "text": licenses[i].text,
                                                         "title": licenses[i].title,
                                                         "status": licenses[i].status
                                                     });
                                });
                            }
                        }
                    }

                    Spacer {
                        height: styler.themePaddingLarge
                    }
                }
            }

            ExpandingSectionPL {
                id: sectionKeys
                title: app.tr("API keys")
                content.sourceComponent: Column {
                    id: keysColumn
                    spacing: styler.themePaddingMedium
                    width: sectionKeys.width

                    ListItemLabel {
                        color: styler.themeHighlightColor
                        text: app.tr("You can specify personal keys for online services " +
                                     "in these settings. Please check the conditions for each of the " +
                                     "services that you want to use to ensure that you comply with them.")
                        truncMode: truncModes.none
                        wrapMode: Text.WordWrap
                    }

                    ListItemLabel {
                        color: styler.themeHighlightColor
                        text: app.tr("Please restart application after changing API keys.")
                        truncMode: truncModes.none
                        wrapMode: Text.WordWrap
                    }

                    Column {
                        id: keysForm
                        spacing: styler.themePaddingLarge
                        width: keysColumn.width
                        Repeater {
                            delegate: Column {
                                spacing: styler.themePaddingMedium
                                width: keysForm.width
                                property bool isHeader: model.header

                                SectionHeaderPL {
                                    text: model.header
                                    visible: text
                                }

                                ListItemLabel {
                                    color: styler.themeHighlightColor
                                    text: model.description
                                    truncMode: truncModes.none
                                    visible: text
                                    wrapMode: Text.WordWrap
                                }

                                TextFieldPL {
                                    label: model.label
                                    placeholderText: model.label
                                    text: model.value
                                    visible: !parent.isHeader
                                    onTextChanged: py.call_sync("poor.key.set",
                                                                [model.key, text])
                                }
                            }
                            model: ListModel {}

                            Component.onCompleted: {
                                py.call("poor.key.list", [true], function(keys) {
                                    for (var i = 0; i < keys.length; i++)
                                        model.append({
                                                         "header": keys[i].header || "",
                                                         "key": keys[i].id || "",
                                                         "description": keys[i].description || "",
                                                         "label": keys[i].label || "",
                                                         "value": keys[i].value || ""
                                                     });
                                });
                            }
                        }
                    }

                    Spacer {
                        height: styler.themePaddingLarge
                    }
                }
            }

            ExpandingSectionPL {
                id: sectionExplore
                title: app.tr("Exploring")
                content.sourceComponent: FormLayoutPL {
                    spacing: styler.themePaddingMedium

                    ComboBoxPL {
                        id: mapmatchingComboBox
                        description: app.tr("Select mode of transportation. Only applies when Pure Maps is not navigating. Uses OSM Scout Server for its operation.")
                        label: app.tr("Snap position to road")
                        model: [ app.tr("None"), app.tr("Car"), app.tr("Bicycle"), app.tr("Foot") ]
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

                    Spacer {
                        height: styler.themePaddingLarge
                    }
                }
            }

            ExpandingSectionPL {
                id: sectionNavigate
                title: app.tr("Navigation")
                content.sourceComponent: Column {
                    spacing: styler.themePaddingMedium
                    width: sectionNavigate.width

                    TextSwitchPL {
                        id: showNarrativeSwitch
                        checked: app.conf.showNarrative
                        text: app.tr("Show navigation instructions")
                        onCheckedChanged: {
                            if (app.conf.showNarrative!==showNarrativeSwitch.checked)
                                app.conf.set("show_narrative", showNarrativeSwitch.checked);
                        }
                    }

                    TextSwitchPL {
                        id: voiceNavigationSwitch
                        checked: app.conf.voiceNavigation
                        text: app.tr("Voice navigation instructions")
                        onCheckedChanged: {
                            if (voiceNavigationSwitch.checked === app.conf.voiceNavigation) return;
                            app.conf.set("voice_navigation", voiceNavigationSwitch.checked);
                        }
                    }

                    TextSwitchPL {
                        id: rerouteSwitch
                        checked: app.conf.reroute
                        text: app.tr("Reroute automatically")
                        onCheckedChanged: {
                            if (rerouteSwitch.checked===app.conf.reroute) return;
                            app.conf.set("reroute", rerouteSwitch.checked);
                        }
                    }

                    TextSwitchPL {
                        checked: app.conf.mapZoomAutoWhenNavigating
                        text: app.tr("Automatic zoom on start")
                        onCheckedChanged: {
                            if (checked===app.conf.mapZoomAutoWhenNavigating) return;
                            app.conf.set("map_zoom_auto_when_navigating", checked);
                        }
                    }

                    TextSwitchPL {
                        id: mapmatchingSwitch
                        checked: app.conf.mapMatchingWhenNavigating
                        description: app.tr("Uses OSM Scout Server for its operation.")
                        text: app.tr("Snap position to road")
                        onCheckedChanged: {
                            if (mapmatchingSwitch.checked===app.conf.mapMatchingWhenNavigating) return;
                            app.conf.set("map_matching_when_navigating", mapmatchingSwitch.checked);
                        }
                    }

                    TextSwitchPL {
                        id: directionsSwitch
                        checked: app.conf.showNavigationSign
                        text: app.tr("Show direction signs")
                        onCheckedChanged: {
                            if (directionsSwitch.checked===app.conf.showNavigationSign) return;
                            app.conf.set("show_navigation_sign", directionsSwitch.checked);
                        }
                    }

                    TextSwitchPL {
                        id: autorotateSwitch
                        checked: app.conf.autoRotateWhenNavigating
                        description: app.tr("Set rotation of the map in the direction of movement when starting navigation.")
                        text: app.tr("Rotate map when navigating")
                        onCheckedChanged: {
                            app.conf.set("auto_rotate_when_navigating", autorotateSwitch.checked);
                        }
                    }

                    TextSwitchPL {
                        id: tiltSwitch
                        checked: app.conf.tiltWhenNavigating
                        description: app.tr("Only applies to vector maps.")
                        enabled: autorotateSwitch.checked
                        text: app.tr("Tilt map when navigating")
                        onCheckedChanged: {
                            app.conf.set("tilt_when_navigating", tiltSwitch.checked);
                        }
                    }

                    TextSwitchPL {
                        checked: app.conf.smoothPositionAnimationWhenNavigating
                        text: app.tr("Smooth position animation")
                        onCheckedChanged: {
                            app.conf.set("smooth_position_animation_when_navigating", checked);
                        }
                    }

                    FormLayoutPL {
                        spacing: styler.themePaddingMedium
                        ComboBoxPL {
                            id: voiceGenderComboBox
                            description: app.tr("Preferred gender for voice navigation. Only supported by some engines and languages.")
                            label: app.tr("Voice gender")
                            model: [ app.tr("Male"), app.tr("Female") ]
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

                        ComboBoxPL {
                            description: app.tr("Timeout between traffic information updates leading to possible rerouting. This is active only while routing.")
                            label: app.tr("Update traffic while routing")
                            model: [
                                app.tr("Disabled"),
                                app.tr("10 minutes"),
                                app.tr("20 minutes"),
                                app.tr("30 minutes"),
                                app.tr("45 minutes"),
                                app.tr("60 minutes")
                            ]
                            property var values: [-1, 600, 1200, 1800, 2700, 3600]
                            Component.onCompleted: {
                                var value = app.conf.trafficRerouteTime;
                                var r = values[0];
                                var ci = 0;
                                if (value > 0) {
                                    for (var i=1; i < values.length; i++)
                                        if (Math.abs(r - value) > Math.abs(values[i] - value)) {
                                            r = values[i];
                                            ci = i;
                                        }
                                }
                                currentIndex = ci;
                            }
                            onCurrentIndexChanged: {
                                var index = currentIndex;
                                var v = values[index];
                                if (v !== app.conf.trafficRerouteTime)
                                    app.conf.set("traffic_reroute_time", v);
                            }
                        }

                        ComboBoxPL {
                            id: speedLimitComboBox
                            description: app.tr("Show speed limit sign. Requires snapping position to the road to find the speed limit.")
                            enabled: mapmatchingSwitch.checked
                            label: app.tr("Speed limit")
                            model: [ app.tr("Always"), app.tr("Only when exceeding"), app.tr("Never") ]
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

                        ComboBoxPL {
                            id: horizontalAccuracyComboBox
                            description: app.tr("Accuracy of the positioning supported by device. Deviation from the route below the specified accuracy will be ignored.")
                            label: app.tr("Positioning accuracy")
                            model: [
                                py.call_sync("poor.util.format_distance", [10, 2]),
                                py.call_sync("poor.util.format_distance", [15, 2]),
                                py.call_sync("poor.util.format_distance", [20, 2]),
                                py.call_sync("poor.util.format_distance", [25, 2]),
                                py.call_sync("poor.util.format_distance", [35, 2]),
                                py.call_sync("poor.util.format_distance", [50, 2])
                            ]
                            property var values: [10, 15, 20, 25, 35, 50]
                            Component.onCompleted: {
                                var value = app.conf.navigationHorizontalAccuracy;
                                var r = values[0];
                                var ci = 0;
                                for (var i=1; i < values.length; i++)
                                    if (Math.abs(r - value) > Math.abs(values[i] - value)) {
                                        r = values[i];
                                        ci = i;
                                    }
                                currentIndex = ci;
                            }
                            onCurrentIndexChanged: {
                                var index = currentIndex;
                                var v = values[index];
                                if (v !== app.conf.navigationHorizontalAccuracy)
                                    app.conf.set("navigation_horizontal_accuracy", v);
                            }
                        }
                    }

                    Spacer {
                        height: styler.themePaddingLarge
                    }
                }
            }

            ExpandingSectionPL {
                id: sectionCompass
                title: app.tr("Compass")
                content.sourceComponent: Column {
                    spacing: styler.themePaddingMedium
                    width: sectionCompass.width

                    ListItemLabel {
                        color: styler.themeHighlightColor
                        text: app.tr("Compass can be used to determine orientation of your device " +
                                     "and align the map accordingly. Note that the compass is enabled only " +
                                     "when your position is determined, your speed is low, and, " +
                                     "if you are navigating, only if you are by foot or on the bicycle.")
                        truncMode: truncModes.none
                        wrapMode: Text.WordWrap
                    }

                    TextSwitchPL {
                        checked: app.conf.compassUse
                        description: app.tr("Use compass for determination of the direction.")
                        text: app.tr("Use compass")
                        onCheckedChanged: app.conf.set("compass_use", checked)
                    }

                    Spacer {
                        height: styler.themePaddingLarge
                    }
                }
            }

            ExpandingSectionPL {
                id: sectionControls
                title: app.tr("Controls")
                content.sourceComponent: Column {
                    spacing: styler.themePaddingMedium
                    width: sectionControls.width

                    ListItemLabel {
                        color: styler.themeHighlightColor
                        text: app.tr("Map view can be shown with either all applicable controls in full view mode " +
                                     "or with a smaller selected set of controls in minimal view mode. To switch between " +
                                     "the modes, click on a map.")
                        truncMode: truncModes.none
                        wrapMode: Text.WordWrap
                    }

                    TextSwitchPL {
                        checked: app.conf.mapModeCleanOnStart
                        text: app.tr("Set map view to minimal mode on start")
                        onCheckedChanged: {
                            if (app.conf.mapModeCleanOnStart!==checked)
                                app.conf.set("map_mode_clean_on_start", checked);
                        }
                    }

                    ComboBoxPL {
                        description: app.tr("Automatically switch to minimal view mode after given delay or " +
                                            "disable automatic switch between map view modes.")
                        label: app.tr("Switch to minimal view")
                        model: [
                            app.tr("Never"), app.tr("10 seconds"), app.tr("20 seconds"),
                            app.tr("30 seconds"), app.tr("1 minute") ]
                        property var values: [-1, 10, 20, 30, 60]
                        Component.onCompleted: {
                            var value = app.conf.mapModeAutoSwitchTime;
                            currentIndex = values.indexOf(value);
                        }
                        onCurrentIndexChanged: {
                            var index = currentIndex;
                            app.conf.set("map_mode_auto_switch_time", values[index]);
                        }
                    }


                    SectionHeaderPL {
                        text: app.tr("Always show")
                    }

                    ListItemLabel {
                        color: styler.themeHighlightColor
                        text: app.tr("Always show the selected controls regardless of whether " +
                                     "map view is in the minimal or in the full mode.")
                        truncMode: truncModes.none
                        wrapMode: Text.WordWrap
                    }

                    TextSwitchPL {
                        checked: app.conf.mapModeCleanShowMenuButton
                        text: app.tr("Menu")
                        onCheckedChanged: {
                            if (app.conf.mapModeCleanShowMenuButton!==checked)
                                app.conf.set("map_mode_clean_show_menu_button", checked);
                        }
                    }

                    TextSwitchPL {
                        checked: app.conf.mapModeCleanShowCenter
                        text: app.tr("Center on current location")
                        onCheckedChanged: {
                            if (app.conf.mapModeCleanShowCenter!==checked)
                                app.conf.set("map_mode_clean_show_center", checked);
                        }
                    }

                    TextSwitchPL {
                        checked: app.conf.mapModeCleanShowCompass
                        text: app.tr("Compass")
                        onCheckedChanged: {
                            if (app.conf.mapModeCleanShowCompass!==checked)
                                app.conf.set("map_mode_clean_show_compass", checked);
                        }
                    }

                    TextSwitchPL {
                        checked: app.conf.mapModeCleanShowBasemap
                        text: app.tr("Map selection")
                        onCheckedChanged: {
                            if (app.conf.mapModeCleanShowBasemap!==checked)
                                app.conf.set("map_mode_clean_show_basemap", checked);
                        }
                    }

                    TextSwitchPL {
                        checked: app.conf.mapModeCleanShowMeters
                        text: app.tr("Speed and location precision")
                        onCheckedChanged: {
                            if (app.conf.mapModeCleanShowMeters!==checked)
                                app.conf.set("map_mode_clean_show_meters", checked);
                        }
                    }

                    TextSwitchPL {
                        checked: app.conf.mapModeCleanShowScale
                        text: app.tr("Scale")
                        onCheckedChanged: {
                            if (app.conf.mapModeCleanShowScale!==checked)
                                app.conf.set("map_mode_clean_show_scale", checked);
                        }
                    }

                    TextSwitchPL {
                        checked: app.conf.mapModeCleanShowGeocode
                        text: app.tr("Search")
                        onCheckedChanged: {
                            if (app.conf.mapModeCleanShowGeocode!==checked)
                                app.conf.set("map_mode_clean_show_geocode", checked);
                        }
                    }

                    TextSwitchPL {
                        checked: app.conf.mapModeCleanShowNavigate
                        text: app.tr("Navigate")
                        onCheckedChanged: {
                            if (app.conf.mapModeCleanShowNavigate!==checked)
                                app.conf.set("map_mode_clean_show_navigate", checked);
                        }
                    }

                    TextSwitchPL {
                        checked: app.conf.mapModeCleanShowNavigationStartPause
                        text: app.tr("Navigation Start/Pause")
                        onCheckedChanged: {
                            if (app.conf.mapModeCleanShowNavigationStartPause!==checked)
                                app.conf.set("map_mode_clean_show_navigation_start_pause", checked);
                        }
                    }

                    TextSwitchPL {
                        checked: app.conf.mapModeCleanShowNavigationClear
                        text: app.tr("Navigation Clear Route")
                        onCheckedChanged: {
                            if (app.conf.mapModeCleanShowNavigationClear!==checked)
                                app.conf.set("map_mode_clean_show_navigation_clear", checked);
                        }
                    }

                    Spacer {
                        height: styler.themePaddingLarge
                    }
                }
            }

            ExpandingSectionPL {
                id: sectionAutoZoom
                title: app.tr("Zoom")
                content.sourceComponent: Column {
                    spacing: styler.themePaddingMedium
                    width: sectionGeneral.width

                    ListItemLabel {
                        color: styler.themeHighlightColor
                        text: app.tr("Map zoom level can be adjusted automatically according to your speed. " +
                                     "Here, you can adjust settings related to this adjustment.")
                        truncMode: truncModes.none
                        wrapMode: Text.WordWrap
                    }

                    FormLayoutPL {
                        spacing: styler.themePaddingMedium

                        SliderPL {
                            description: app.tr("Maximal zoom level that is going to be used " +
                                                "in the automatic adjustment of the zoom.")
                            label: app.tr("Maximal zoom level")
                            maximumValue: 20.0
                            minimumValue: 10.0
                            stepSize: 0.1
                            value: app.conf.get("map_zoom_auto_zero_speed_z")
                            valueText: value
                            width: parent.width
                            onValueChanged: app.conf.set("map_zoom_auto_zero_speed_z", value)
                        }

                        SliderPL {
                            description: app.tr("Zoom level will be adjusted to have the same " +
                                                "map height as the distance that is " +
                                                "covered by you in the given amount of seconds.")
                            label: app.tr("Time range, s")
                            maximumValue: 120.0
                            minimumValue: 5.0
                            stepSize: 1.0
                            value: app.conf.get("map_zoom_auto_time")
                            valueText: value
                            width: parent.width
                            onValueChanged: app.conf.set("map_zoom_auto_time", value)
                        }
                    }

                    Spacer {
                        height: styler.themePaddingLarge
                    }
                }
            }

            ExpandingSectionPL {
                id: sectionTesting
                title: app.tr("Testing")
                content.sourceComponent: Column {
                    id: testingColumn
                    spacing: styler.themePaddingMedium
                    width: sectionTesting.width

                    property string message

                    ListItemLabel {
                        color: styler.themeHighlightColor
                        text: app.tr("Testing of Text-to-Speech (TTS) engine. " +
                                     "Select the same language as used for navigation, preferred gender, and press " +
                                     "the button below for testing.")
                        truncMode: truncModes.none
                        wrapMode: Text.WordWrap
                    }

                    FormLayoutPL {
                        spacing: styler.themePaddingMedium
                        LanguageSelector {
                            id: languageComboBox
                            key: "en"
                            languages: [
                                { "key": "en", "name": app.tr("English"), "text": "My hovercraft is full of eels" },
                                { "key": "ca", "name": app.tr("Catalan"), "text": "El meu aerolliscador està ple d'anguiles" },
                                { "key": "cz", "name": app.tr("Czech"), "text": "Moje vznášedlo je plné úhořů" },
                                { "key": "de", "name": app.tr("German"), "text": "Mein Luftkissenfahrzeug ist voller Aale" },
                                { "key": "es", "name": app.tr("Spanish"), "text": "Mi aerodeslizador está lleno de anguilas" },
                                { "key": "fr", "name": app.tr("French"), "text": "Mon aéroglisseur est plein d'anguilles" },
                                { "key": "hi", "name": app.tr("Hindi"), "text": "मेरी मँडराने वाली नाव सर्पमीनों से भरी हैं" },
                                { "key": "it", "name": app.tr("Italian"), "text": "Il mio hovercraft è pieno di anguille" },
                                { "key": "ru", "name": app.tr("Russian"), "text": "Моё судно на воздушной подушке полно угрей" },
                                { "key": "sl", "name": app.tr("Slovak"), "text": "Moje vznášadlo je plné úhorov" },
                                { "key": "sv", "name": app.tr("Swedish"), "text": "Min svävare är full med ål" }
                            ]
                        }

                        ComboBoxPL {
                            id: genderComboBox
                            description: app.tr("Preferred gender. Only supported by some engines and languages.")
                            label: app.tr("Voice gender")
                            model: [ app.tr("Male"), app.tr("Female") ]
                            property var values: ["male", "female"]
                        }
                    }

                    Spacer {
                        height: styler.themePaddingLarge
                    }

                    ButtonPL {
                        anchors.horizontalCenter: parent.horizontalCenter
                        preferredWidth: styler.themeButtonWidthLarge
                        text: app.tr("Test")
                        onClicked: testingColumn.test()
                    }

                    Spacer {
                        height: styler.themePaddingLarge
                    }

                    ListItemLabel {
                        id: description
                        color: styler.themeHighlightColor
                        text: voice.currentEngine ? app.tr("Selected voice engine: %1",
                                                           voice.currentEngine) :
                                                    app.tr("No engine available for selected language.\n\n" +
                                                           "Pure Maps supports Mimic, Flite, PicoTTS, and " +
                                                           "Espeak TTS engines. Unless you are using Pure Maps " +
                                                           "through Flatpak or OpenStore, the engines have " +
                                                           "to be installed separately. Sailfish OS users " +
                                                           "can find the engines at Chum.")
                        truncMode: truncModes.none
                        wrapMode: Text.WordWrap
                    }

                    Spacer {
                        height: styler.themePaddingLarge
                    }

                    Voice {
                        id: voice
                        enabled: true
                        engine: "tester"
                        gender: genderComboBox.values[genderComboBox.currentIndex]
                        language: languageComboBox.key
                    }

                    function test() {
                        if (voice.active) {
                            var txt = languageComboBox.languages[languageComboBox.languageIndex].text;
                            voice.prepare(txt);
                            voice.play(txt);
                        }
                    }
                }
            }

            ExpandingSectionPL {
                id: sectionDevelop
                title: app.tr("Development")
                content.sourceComponent: Column {
                    spacing: styler.themePaddingMedium
                    width: sectionDevelop.width

                    ListItemLabel {
                        color: styler.themeHighlightColor
                        text: app.tr("The following options are for development only. Please don't change them unless you know what you are doing.")
                        truncMode: truncModes.none
                        wrapMode: Text.WordWrap
                    }

                    TextSwitchPL {
                        id: develCoorSwitch
                        checked: app.conf.developmentCoordinateCenter
                        description: app.tr("Sets current position to the center of the current map view. Remember to disable GPS positioning when using this option.")
                        text: app.tr("Set position to the map center")
                        onCheckedChanged: app.conf.set("devel_coordinate_center", develCoorSwitch.checked)
                    }

                    TextSwitchPL {
                        id: develShowZSwitch
                        checked: app.conf.developmentShowZ
                        text: app.tr("Show current zoom level")
                        onCheckedChanged: app.conf.set("devel_show_z", develShowZSwitch.checked)
                    }

                    Spacer {
                        height: styler.themePaddingLarge
                    }
                }
            }
        }
    }

}
