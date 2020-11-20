/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2020 Rinigus
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

Item {
    id: voice

    property bool   active: false
    property string currentEngine
    property string engine // has to be set
    property string gender: "male"
    property string language

    Timer {
        id: currentPlay
        interval: 500
        repeat: true
        running: text

        property string text
        property int tries: 0

        onTextChanged: {
            tries = 0;
            check();
        }

        onTriggered: {
            if (tries > 10) {
                console.log("Failed to get sound file for: " + text);
                text = "";
                return;
            }
            tries += 1;
            check();
        }

        function check() {
            if (!text) return;
            var t = text;
            console.log("Waiting for sound file: " + text)
            py.call("poor.app.voice_get_uri", [engine, text], function(uri) {
                if (uri && text === t) {
                    console.log("Going to play: " + text)
                    app.play(uri);
                    text = "";
                }
            });
        }
    }

    onEnabledChanged: init()
    onGenderChanged: init()
    onLanguageChanged: init()

    function init() {
        if (!enabled || !engine) {
            active = false;
            currentEngine = "";
            return;
        }
        console.log('Initializing voice engine ' + engine + ' ' + language + ' ' + gender);
        var args = [engine, language, gender];
        py.call_sync("poor.app.set_voice", args);
        currentEngine = py.call_sync("poor.app.voice_current_engine", [engine]);
        active = py.call_sync("poor.app.voice_active", [engine]);
        console.log('Voice engine: ' + engine + ' ' + currentEngine + ' active=' + active);
    }

    function play(text) {
        currentPlay.text = text;
    }

    function prepare(text, preserve) {
        if (!active) return;
        py.call_sync("poor.app.voice_make", [engine, text, preserve]);
    }
}
