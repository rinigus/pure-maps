/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2018 Osmo Salomaa
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
    id: attribution
    anchors.left: parent.left
    anchors.leftMargin: Theme.paddingLarge
    anchors.top: navigationBlock.bottom
    anchors.topMargin: Theme.paddingSmall
    height: icon.height
    icon.height: icon.sourceSize.height
    icon.smooth: false
    icon.source: ""
    icon.width: icon.sourceSize.width
    visible: !!icon.source
    width: icon.width
    z: 100

    property string logo: ""
    property string text: ""

    Bubble {
        id: bubble
        anchorItem: parent
        lineHeight: 1.15
        padding: Theme.paddingLarge
        showArrow: false
        state: "top-right"
        visible: false
    }

    Timer {
        id: timer
        interval: 3000
        repeat: false
        onTriggered: bubble.visible = false;
    }

    onClicked: {
        bubble.text = "<style>a:link { color: %1; text-decoration: none; }</style>%2"
            .arg(Theme.highlightColor).arg(attribution.text);
        bubble.visible = true;
        timer.restart();
    }

    onLogoChanged: attribution.icon.source = logo ?
        app.getIcon("icons/attribution/%1".arg(logo)) : "";

}
