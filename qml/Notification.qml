/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2017 Osmo Salomaa, 2019 Rinigus, 2019 Purism SPC
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

import QtQuick 2.2
import "platform"

Rectangle {
    id: rect
    anchors.top: referenceBlockTop.bottom
    anchors.topMargin: styler.themePaddingLarge
    anchors.horizontalCenter: parent.horizontalCenter
    color: styler.blockBg
    height: label.height + 2*padding
    opacity: currentText ? 1 : 0
    radius: 0.85 * padding
    visible: !app.modalDialog && label.text
    width: label.width + 2*padding
    z: 400

    property string currentText: {
        if (stack.length)
            return stack.reduce(function (a,b) {
                if (a) return a + '\n' + b.text;
                return b.text;
            }, '');
        return '';
    }
    property string lastText
    // Padding on the edges
    property real   padding: 1.5 * styler.themePaddingMedium
    property var    stack: []
    property real   widthLimit: parent.width / 2

    Behavior on opacity {
        OpacityAnimator {
            duration: 200
            easing.type: Easing.InOutQuad
            onRunningChanged: if (!currentText && !running) lastText = ''
        }
    }

    LabelPL {
        id: label
        anchors.centerIn: rect
        color: styler.themeHighlightColor
        font.family: styler.themeFontFamily
        font.pixelSize: styler.themeFontSizeSmall
        horizontalAlignment: Text.AlignHCenter
        lineHeight: 1.1
        text: currentText ? currentText : lastText
        wrapMode: Text.WordWrap
        width: Math.min(implicitWidth, rect.widthLimit)
    }

    Timer {
        id: timer
        interval: 1000
        repeat: stack.length > 0
        running: stack.length > 0
        onTriggered: {
            var t = Date.now();
            stack = stack.filter(function (txt) {
                return txt.timeout < 0 || txt.timeout > t;
            });
        }
    }

    onCurrentTextChanged: if (currentText) lastText = currentText

    function clear(textId) {
        textId = textId || 'none';
        stack = stack.filter(function (txt) {
            return txt.id !== textId;
        });
    }

    function flash(text, textId, timeout) {
        var tout = Date.now();
        if (timeout > 0) tout += timeout*1000;
        else if (timeout < 0) tout = -1;
        else tout += 5000; // default
        var t = { 'text': text,
            'id': textId || 'none',
            'timeout': tout };
        var ns = stack;
        if (ns.length > 0) {
            ns = ns.filter(function (i) {
                return i.id !== t.id;
            });
            ns.push(t);
        } else
            ns = [t];
        stack = ns;
    }

    function hold(text, textId) {
        flash(text, textId, -1);
    }

}
