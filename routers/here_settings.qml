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
        anchors.left: parent.left
        anchors.right: parent.right
        text: app.tr("Traffic")
        visible: full && (typeComboBox.current_key == "car" ||
                          typeComboBox.current_key == "bus" ||
                          typeComboBox.current_key == "taxi")
        Component.onCompleted: checked = app.conf.get("routers.here.traffic")
        onCheckedChanged: {
            if (!visible) return;
            app.conf.set("routers.here.traffic", checked ? 1 : 0);
        }
    }

    TextSwitchPL {
        anchors.left: parent.left
        anchors.right: parent.right
        text: app.tr("Prefer shorter route")
        visible: full && (typeComboBox.current_key == "car" || typeComboBox.current_key == "truck")
        Component.onCompleted: checked = app.conf.get("routers.here.shorter")
        onCheckedChanged: {
            if (!visible) return;
            app.conf.set("routers.here.shorter", checked ? 1 : 0);
        }
    }

    TextSwitchPL {
        anchors.left: parent.left
        anchors.right: parent.right
        text: app.tr("Avoid tolls")
        visible: full
        Component.onCompleted: checked = app.conf.get("routers.here.avoid_toll")
        onCheckedChanged: {
            if (!visible) return;
            app.conf.set("routers.here.avoid_toll", checked ? 1 : 0);
        }
    }

    TextSwitchPL {
        anchors.left: parent.left
        anchors.right: parent.right
        text: app.tr("Avoid highways")
        visible: full
        Component.onCompleted: checked = app.conf.get("routers.here.avoid_highway")
        onCheckedChanged: {
            if (!visible) return;
            app.conf.set("routers.here.avoid_highway", checked ? 1 : 0);
        }
    }

    TextSwitchPL {
        anchors.left: parent.left
        anchors.right: parent.right
        text: app.tr("Avoid tunnels")
        visible: full
        Component.onCompleted: checked = app.conf.get("routers.here.avoid_tunnel")
        onCheckedChanged: {
            if (!visible) return;
            app.conf.set("routers.here.avoid_tunnel", checked ? 1 : 0);
        }
    }

    TextSwitchPL {
        anchors.left: parent.left
        anchors.right: parent.right
        text: app.tr("Avoid dirt roads")
        visible: full
        Component.onCompleted: checked = app.conf.get("routers.here.avoid_dirt")
        onCheckedChanged: {
            if (!visible) return;
            app.conf.set("routers.here.avoid_dirt", checked ? 1 : 0);
        }
    }

    TextSwitchPL {
        anchors.left: parent.left
        anchors.right: parent.right
        text: app.tr("Avoid difficult turns")
        visible: full && (typeComboBox.current_key == "truck")
        Component.onCompleted: checked = app.conf.get("routers.here.avoid_difficult_turn")
        onCheckedChanged: {
            if (!visible) return;
            app.conf.set("routers.here.avoid_difficult_turn", checked ? 1 : 0);
        }
    }

    TextSwitchPL {
        anchors.left: parent.left
        anchors.right: parent.right
        text: app.tr("Avoid ferries")
        visible: full
        Component.onCompleted: checked = app.conf.get("routers.here.avoid_ferry")
        onCheckedChanged: {
            if (!visible) return;
            app.conf.set("routers.here.avoid_ferry", checked ? 1 : 0);
        }
    }

    TextSwitchPL {
        anchors.left: parent.left
        anchors.right: parent.right
        text: app.tr("Avoid car trains")
        visible: full
        Component.onCompleted: checked = app.conf.get("routers.here.avoid_car_train")
        onCheckedChanged: {
            if (!visible) return;
            app.conf.set("routers.here.avoid_car_train", checked ? 1 : 0);
        }
    }

    TextSwitchPL {
        anchors.left: parent.left
        anchors.right: parent.right
        text: app.tr("Avoid seasonally closed roads")
        visible: full
        Component.onCompleted: checked = app.conf.get("routers.here.avoid_seasonal_closure")
        onCheckedChanged: {
            if (!visible) return;
            app.conf.set("routers.here.avoid_seasonal_closure", checked ? 1 : 0);
        }
    }
}
