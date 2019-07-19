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
    anchors.right: parent.right
    iconHeight: styler.themeIconSizeSmall
    iconSource: app.getIcon("icons/map-layers")
    states: [
        State {
            when: hidden
            AnchorChanges {
                target: button
                anchors.right: undefined
                anchors.left: parent.right
            }
        }
    ]
    transitions: Transition {
        AnchorAnimation { duration: app.conf.animationDuration; }
        onRunningChanged: {
            if (running) button.visible = true;
            else if (hidden) button.visible = false;
            else button.visible = true;
        }
    }
    visible: app.mode === modes.explore || app.mode === modes.exploreRoute
    y: meters.height + styler.themePaddingLarge
    z: 500

    property bool hidden: app.infoPanelOpen || (map.cleanMode && !app.conf.mapModeCleanShowBasemap)

    onClicked: console.log("Basemap button pressed")
}
