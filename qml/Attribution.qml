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

Column {

    property string logoSource
    property string infoText

    anchors.bottom: scaleBar.top
    anchors.bottomMargin: Theme.paddingSmall
    anchors.left: parent.left
    anchors.leftMargin: Theme.paddingLarge

    z: 100

    spacing: Theme.paddingMedium

    function clearInfo() {
        info.clear();
    }

    function setInfo(infotxt) {
        infoText = infotxt
    }

    function setLogo(logo) {
        image.source = logo;
        if (logo) image.visible = true;
        else image.visible = false;
    }

    Image {
        id: info
        source: "icons/attribution/attrib.svg"

        // size matches the size of Mapbox logo circle
        height: sourceSize.height / 2.5 * Theme.pixelRatio * 1.5
        width: sourceSize.width / 2.5 * Theme.pixelRatio * 1.5

        function clear(text) {
            infoBubble.opacity = 0;
        }

        function show() {
            infoBubble.opacity = 1;
        }

        Bubble {
            id: infoBubble
            anchorItem: info
            opacity: 0
            showArrow: false
            state: "top-right"
            text: "<style>a:link { color: " + Theme.highlightColor + "; }</style> " + infoText
            visible: opacity > 0

            Behavior on opacity { FadeAnimator {} }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: info.show();
        }
    }

    Image {
        id: image

        source: logoSource

        visible: true
        //anchors.verticalCenter: info.verticalCenter

        height: sourceSize.height * Theme.pixelRatio * 1.5
        width: sourceSize.width * Theme.pixelRatio * 1.5
    }
}
