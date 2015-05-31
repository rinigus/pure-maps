/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2014 Osmo Salomaa
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

IconButton {
    anchors.bottom: parent.bottom
    anchors.right: parent.right
    height: icon.height
    icon.source: "icons/north.png"
    rotation: map.rotation
    width: icon.width
    z: 600
    onClicked: {
        if (map.autoRotate) {
            map.autoRotate = false;
            bubble.message = "Auto-rotate off";
        } else {
            map.autoRotate = true;
            bubble.message = "Auto-rotate on";
        }
        bubble.visible = true;
        timer.restart();
    }
    Bubble {
        id: bubble
        align: "right"
        anchorItem: parent
        showArrow: false
        visible: false
    }
    Timer {
        id: timer
        interval: 2000
        onTriggered: bubble.visible = !bubble.visible;
    }
}
