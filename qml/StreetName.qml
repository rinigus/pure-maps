/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2018 Rinigus
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
import "platform"

Rectangle {
    id: master
    anchors.bottom: (app.mode === modes.navigate || app.mode === modes.followMe) ? (app.portrait && app.mode === modes.navigate ? navigationInfoBlock.top : parent.bottom) : menuButton.top
    anchors.bottomMargin: (app.mode === modes.navigate || app.mode === modes.followMe) ? styler.themePaddingSmall : 0
    anchors.left: parent.left
    anchors.leftMargin: styler.themePaddingLarge
    anchors.right: parent.right
    anchors.rightMargin: styler.themePaddingLarge
    color: "transparent"
    height: cover.height
    states: [
        State {
            when: (app.mode === modes.navigate && !app.portrait) || app.mode === modes.followMe
            AnchorChanges {
                target: master
                anchors.left: navigationInfoBlockLandscapeLeftShield.right
                anchors.right: navigationInfoBlockLandscapeRightShield.left
            }
        }
    ]
    visible: !app.modalDialog
    z: 400

    Rectangle {
        id: cover
        anchors.centerIn: streetname
        color: styler.itemBg
        height: streetname.height
        opacity: 0.75
        radius: styler.themePaddingMedium
        visible: streetname.visible
        width: streetname.width + 2*styler.themePaddingMedium
        z: 450
    }

    LabelPL {
        id: streetname
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        color: styler.itemFg
        font.pixelSize: styler.themeFontSizeLarge
        maximumLineCount: 1
        text: gps.streetName
        truncMode: truncModes.fade
        visible: (app.mode === modes.navigate || app.mode === modes.followMe) && (text !== undefined && text !== null && text.length>0)
        width: implicitWidth > master.width - 4*styler.themePaddingMedium ? master.width-4*styler.themePaddingMedium : implicitWidth
        z: 500
    }
}
