/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2014 Osmo Salomaa, 2018 Rinigus
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
import "."
import "platform"

MapButton {
    id: master
    anchors.bottom: centerButton.top
    anchors.right: parent.right
    enabled: !hidden
    iconColorize: false
    iconHeight: app.styler.themeIconSizeSmall
    iconRotation: -map.bearing
    iconSource: app.getIcon("icons/north")
    states: [
        State {
            when: (app.mode === modes.navigate || app.mode === modes.followMe) && !app.portrait
            AnchorChanges {
                target: master
                anchors.bottom: undefined
                anchors.top: navigationSign.bottom
            }
        },
        State {
            when: app.mode === modes.navigate || app.mode === modes.followMe
            AnchorChanges {
                target: master
                anchors.bottom: undefined
                anchors.top: centerButton.bottom
            }
        }
    ]
    opacity: hidden ? 0 : 1
    z: 500

    property bool hidden: app.infoPanelOpen || (Math.abs(master.iconRotation) < 0.01 && map.cleanMode && !app.conf.mapModeCleanShowCompass)

    Behavior on opacity { NumberAnimation { property: "opacity"; duration: app.conf.animationDuration; } }

    Bubble {
        id: bubble
        anchorItem: parent
        showArrow: false
        state: (app.mode === modes.navigate || app.mode === modes.followMe) ? "bottom-left" : "top-left"
        visible: false
    }

    Timer {
        id: timer
        interval: 2000
        repeat: false
        onTriggered: bubble.visible = false;
    }

    onClicked: {
        map.autoRotate = !map.autoRotate;
        bubble.text = map.autoRotate ?
                    app.tr("Auto-rotate on") :
                    app.tr("Auto-rotate off");
        bubble.visible = true;
        timer.restart();
    }

}
