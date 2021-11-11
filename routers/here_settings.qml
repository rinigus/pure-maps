/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2021 Rinigus
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
import "../qml/platform"
import "../qml"

FormLayoutPL {
    id: settingsBlock
    spacing: styler.themePaddingLarge

    property bool   full: true

    SectionHeaderPL {
        text: app.tr("General options")
        visible: full
    }

    ComboBoxPL {
        id: typeComboBox
        label: app.tr("Type")
        model: [ app.tr("Car"), app.tr("Bicycle"), app.tr("Foot"), app.tr("Motor Scooter"),
            app.tr("Bus"), app.tr("Taxi")]
        property string current_key
        property var keys: ["car", "bicycle", "pedestrian", "scooter", "bus", "taxi"]
        Component.onCompleted: {
            var key = app.conf.get("routers.here.type");
            var index = typeComboBox.keys.indexOf(key);
            typeComboBox.currentIndex = index > -1 ? index : 0;
            current_key = typeComboBox.keys[typeComboBox.currentIndex];
        }
        onCurrentIndexChanged: {
            var key = typeComboBox.keys[typeComboBox.currentIndex]
            current_key = key;
            app.conf.set("routers.here.type", key);
        }
    }

    LanguageSelector {
        id: langComboBox
        key: app.conf.get("routers.here.language")
        // list generated using tools/generate-valhalla-lang.py
        languages: [
            { "key": "af", "name": app.tr("Afrikaans") },
            { "key": "sq", "name": app.tr("Albanian") },
            { "key": "am", "name": app.tr("Amharic") },
            { "key": "ar-sa", "name": app.tr("Arabic (Saudi Arabia)") },
            { "key": "hy", "name": app.tr("Armenian") },
            { "key": "as", "name": app.tr("Assamese") },
            { "key": "az-Latn", "name": app.tr("Azerbaijani (Latin)") },
            { "key": "eu", "name": app.tr("Basque") },
            { "key": "be", "name": app.tr("Belarusian") },
            { "key": "bn-bd", "name": app.tr("Bangla (Bangladesh)") },
            { "key": "bn-in", "name": app.tr("Bangla (India)") },
            { "key": "bs", "name": app.tr("Bosnian") },
            { "key": "bg", "name": app.tr("Bulgarian") },
            { "key": "ca", "name": app.tr("Catalan") },
            { "key": "ca-ES", "name": app.tr("Catalan (Spain)") },
            { "key": "zh-cn", "name": app.tr("Chinese (China)") },
            { "key": "zh-hk", "name": app.tr("Chinese (Hong Kong SAR China)") },
            { "key": "zh-tw", "name": app.tr("Chinese (Taiwan)") },
            { "key": "hr", "name": app.tr("Croatian") },
            { "key": "cs-cz", "name": app.tr("Czech (Czechia)") },
            { "key": "da-dk", "name": app.tr("Danish (Denmark)") },
            { "key": "prs-Arab", "name": app.tr("Persian (Afghanistan)") },
            { "key": "nl-nl", "name": app.tr("Dutch (Netherlands)") },
            { "key": "en-gb", "name": app.tr("English (United Kingdom)") },
            { "key": "en-us", "name": app.tr("English (United States)") },
            { "key": "et", "name": app.tr("Estonian") },
            { "key": "fil-Latn", "name": app.tr("Filipino (Latin)") },
            { "key": "fi-FI", "name": app.tr("Finnish (Finland)") },
            { "key": "fr-FR", "name": app.tr("French (France)") },
            { "key": "gl", "name": app.tr("Galician") },
            { "key": "ka", "name": app.tr("Georgian") },
            { "key": "de-de", "name": app.tr("German (Germany)") },
            { "key": "el-gr", "name": app.tr("Greek (Greece)") },
            { "key": "gu", "name": app.tr("Gujarati") },
            { "key": "ha-Latn", "name": app.tr("Hausa (Latin)") },
            { "key": "he-IL", "name": app.tr("Hebrew (Israel)") },
            { "key": "hi-IN", "name": app.tr("Hindi (India)") },
            { "key": "hu-hu", "name": app.tr("Hungarian (Hungary)") },
            { "key": "is", "name": app.tr("Icelandic") },
            { "key": "ig-Latn", "name": app.tr("Igbo (Latin)") },
            { "key": "id-ID", "name": app.tr("Indonesian (Indonesia)") },
            { "key": "ga", "name": app.tr("Irish") },
            { "key": "it-IT", "name": app.tr("Italian (Italy)") },
            { "key": "ja-jp", "name": app.tr("Japanese (Japan)") },
            { "key": "quc-Latn", "name": app.tr("Kʼicheʼ (Latin)") },
            { "key": "kn", "name": app.tr("Kannada") },
            { "key": "kk", "name": app.tr("Kazakh") },
            { "key": "km", "name": app.tr("Khmer") },
            { "key": "rw-RW", "name": app.tr("Kinyarwanda (Rwanda)") },
            { "key": "kok", "name": app.tr("Konkani") },
            { "key": "ko-KR", "name": app.tr("Korean (South Korea)") },
            { "key": "ku-Arab", "name": app.tr("Kurdish (Arabic)") },
            { "key": "ky-Cyrl", "name": app.tr("Kyrgyz (Cyrillic)") },
            { "key": "lv", "name": app.tr("Latvian") },
            { "key": "lt", "name": app.tr("Lithuanian") },
            { "key": "lb", "name": app.tr("Luxembourgish") },
            { "key": "mk", "name": app.tr("Macedonian") },
            { "key": "ms-MY", "name": app.tr("Malay (Malaysia)") },
            { "key": "ml", "name": app.tr("Malayalam") },
            { "key": "mt", "name": app.tr("Maltese") },
            { "key": "mi-Latn", "name": app.tr("Maori (Latin)") },
            { "key": "mr", "name": app.tr("Marathi") },
            { "key": "mn-Cyrl", "name": app.tr("Mongolian (Cyrillic)") },
            { "key": "ne-NP", "name": app.tr("Nepali (Nepal)") },
            { "key": "no", "name": app.tr("Norwegian") },
            { "key": "nn", "name": app.tr("Norwegian Nynorsk") },
            { "key": "or", "name": app.tr("Odia") },
            { "key": "nso", "name": app.tr("Northern Sotho") },
            { "key": "fa", "name": app.tr("Persian") },
            { "key": "pl-pl", "name": app.tr("Polish (Poland)") },
            { "key": "pt-BR", "name": app.tr("Portuguese (Brazil)") },
            { "key": "pt-pt", "name": app.tr("Portuguese (Portugal)") },
            { "key": "pa", "name": app.tr("Punjabi") },
            { "key": "pa-Arab", "name": app.tr("Punjabi (Arabic)") },
            { "key": "quz-Latn-PE", "name": app.tr("Cusco Quechua (Latin, Peru)") },
            { "key": "ro-ro", "name": app.tr("Romanian (Romania)") },
            { "key": "ru-ru", "name": app.tr("Russian (Russia)") },
            { "key": "gd-Latn", "name": app.tr("Scottish Gaelic (Latin)") },
            { "key": "sr-Cyrl-BA", "name": app.tr("Serbian (Cyrillic, Bosnia & Herzegovina)") },
            { "key": "sr-Cyrl-RS", "name": app.tr("Serbian (Cyrillic, Serbia)") },
            { "key": "sr-Latn-RS", "name": app.tr("Serbian (Latin, Serbia)") },
            { "key": "sd-Arab", "name": app.tr("Sindhi (Arabic)") },
            { "key": "si", "name": app.tr("Sinhala") },
            { "key": "sk-sk", "name": app.tr("Slovak (Slovakia)") },
            { "key": "sl-si", "name": app.tr("Slovenian (Slovenia)") },
            { "key": "es-es", "name": app.tr("Spanish (Spain)") },
            { "key": "sw", "name": app.tr("Swahili") },
            { "key": "sv-SE", "name": app.tr("Swedish (Sweden)") },
            { "key": "tg-Cyrl", "name": app.tr("Tajik (Cyrillic)") },
            { "key": "ta", "name": app.tr("Tamil") },
            { "key": "tt-Cyrl", "name": app.tr("Tatar (Cyrillic)") },
            { "key": "te", "name": app.tr("Telugu") },
            { "key": "th-TH", "name": app.tr("Thai (Thailand)") },
            { "key": "ti", "name": app.tr("Tigrinya") },
            { "key": "tn", "name": app.tr("Tswana") },
            { "key": "tr-TR", "name": app.tr("Turkish (Turkey)") },
            { "key": "tk-Latn", "name": app.tr("Turkmen (Latin)") },
            { "key": "uk", "name": app.tr("Ukrainian") },
            { "key": "ur", "name": app.tr("Urdu") },
            { "key": "ug-Arab", "name": app.tr("Uyghur (Arabic)") },
            { "key": "uz-Cyrl", "name": app.tr("Uzbek (Cyrillic)") },
            { "key": "vi", "name": app.tr("Vietnamese") },
            { "key": "cy", "name": app.tr("Welsh") },
            { "key": "wo-Latn", "name": app.tr("Wolof (Latin)") },
            { "key": "xh", "name": app.tr("Xhosa") },
            { "key": "yo-Latn", "name": app.tr("Yoruba (Latin)") },
            { "key": "zu-ZA", "name": app.tr("Zulu (South Africa)") }
        ]
        visible: full
        onKeyChanged: app.conf.set("routers.here.language", key)
    }

    SectionHeaderPL {
        text: app.tr("Advanced options")
        visible: full
    }

    TextSwitchPL {
        id: autoShorterSwitch
        anchors.left: parent.left
        anchors.right: parent.right
        text: app.tr("Prefer shorter route")
        visible: full && (typeComboBox.current_key == "car" || typeComboBox.current_key == "truck")
        Component.onCompleted: checked = app.conf.get("routers.here.shorter")
        onCheckedChanged: {
            if (!autoShorterSwitch.visible) return;
            app.conf.set("routers.here.shorter", checked ? 1 : 0);
        }
    }

    ComboBoxPL {
        id: bicycleTypeComboBox
        label: app.tr("Bicycle type")
        model: [ app.tr("Road"), app.tr("Hybrid or City (default)"), app.tr("Cross"), app.tr("Mountain") ]
        visible: full && typeComboBox.current_key == "bicycle"
        property var keys: ["Road", "Hybrid", "Cross", "Mountain"]
        Component.onCompleted: {
            var key = app.conf.get("routers.here.bicycle_type");
            var index = bicycleTypeComboBox.keys.indexOf(key);
            bicycleTypeComboBox.currentIndex = index > -1 ? index : 1;
        }
        onCurrentIndexChanged: {
            var key = bicycleTypeComboBox.keys[bicycleTypeComboBox.currentIndex]
            app.conf.set("routers.here.bicycle_type", key);
        }
    }

    ComboBoxPL {
        id: useBusComboBox
        description: app.tr("Your desire to use buses.")
        label: app.tr("Bus")
        model: [ app.tr("Avoid"), app.tr("Prefer to avoid"), app.tr("No preference (default)"), app.tr("Incline"), app.tr("Prefer") ]
        visible: full && typeComboBox.current_key == "transit"
        property var keys: [0.0, 0.25, 0.5, 0.75, 1.0]
        Component.onCompleted: {
            var key = app.conf.get("routers.here.use_bus");
            useBusComboBox.currentIndex = settingsBlock.getIndex(useBusComboBox.keys,key);
        }
        onCurrentIndexChanged: {
            var key = useBusComboBox.keys[useBusComboBox.currentIndex]
            app.conf.set("routers.here.use_bus", key);
        }
    }

    ComboBoxPL {
        id: maxHikingDifficultyComboBox
        description: app.tr("The maximum difficulty of hiking trails that is allowed.")
        label: app.tr("Hiking difficulty")
        model: [ app.tr("Walking"), app.tr("Hiking (default)"), app.tr("Mountain hiking"),
            app.tr("Demanding mountain hiking"), app.tr("Alpine hiking"), app.tr("Demanding alpine hiking") ]
        visible: full && typeComboBox.current_key == "pedestrian"
        property var keys: [0, 1, 2, 3, 4, 5]
        Component.onCompleted: {
            var key = app.conf.get("routers.here.max_hiking_difficulty");
            var index = maxHikingDifficultyComboBox.keys.indexOf(key);
            maxHikingDifficultyComboBox.currentIndex = index > -1 ? index : 1;
        }
        onCurrentIndexChanged: {
            var key = maxHikingDifficultyComboBox.keys[maxHikingDifficultyComboBox.currentIndex]
            app.conf.set("routers.here.max_hiking_difficulty", key);
        }
    }

    ComboBoxPL {
        id: useFerryComboBox
        label: app.tr("Ferries")
        model: [ app.tr("Avoid"), app.tr("Prefer to avoid"), app.tr("No preference (default)"),
            app.tr("Incline"), app.tr("Prefer") ]
        visible: full && typeComboBox.current_key != "transit"
        property var keys: [0.0, 0.25, 0.5, 0.75, 1.0]
        Component.onCompleted: {
            var key = app.conf.get("routers.here.use_ferry");
            useFerryComboBox.currentIndex = settingsBlock.getIndex(useFerryComboBox.keys,key);
        }
        onCurrentIndexChanged: {
            var key = useFerryComboBox.keys[useFerryComboBox.currentIndex]
            app.conf.set("routers.here.use_ferry", key);
        }
    }

    ComboBoxPL {
        id: useHighwaysComboBox
        label: app.tr("Highways")
        model: [app.tr("Avoid"), app.tr("Prefer to avoid"), app.tr("No preference"),
            app.tr("Incline"), app.tr("Prefer (default)") ]
        visible: full && (typeComboBox.current_key == "auto" || typeComboBox.current_key == "bus" ||
                          typeComboBox.current_key == "hov" || typeComboBox.current_key == "motorcycle" ||
                          typeComboBox.current_key == "motor_scooter")
        property var keys: [0.0, 0.25, 0.5, 0.75, 1.0]
        Component.onCompleted: {
            var key = app.conf.get("routers.here.use_highways");
            useHighwaysComboBox.currentIndex = settingsBlock.getIndex(useHighwaysComboBox.keys,key);
        }
        onCurrentIndexChanged: {
            var key = useHighwaysComboBox.keys[useHighwaysComboBox.currentIndex]
            app.conf.set("routers.here.use_highways", key);
        }
    }

    ComboBoxPL {
        id: useHillsComboBox
        description: app.tr("Your desire to tackle hills. When avoiding hills and steep grades, longer (time and distance) routes can be selected. By allowing hills, it indicates you do not fear hills and steeper grades.")
        label: app.tr("Hills")
        model: [ app.tr("Avoid"), app.tr("No preference (default)"), app.tr("Allow") ]
        visible: full && (typeComboBox.current_key == "bicycle" || typeComboBox.current_key == "motor_scooter")
        property var keys: [0.0, 0.5, 1.0]
        Component.onCompleted: {
            var key = app.conf.get("routers.here.use_hills");
            useHillsComboBox.currentIndex = settingsBlock.getIndex(useHillsComboBox.keys,key);
        }
        onCurrentIndexChanged: {
            var key = useHillsComboBox.keys[useHillsComboBox.currentIndex]
            app.conf.set("routers.here.use_hills", key);
        }
    }

    ComboBoxPL {
        id: usePrimaryComboBox
        label: app.tr("Primary roads")
        model: [ app.tr("Avoid"), app.tr("Prefer to avoid"), app.tr("No preference (default)"),
            app.tr("Incline"), app.tr("Prefer") ]
        visible: full && typeComboBox.current_key == "motor_scooter"
        property var keys: [0.0, 0.25, 0.5, 0.75, 1.0]
        Component.onCompleted: {
            var key = app.conf.get("routers.here.use_primary");
            usePrimaryComboBox.currentIndex = settingsBlock.getIndex(usePrimaryComboBox.keys,key);
        }
        onCurrentIndexChanged: {
            var key = usePrimaryComboBox.keys[usePrimaryComboBox.currentIndex]
            app.conf.set("routers.here.use_primary", key);
        }
    }

    ComboBoxPL {
        id: useRailComboBox
        description: app.tr("Your desire to use rail/subway/metro.")
        label: app.tr("Rail")
        model: [ app.tr("Avoid"), app.tr("Prefer to avoid"), app.tr("No preference (default)"),
            app.tr("Incline"), app.tr("Prefer") ]
        visible: full && typeComboBox.current_key == "transit"
        property var keys: [0.0, 0.25, 0.5, 0.75, 1.0]
        Component.onCompleted: {
            var key = app.conf.get("routers.here.use_rail");
            useRailComboBox.currentIndex = settingsBlock.getIndex(useRailComboBox.keys,key);
        }
        onCurrentIndexChanged: {
            var key = useRailComboBox.keys[useRailComboBox.currentIndex]
            app.conf.set("routers.here.use_rail", key);
        }
    }

    ComboBoxPL {
        id: useRoadsComboBox
        description: app.tr("Your propensity to use roads alongside other vehicles.")
        label: app.tr("Roads")
        model: [ app.tr("Avoid"), app.tr("No preference (default)"), app.tr("Prefer") ]
        visible: full && typeComboBox.current_key == "bicycle"
        property var keys: [0.0, 0.5, 1.0]
        Component.onCompleted: {
            var key = app.conf.get("routers.here.use_roads");
            useRoadsComboBox.currentIndex = settingsBlock.getIndex(useRoadsComboBox.keys,key);
        }
        onCurrentIndexChanged: {
            var key = useRoadsComboBox.keys[useRoadsComboBox.currentIndex]
            app.conf.set("routers.here.use_roads", key);
        }
    }

    ComboBoxPL {
        id: useTollsComboBox
        label: app.tr("Tolls")
        model: [ app.tr("Avoid"), app.tr("No preference (default)"), app.tr("Prefer") ]
        visible: full && (typeComboBox.current_key == "auto" || typeComboBox.current_key == "bus" ||
                          typeComboBox.current_key == "hov" || typeComboBox.current_key == "motorcycle" ||
                          typeComboBox.current_key == "motor_scooter")
        property var keys: [0.0, 0.5, 1.0]
        Component.onCompleted: {
            var key = app.conf.get("routers.here.use_tolls");
            useTollsComboBox.currentIndex = settingsBlock.getIndex(useTollsComboBox.keys,key);
        }
        onCurrentIndexChanged: {
            var key = useTollsComboBox.keys[useTollsComboBox.currentIndex]
            app.conf.set("routers.here.use_tolls", key);
        }
    }

    ComboBoxPL {
        id: useTrailsComboBox
        description: app.tr("Your desire for adventure. When preferred, router will tend to avoid major roads and route on secondary roads, sometimes on using trails, tracks, unclassified roads or roads with bad surfaces.")
        label: app.tr("Trails")
        model: [ app.tr("Avoid (default)"), app.tr("Prefer to avoid"), app.tr("No preference"),
            app.tr("Incline"), app.tr("Prefer") ]
        visible: full && typeComboBox.current_key == "motorcycle"
        property var keys: [0.0, 0.25, 0.5, 0.75, 1.0]
        Component.onCompleted: {
            var key = app.conf.get("routers.here.use_trails");
            useTrailsComboBox.currentIndex = settingsBlock.getIndex(useTrailsComboBox.keys,key);
        }
        onCurrentIndexChanged: {
            var key = useTrailsComboBox.keys[useTrailsComboBox.currentIndex]
            app.conf.set("routers.here.use_trails", key);
        }
    }

    ComboBoxPL {
        id: useTransfersComboBox
        label: app.tr("Transfers")
        model: [ app.tr("Avoid"), app.tr("No preference (default)"), app.tr("Prefer") ]
        visible: full && typeComboBox.current_key == "transit"
        property var keys: [0.0, 0.5, 1.0]
        Component.onCompleted: {
            var key = app.conf.get("routers.here.use_transfers");
            useTransfersComboBox.currentIndex = settingsBlock.getIndex(useTransfersComboBox.keys,key);
        }
        onCurrentIndexChanged: {
            var key = useTransfersComboBox.keys[useTransfersComboBox.currentIndex]
            app.conf.set("routers.here.use_transfers", key);
        }
    }

    function getIndex(arr, val) {
        // for sorted short arrays
        if (arr==null || arr.length <= 1)
            return 0;
        for (var i = 1; i < arr.length; i++) {
            if (arr[i] > val) {
                var p = arr[i-1];
                var c = arr[i]
                return Math.abs( p-val ) < Math.abs( c-val ) ? i-1 : i;
            }
        }
        return arr.length-1;
    }

}
