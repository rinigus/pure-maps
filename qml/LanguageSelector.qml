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
import "platform"

ComboBoxPL {
    id: comboBox
    label: app.tr("Language")
    model: []

    property string key
    property int languageIndex: -1 // current selected index
    property var languages // has to be set on construction

    Component.onCompleted: {
        var p = [];
        for (var i=0; i < languages.length; i++)
            p.push(languages[i].name);
        p.sort();
        model = p;
        // as ancient Qt used by SFOS is unaware of findIndex
        var index = languageIndex;
        for (var i=0; i < languages.length && index < 0; i++)
            if (languages[i].key === key)
                index = i;
        if (index < 0) { // set to English by default
            var eng = app.tr("English");
            var eng_us = app.tr("English (United States)");
            for (var i=0; i < languages.length && index < 0; i++)
                if (languages[i].name === eng || languages[i].name === eng_us)
                    index = i;
        }
        // TODO: replace with the implementation for newer Qt
        //            var index = languages.findIndex(function (l) { return l.key === key; } );
        //            if (index < 0) { // set to English by default
        //                var eng = app.tr("English");
        //                index = languages.findIndex(function (l) { return l.name === eng; } );
        //            }
        index = model.indexOf(languages[index].name);
        comboBox.currentIndex = index;
    }
    onCurrentIndexChanged: {
        if (comboBox.currentIndex < 0) return;
        var name = model[comboBox.currentIndex];
        var index = -1;
        for (var i=0; i < languages.length && index < 0; i++)
            if (languages[i].name === name)
                index = i;
        if (index > -1) {
            key = languages[index].key;
            languageIndex = index;
        }
    }
}
