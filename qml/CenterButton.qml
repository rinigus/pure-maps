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
import "platform"

IconButtonPL {
    id: button
    anchors.bottomMargin: app.styler.themePaddingLarge
    anchors.horizontalCenter: northArrow.horizontalCenter
    anchors.rightMargin: app.styler.themePaddingLarge
    anchors.top: navigationSign.bottom
    anchors.topMargin: app.styler.themePaddingLarge
    height: icon.height
    icon.source: app.getIcon("icons/center")
    icon.sourceSize.height: app.styler.themeIconSizeSmall
    states: [
        State {
            when: hidden && (app.mode === modes.navigate || app.mode === modes.followMe) && !app.portrait
            AnchorChanges {
                target: button
                anchors.bottom: navigationSign.bottom
                anchors.horizontalCenter: undefined
                anchors.right: northArrow.left
                anchors.top: undefined
            }
        },
        State {
            when: hidden
            AnchorChanges {
                target: button
                anchors.bottom: navigationSign.bottom
                anchors.horizontalCenter: undefined
                anchors.top: undefined
                anchors.right: parent.right
            }
        },
        State {
            when: (app.mode === modes.navigate || app.mode === modes.followMe) && !app.portrait
            AnchorChanges {
                target: button
                anchors.bottom: undefined
                anchors.horizontalCenter: undefined
                anchors.right: northArrow.left
                anchors.top: navigationSign.bottom
            }
        }
    ]
    transitions: Transition {
        AnchorAnimation { duration: app.conf.animationDuration; }
    }
    width: icon.width
    z: 500

    property bool hidden: map.cleanMode && !app.conf.mapModeCleanShowCenter

    onClicked: map.centerOnPosition();
}
