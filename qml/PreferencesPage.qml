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
import "."
import "platform"

PagePL {
    title: app.tr("Preferences")

    Column {
        id: column
        anchors.left: parent.left
        anchors.right: parent.right

        ExpandingSectionGroupPL {
            currentIndex: -1

            ExpandingSectionPL {
                id: sectionGeneral
                title: app.tr("General")
                content.sourceComponent: Column {
                    spacing: app.styler.themePaddingMedium
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
                        onCheckedChanged: app.conf.set("auto_complete_geo", autocompleteSwitch.checked)
                    }

                    Spacer {
                        height: app.styler.themePaddingLarge
                    }

                    ButtonPL {
                        anchors.horizontalCenter: parent.horizontalCenter
                        preferredWidth: app.styler.themeButtonWidthLarge
                        text: app.tr("Clear cache")
                        onClicked: map.clearCache();
                    }

                    Spacer {
                        height: app.styler.themePaddingLarge
                    }
                }
            }

            ExpandingSectionPL {
                id: sectionKeys
                title: app.tr("API keys")
                content.sourceComponent: Column {
                    spacing: app.styler.themePaddingMedium
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

                    Repeater {
                        delegate: TextFieldPL {
                            description: model.description
                            label: model.label
                            placeholderText: model.label
                            text: model.value
                            width: sectionKeys.width
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

                    Spacer {
                        height: app.styler.themePaddingLarge
                    }
                }
            }

            ExpandingSectionPL {
                id: sectionExplore
                title: app.tr("Map view")
                content.sourceComponent: Column {
                    spacing: app.styler.themePaddingMedium
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

                    SliderPL {
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
                        height: app.styler.themePaddingLarge
                    }
                }
            }

            ExpandingSectionPL {
                id: sectionNavigate
                title: app.tr("Navigation")
                content.sourceComponent: Column {
                    spacing: app.styler.themePaddingMedium
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

                    Spacer {
                        height: app.styler.themePaddingLarge
                    }
                }
            }

            ExpandingSectionPL {
                id: sectionTesting
                title: app.tr("Testing")
                content.sourceComponent: Column {
                    id: testingColumn
                    spacing: app.styler.themePaddingMedium
                    width: sectionTesting.width

                    property string message

                    ListItemLabel {
                        text: app.tr("Testing of text to speach (TTS) engine. " +
                                     "Select the same language as used for navigation, preferred gender, and press " +
                                     "the button below for testing.")
                        truncMode: truncModes.none
                        wrapMode: Text.WordWrap
                    }

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

                    Spacer {
                        height: app.styler.themePaddingLarge
                    }

                    ButtonPL {
                        anchors.horizontalCenter: parent.horizontalCenter
                        preferredWidth: app.styler.themeButtonWidthLarge
                        text: app.tr("Test")
                        onClicked: testingColumn.test()
                    }

                    Spacer {
                        height: app.styler.themePaddingLarge
                    }

                    LabelPL {
                        id: description
                        anchors.left: parent.left
                        anchors.right: parent.right
                    }

                    Spacer {
                        height: app.styler.themePaddingLarge
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
                        description.text = app.tr("Selected voice engine: %1").arg(py.evaluate("poor.app.voice_tester.current_engine"));
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
                    spacing: app.styler.themePaddingMedium
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
                        height: app.styler.themePaddingLarge
                    }
                }
            }
        }
    }

}
