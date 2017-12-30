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
    anchors.bottomMargin: Theme.paddingSmall
    anchors.right: parent.right
    anchors.rightMargin: Theme.paddingSmall
    icon.rotation: map.autoRotate ? -map.bearing : 0
    icon.smooth: true
    icon.source: app.getIcon("icons/north")
    z: 600

    onClicked: {
        if (map.autoRotate) {
            map.autoRotate = false;
            bubble.text = app.tr("Auto-rotate off");
        } else {
            map.autoRotate = true;
            bubble.text = app.tr("Auto-rotate on");
        }
        bubble.visible = true;
        timer.restart();
    }

    Bubble {
        id: bubble
        anchorItem: parent
        showArrow: false
        state: "top-left"
        visible: false
    }

    Timer {
        id: timer
        interval: 2000
        repeat: false
        onTriggered: bubble.visible = false;
    }

}
