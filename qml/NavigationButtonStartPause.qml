/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2019 Rinigus, 2019 Purism SPC
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

MapButton {
    id: button
    anchors.bottom: parent.verticalCenter
    anchors.left: parent.left
    anchors.right: undefined
    iconHeight: styler.themeIconSizeSmall
    iconName: app.mode === modes.navigate ? styler.iconPause : styler.iconStart
    states: [
        State {
            when: app.mode === modes.navigate && hidden
            AnchorChanges {
                target: button
                anchors.bottom: speedLimit.top
                anchors.left: undefined
                anchors.right: parent.left
            }
        },
        State {
            when: hidden
            AnchorChanges {
                target: button
                anchors.bottom: parent.verticalCenter
                anchors.left: undefined
                anchors.right: parent.left
            }
        },
        State {
            when: app.mode === modes.navigate
            AnchorChanges {
                target: button
                anchors.bottom: speedLimit.top
                anchors.left: parent.left
                anchors.right: undefined
            }
        }
    ]
    transitions: Transition {
        AnchorAnimation { duration: app.conf.animationDuration; }
    }
    visible: app.mode === modes.exploreRoute || app.mode === modes.navigate
    z: 900

    onClicked: {
        var notifyId = "navigationStartPause";
        if (app.mode === modes.navigate) {
            notification.flash(app.tr("Navigation paused"),
                               notifyId);
            app.setModeExploreRoute();
        } else {
            notification.flash(app.tr("Navigation started"),
                               notifyId);
            app.setModeNavigate();
        }
    }

    property bool hidden: app.modalDialog || app.infoPanelOpen || (map.cleanMode) // && !app.conf.mapModeCleanShowMenuButton)
}
