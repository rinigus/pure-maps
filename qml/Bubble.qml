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
    anchors.bottom: anchorItem.top
    anchors.horizontalCenter: anchorItem.horizontalCenter

    property var    anchorItem: undefined
    property string align: "center"
    property real   buttonHeight: 0
    property real   buttonWidth: 0
    property var    contentItem: bubble
    property string message: ""
    property real   paddingX: 0.75*Theme.paddingLarge
    property real   paddingY: 0.50*Theme.paddingLarge
    property bool   showArrow: true

    signal clicked()
    Rectangle {
        id: bubble
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.showArrow ? 18 : 6
        anchors.horizontalCenter: parent.align == "center" ? parent.horizontalCenter : undefined
        anchors.right: parent.align == "right" ? parent.right : undefined
        anchors.left: parent.align == "left" ? parent.left : undefined
        color: "#bb000000"
        height: parent.buttonHeight > 0 ?
            label.height + parent.buttonHeight + 3*parent.paddingY :
            label.height + 2*parent.paddingY
        radius: Theme.fontSizeSmall/2
        visible: parent.visible
        width: label.width + 2*parent.paddingX
    }
    Label {
        id: label
        anchors.left: bubble.left
        anchors.leftMargin: parent.paddingX
        anchors.top: bubble.top
        anchors.topMargin: parent.paddingY
        color: "white"
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
        text: parent.message
        textFormat: Text.RichText
        visible: parent.visible
        width: Math.max(Math.min(
            0.65*Math.min(app.screenWidth, app.screenHeight),
            implicitWidth), parent.buttonWidth)
        wrapMode: Text.WordWrap
    }
    MouseArea {
        anchors.fill: label
        onClicked: parent.clicked();
    }
    Image {
        id: arrow
        anchors.horizontalCenter: bubble.horizontalCenter
        anchors.top: bubble.bottom
        // Try to avoid a stripe between bubble and arrow.
        anchors.topMargin: -0.5
        source: "icons/bubble-arrow.png"
        visible: parent.visible && parent.showArrow
    }
}
