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
import "."

Bubble {
    id: bubble
    anchorItem: navigationBlock
    anchors.topMargin: app.styler.themePaddingLarge
    opacity: stack.length > 0
    showArrow: false
    state: "bottom-center"
    text: {
        if (stack.length)
            return stack.reduce(function (a,b) {
                if (a) return a + '. ' + b.text;
                return b.text;
            }, '');
        return '';
    }
    visible: opacity > 0

    property var stack: []

    Behavior on opacity {
        OpacityAnimator {
            duration: 200
            easing.type: Easing.InOutQuad
        }
    }

    Timer {
        id: timer
        interval: 1000
        repeat: bubble.stack.length > 0
        running: bubble.stack.length > 0
        onTriggered: {
            var t = Date.now();
            bubble.stack = bubble.stack.filter(function (txt) {
                return txt.timeout < 0 || txt.timeout > t;
            });
        }
    }

    function clear(textId) {
        textId = textId || 'none';
        bubble.stack = bubble.stack.filter(function (txt) {
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
        var ns = bubble.stack;
        if (ns.length > 0) {
            ns = ns.filter(function (i) {
                return i.id !== t.id;
            });
            ns.push(t);
        } else
            ns = [t];
        bubble.stack = ns;
    }

    function hold(text, textId) {
        flash(text, textId, -1);
    }

}
