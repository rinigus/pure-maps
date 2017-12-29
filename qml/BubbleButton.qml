/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2015 Osmo Salomaa
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

Rectangle {
    id: button
    color: "#bbffffff"
    height: label.height + 1.5 * Theme.paddingMedium
    radius: Theme.paddingSmall
    width: label.width + 2.5 * Theme.paddingMedium

    property string text: ""

    // Use a pressed effect only when the associated action has
    // a delay, e.g. launching an external application.
    property bool useHighlight: false

    signal clicked()

    Label {
        id: label
        anchors.centerIn: parent
        color: "black"
        font.pixelSize: Theme.fontSizeExtraSmall
        text: button.text
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            if (button.useHighlight) {
                button.color = Theme.highlightColor;
                timer.restart();
            }
            button.clicked();
        }
    }

    Timer {
        id: timer
        interval: 3000
        repeat: false
        onTriggered: button.color = "#bbffffff";
    }

}
