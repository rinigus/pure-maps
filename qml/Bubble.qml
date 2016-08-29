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
    id: bubble
    anchors.bottom: anchorItem.top
    anchors.bottomMargin: arrow.height + Theme.paddingSmall
    anchors.horizontalCenter: position === "center" ? anchorItem.horizontalCenter : undefined
    anchors.left: position === "right" ? anchorItem.horizontalCenter : undefined
    anchors.right: position === "left" ? anchorItem.horizontalCenter : undefined
    color: "#d0000000"
    height: controls.height + label.height +
        (controlHeight > 0 ? 3 : 2) * padding
    radius: 2*Theme.paddingSmall
    width: Math.max(Math.min(
        label.implicitWidth,
        0.65*app.screenWidth,
        0.65*app.screenHeight,
        500*Theme.pixelRatio), bubble.controlWidth) + 2*padding
    property var anchorItem: undefined
    property real controlHeight: 0
    property real controlWidth: 0
    property real padding: 1.5*Theme.paddingMedium
    property string position: "center"
    property string text: ""
    property bool showArrow: true
    signal clicked()
    Image {
        id: arrow
        anchors.horizontalCenter: bubble.horizontalCenter
        anchors.top: bubble.bottom
        // Try to avoid a stripe between bubble and arrow.
        anchors.topMargin: -0.5
        smooth: false
        source: app.getIcon("icons/bubble-arrow")
        visible: bubble.visible && bubble.showArrow
    }
    Rectangle {
        id: controls
        anchors.bottom: bubble.bottom
        anchors.bottomMargin: bubble.padding
        anchors.left: bubble.left
        anchors.leftMargin: bubble.padding
        anchors.right: bubble.right
        anchors.rightMargin: bubble.padding
        color: "#00000000"
        height: bubble.controlHeight
    }
    Label {
        id: label
        anchors.bottom: controls.top
        anchors.bottomMargin: bubble.controlHeight > 0 ? bubble.padding : 0
        anchors.left: bubble.left
        anchors.leftMargin: bubble.padding
        anchors.right: bubble.right
        anchors.rightMargin: bubble.padding
        color: "white"
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontSizeSmall
        text: bubble.text
        textFormat: Text.RichText
        visible: bubble.visible
        wrapMode: Text.WordWrap
    }
    MouseArea {
        anchors.fill: label
        onClicked: bubble.clicked();
    }
    onWidthChanged: label.doLayout();
}
