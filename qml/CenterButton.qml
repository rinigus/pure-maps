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
    anchors.bottom: parent.bottom
    anchors.bottomMargin: app.styler.themePaddingLarge + menuButton.height/2 - height/2
    anchors.horizontalCenter: northArrow.horizontalCenter
    anchors.rightMargin: app.styler.themePaddingLarge
    anchors.topMargin: app.styler.themePaddingLarge
    iconHeight: app.styler.themeIconSizeSmall
    iconSource: app.getIcon("icons/center")
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
            when: hidden && (app.mode === modes.navigate || app.mode === modes.followMe)
            AnchorChanges {
                target: button
                anchors.bottom: navigationSign.bottom
                anchors.horizontalCenter: undefined
                anchors.right: undefined
                anchors.top: undefined
            }
            PropertyChanges {
                target: button
                anchors.bottomMargin: 0
            }
        },
        State {
            when: hidden
            AnchorChanges {
                target: button
                anchors.bottom: undefined
                anchors.horizontalCenter: northArrow.horizontalCenter
                anchors.right: undefined
                anchors.top: parent.bottom
            }
            PropertyChanges {
                target: button
                anchors.topMargin: 0
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
        },
        State {
            when: (app.mode === modes.navigate || app.mode === modes.followMe)
            AnchorChanges {
                target: button
                anchors.bottom: undefined
                anchors.horizontalCenter: northArrow.horizontalCenter
                anchors.right: undefined
                anchors.top: navigationSign.bottom
            }
        }
    ]
    transitions: Transition {
        AnchorAnimation { duration: app.conf.animationDuration; }
    }
    z: 500

    property bool hidden: app.infoPanelOpen || (map.cleanMode && !app.conf.mapModeCleanShowCenter)

    onClicked: map.centerOnPosition();
}
