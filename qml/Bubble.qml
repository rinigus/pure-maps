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

Item {
    id: bubble
    anchors.bottom: anchorItem.top
    anchors.horizontalCenter: anchorItem.horizontalCenter
    state: "center"
    states: [
        State {
            name: "center"
            AnchorChanges {
                target: content
                anchors.horizontalCenter: bubble.horizontalCenter
            }
        },
        State {
            name: "left"
            AnchorChanges {
                target: content
                anchors.right: bubble.horizontalCenter
            }
        },
        State {
            name: "right"
            AnchorChanges {
                target: content
                anchors.left: bubble.horizontalCenter
            }
        }
    ]

    property var    anchorItem: undefined
    property real   buttonBlockHeight: 0
    property real   buttonBlockWidth: 0
    property var    content: content
    property string message: ""
    property real   paddingX: 0.75*Theme.paddingLarge
    property real   paddingY: 0.50*Theme.paddingLarge
    property bool   showArrow: true

    signal clicked()

    Rectangle {
        id: content
        anchors.bottom: bubble.bottom
        anchors.bottomMargin: bubble.showArrow ? 18 : 6
        color: "#bb000000"
        height: label.height + 2*bubble.paddingY + bubble.buttonBlockHeight +
            (bubble.buttonBlockHeight > 0) * 2*bubble.paddingY
        radius: Theme.fontSizeSmall/2
        visible: bubble.visible
        width: label.width + 2*bubble.paddingX
    }
    Label {
        id: label
        anchors.left: content.left
        anchors.leftMargin: bubble.paddingX
        anchors.top: content.top
        anchors.topMargin: bubble.paddingY
        color: "white"
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
        text: bubble.message
        textFormat: Text.RichText
        visible: bubble.visible
        width: Math.max(Math.min(
            0.65*Math.min(app.screenWidth, app.screenHeight),
            implicitWidth), bubble.buttonBlockWidth)
        wrapMode: Text.WordWrap
    }
    MouseArea {
        anchors.fill: label
        onClicked: bubble.clicked();
    }
    Image {
        id: arrow
        anchors.horizontalCenter: content.horizontalCenter
        anchors.top: content.bottom
        // Try to avoid a stripe between bubble and arrow.
        anchors.topMargin: -0.5
        source: "icons/bubble-arrow.png"
        visible: bubble.visible && bubble.showArrow
    }
}
