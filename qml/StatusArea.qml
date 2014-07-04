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

Rectangle {
    id: statusArea
    color: "#BB000000"
    height: destDist != "" ?
        Math.max(iconImage.height,
                 manLabel.height +
                 narrativeLabel.height +
                 Theme.paddingMedium/2) : 0

    width: parent.width
    z: 400
    property string destDist: ""
    property string destTime: ""
    property string icon: ""
    property string manDist: ""
    property string manTime: ""
    property string narrative: ""
    Image {
        id: iconImage
        anchors.left: parent.left
        fillMode: Image.Pad
        height: statusArea.narrative != "" ?
            Math.max(implicitHeight +
                     2*Theme.paddingLarge,
                     manLabel.height +
                     narrativeLabel.height +
                     Theme.paddingMedium/2): 0

        horizontalAlignment: Image.AlignHCenter
        source: statusArea.icon != "" ?
            "icons/" + statusArea.icon + ".png" :
            "icons/alert.png"
        verticalAlignment: Image.AlignVCenter
        width: statusArea.narrative != "" ?
            implicitWidth + 2*Theme.paddingLarge :
            Theme.paddingMedium
    }
    Label {
        id: manLabel
        anchors.left: iconImage.right
        color: Theme.highlightColor
        font.family: statusArea.narrative != "" ?
            Theme.fontFamilyHeading : Theme.fontFamily
        font.pixelSize: statusArea.narrative != "" ?
            Theme.fontSizeExtraLarge : Theme.fontSizeExtraSmall
        height: statusArea.destDist != "" ?
            implicitHeight : 0
        text: statusArea.manDist
        verticalAlignment: Text.AlignBottom
    }
    Label {
        id: destLabel
        anchors.right: parent.right
        anchors.rightMargin: Theme.paddingMedium
        color: "white"
        font.pixelSize: Theme.fontSizeExtraSmall
        height: manLabel.height
        text: statusArea.destDist + "  ·  " + statusArea.destTime
        verticalAlignment: statusArea.narrative != "" ?
            Text.AlignVCenter : Text.AlignBottom
    }
    Label {
        id: narrativeLabel
        anchors.left: iconImage.right
        anchors.right: parent.right
        anchors.rightMargin: Theme.paddingMedium
        anchors.top: manLabel.bottom
        color: "white"
        font.pixelSize: Theme.fontSizeSmall
        height: statusArea.narrative != "" ?
            implicitHeight + Theme.paddingMedium : 0
        text: statusArea.narrative
        verticalAlignment: Text.AlignTop
        wrapMode: Text.WordWrap
    }
}
