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
                    width: sectionControls.width
                    FormLayoutPL {
                        spacing: styler.themePaddingMedium
                        width: sectionGeneral.width

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

                        ComboBoxPL {
                            description: app.tr("Preferred map language.")
                            label: app.tr("Language")
                            model: [
                                app.tr("Local"),
                                app.tr("Arabic"),
                                app.tr("Basque"),
                                app.tr("Catalan"),
                                app.tr("Chinese (simplified)"),
                                app.tr("Chinese (traditional)"),
                                app.tr("Czech"),
                                app.tr("Danish"),
                                app.tr("Dutch"),
                                app.tr("English"),
                                app.tr("Finnish"),
                                app.tr("French"),
                                app.tr("German"),
                                app.tr("Gaelic"),
                                app.tr("Greek"),
                                app.tr("Hebrew"),
                                app.tr("Hindi"),
                                app.tr("Indonesian"),
                                app.tr("Italian"),
                                app.tr("Japanese"),
                                app.tr("Korean"),
                                app.tr("Norwegian"),
                                app.tr("Persian"),
                                app.tr("Polish"),
                                app.tr("Portuguese"),
                                app.tr("Russian"),
                                app.tr("Sinhalese"),
                                app.tr("Spanish"),
                                app.tr("Swedish"),
                                app.tr("Thai"),
                                app.tr("Turkish"),
                                app.tr("Ukrainian"),
                                app.tr("Urdu"),
                                app.tr("Vietnamese"),
                                app.tr("Welsh")
                            ]
                            property var values: [
                                "local",
                                "ar",
                                "eu",
                                "ca",
                                "zh-simpl",
                                "zh",
                                "cs",
                                "da",
                                "nl",
                                "en",
                                "fi",
                                "fr",
                                "de",
                                "ga",
                                "el",
                                "he",
                                "hi",
                                "id",
                                "it",
                                "ja",
                                "ko",
                                "no",
                                "fa",
                                "pl",
                                "pt",
                                "ru",
                                "si",
                                "es",
                                "sv",
                                "th",
                                "tr",
                                "uk",
                                "ur",
                                "vi",
                                "cy"
                            ]

                            Component.onCompleted: {
                                var value = app.conf.basemapLang;
                                currentIndex = values.indexOf(value);
                            }
                            onCurrentIndexChanged: {
                                var index = currentIndex;
                                app.conf.set("basemap_lang", values[index]);
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

                        ComboBoxPL {
                            id: sleepComboBox
                            description: app.tr("Only applies when Pure Maps is active. When minimized, sleep is controlled by normal device-level preferences.")
                            label: app.tr("Prevent sleep")
                            model: [ app.tr("Never"), app.tr("When navigating"), app.tr("Always") ]
                            property var values: ["never", "navigating", "always"]
                            Component.onCompleted: {
                                var value = app.conf.get("keep_alive");
                                sleepComboBox.currentIndex = sleepComboBox.values.indexOf(value);
                            }
                            onCurrentIndexChanged: {
                                var index = sleepComboBox.currentIndex;
                                app.conf.set("keep_alive", sleepComboBox.values[index]);
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

                    ListItemLabel {
                        text: app.tr("Clear all history, including search, routes, and destinations. " +
                                     "Please note that the bookmarks will be kept.")
                        truncMode: truncModes.none
                        wrapMode: Text.WordWrap
                    }

                    ListItemLabel {
                        id: historyClearedNote
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
                id: sectionKeys
                title: app.tr("API keys")
                content.sourceComponent: Column {
                    spacing: styler.themePaddingMedium
                    width: sectionKeys.width

                    ListItemLabel {
                        text: app.tr("You can specify personal keys for online services " +
                                     "in these settings. Please check the conditions for each of the " +
                                     "services that you want to use to ensure that you comply with them.")
                        truncMode: truncModes.none
                        wrapMode: Text.WordWrap
                    }

                    ListItemLabel {
                        text: app.tr("Please restart application after changing API keys.")
                        truncMode: truncModes.none
                        wrapMode: Text.WordWrap
                    }

                    FormLayoutPL {
                        spacing: styler.themePaddingMedium
                        width: parent.width
                        Repeater {
                            delegate: TextFieldPL {
                                description: model.description
                                label: model.label
                                placeholderText: model.label
                                text: model.value
                                onTextChanged: py.call_sync("poor.key.set",
                                                            [model.key, text])
                            }
                            model: ListModel {}

                            Component.onCompleted: {
                                // Load router model items from the Python backend.
                                py.call("poor.key.list", [], function(keys) {
                                    for (var i = 0; i < keys.length; i++)
                                        model.append({
                                                         "key": keys[i].id,
                                                         "description": keys[i].description,
                                                         "label": keys[i].label,
                                                         "value": keys[i].value
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
                    width: sectionExplore.width

                    ComboBoxPL {
                        id: mapmatchingComboBox
                        description: app.tr("Select mode of transportation. Only applies when Pure Maps is not navigating.")
                        label: app.tr("Snap position to road")
                        model: [ app.tr("None"), app.tr("Car"), app.tr("Bicycle"), app.tr("Foot") ]
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

                    Spacer {
                        height: styler.themePaddingLarge
                    }
                }
            }

            ExpandingSectionPL {
                id: sectionAutoZoom
                title: app.tr("Automatic zoom")
                content.sourceComponent: FormLayoutPL {
                    spacing: styler.themePaddingMedium
                    width: sectionAutoZoom.width

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
                            if (app.mode === modes.navigate) map.initVoiceNavigation();
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
                        text: app.tr("Snap position to road")
                        visible: app.hasMapMatching
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

                    FormLayoutPL {
                        spacing: styler.themePaddingMedium
                        width: parent.width
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
                            id: speedLimitComboBox
                            description: app.tr("Show speed limit sign")
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
                        text: app.tr("Testing of Text-to-Speech (TTS) engine. " +
                                     "Select the same language as used for navigation, preferred gender, and press " +
                                     "the button below for testing.")
                        truncMode: truncModes.none
                        wrapMode: Text.WordWrap
                    }

                    FormLayoutPL {
                        spacing: styler.themePaddingMedium
                        width: parent.width
                        ComboBoxPL {
                            id: languageComboBox
                            currentIndex: 0
                            label: app.tr("Language")
                            model: [
                                app.tr("English"),
                                app.tr("Catalan"),
                                app.tr("Czech"),
                                app.tr("German"),
                                app.tr("Spanish"),
                                app.tr("French"),
                                app.tr("Hindi"),
                                app.tr("Italian"),
                                app.tr("Russian"),
                                app.tr("Slovak"),
                                app.tr("Swedish")
                            ]
                            property var values: ["en", "ca", "cz", "de", "es", "fr", "hi", "it", "ru", "sl", "sv"]
                            // from https://www.omniglot.com/language/phrases/hovercraft.htm
                            property var phrases: [
                                "My hovercraft is full of eels", // en
                                "El meu aerolliscador està ple d'anguiles", // ca
                                "Moje vznášedlo je plné úhořů", // cz
                                "Mein Luftkissenfahrzeug ist voller Aale", // de
                                "Mi aerodeslizador está lleno de anguilas", // es
                                "Mon aéroglisseur est plein d'anguilles", // fr
                                "मेरी मँडराने वाली नाव सर्पमीनों से भरी हैं", // hi
                                "Il mio hovercraft è pieno di anguille", // it
                                "Моё судно на воздушной подушке полно угрей", // ru
                                "Moje vznášadlo je plné úhorov", // sl
                                "Min svävare är full med ål" // sv
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
                        truncMode: truncModes.none
                        wrapMode: Text.WordWrap
                    }

                    Spacer {
                        height: styler.themePaddingLarge
                    }

                    Timer {
                        interval: 500
                        running: testingColumn.message
                        repeat: true
                        onTriggered: {
                            console.log("Waiting for WAV file")
                            py.call("poor.app.voice_tester.get_uri", [testingColumn.message], function(uri) {
                                if (uri) {
                                    sound.source = uri;
                                    sound.play();
                                    testingColumn.message = "";
                                }
                            });
                        }
                    }

                    function test() {
                        py.call_sync("poor.app.voice_tester_start", []);
                        py.call_sync("poor.app.voice_tester.set_voice",
                                     [ languageComboBox.values[languageComboBox.currentIndex],
                                      genderComboBox.values[genderComboBox.currentIndex] ]);
                        var engine = py.evaluate("poor.app.voice_tester.current_engine");
                        if (engine) description.text = app.tr("Selected voice engine: %1", engine);
                        else {
                            description.text = app.tr("No engine available for selected language.\n\n" +
                                                      "Pure Maps supports Mimic, Flite, PicoTTS, and " +
                                                      "Espeak TTS engines. Unless you are using Pure Maps " +
                                                      "through Flatpak, the engines have to be installed " +
                                                      "separately. Sailfish OS users can find the engines " +
                                                      "at OpenRepos.");
                        }

                        if (!py.evaluate("poor.app.voice_tester.active")) return;
                        testingColumn.message = languageComboBox.phrases[languageComboBox.currentIndex];
                        py.call_sync("poor.app.voice_tester.make",
                                     [testingColumn.message]);
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
