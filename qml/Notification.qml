/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2017 Osmo Salomaa
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

Bubble {
    id: bubble
    anchorItem: navigationBlock
    anchors.topMargin: Theme.paddingLarge
    opacity: 0
    showArrow: false
    state: "bottom-center"
    visible: opacity > 0

    Behavior on opacity { FadeAnimator {} }

    Timer {
        id: timer
        interval: 5000
        repeat: false
        onTriggered: bubble.opacity = 0;
    }

    function clear(text) {
        bubble.opacity = 0;
        timer.stop();
    }

    function flash(text) {
        bubble.text = text;
        bubble.opacity = 1;
        timer.restart();
    }

    function hold(text) {
        bubble.text = text;
        bubble.opacity = 1;
        timer.stop();
    }

}
