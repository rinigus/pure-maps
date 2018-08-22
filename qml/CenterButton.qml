/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2018 Osmo Salomaa, 2018 Rinigus
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

IconButton {
    id: button
    anchors.right: parent.right
    anchors.top: navigationSign.bottom
    height: icon.height
    icon.height: icon.sourceSize.height
    icon.smooth: false
    icon.source: app.getIcon("icons/center")
    icon.width: icon.sourceSize.width
    states: [
        State {
            when: app.navigationActive && app.portrait
            AnchorChanges {
                target: button
                anchors.right: undefined
                anchors.horizontalCenter: app.northArrow.horizontalCenter
            }
        },
        State {
            when: app.navigationActive && !app.portrait
            AnchorChanges {
                target: button
                anchors.right: app.northArrow.left
                anchors.top: undefined
                anchors.verticalCenter: app.northArrow.verticalCenter
            }
        }
    ]
    width: icon.width
    z: 500

    onClicked: map.centerOnPosition();
}
