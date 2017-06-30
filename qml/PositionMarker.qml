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
import QtLocation 5.0
import QtPositioning 5.3
import Sailfish.Silica 1.0
import "."

MapQuickItem {
    id: marker
    anchorPoint.x: sourceItem.width/2
    anchorPoint.y: sourceItem.height/2
    coordinate: map.position.coordinate
    height: sourceItem.height
    visible: map.ready
    width: sourceItem.width

    sourceItem: Item {
        height: movingImage.height
        width: movingImage.width

        Image {
            id: movingImage
            rotation: map.rotation + (map.direction || 0)
            smooth: true
            source: app.getIcon("icons/position-direction")
            visible: map.direction || false
            Behavior on rotation {
                RotationAnimation {
                    direction: RotationAnimation.Shortest
                    duration: 500
                    easing.type: Easing.Linear
                }
            }
        }

        Image {
            id: stillImage
            anchors.centerIn: movingImage
            smooth: false
            source: app.getIcon("icons/position")
            visible: !movingImage.visible
        }

        MouseArea {
            anchors.fill: movingImage
            onClicked: {
                if (map.autoCenter) {
                    map.autoCenter = false;
                    bubble.text = qsTranslate("", "Auto-center off");
                } else {
                    map.autoCenter = true;
                    bubble.text = qsTranslate("", "Auto-center on");
                    map.centerOnPosition();
                }
                bubble.visible = true;
                timer.restart();
            }
        }

        Bubble {
            id: bubble
            anchorItem: movingImage
            visible: false
        }

        Timer {
            id: timer
            interval: 2000
            repeat: false
            onTriggered: bubble.visible = false;
        }

    }

    transform: Rotation {
        angle: -map.rotation
        origin.x: sourceItem.width/2
        origin.y: sourceItem.height/2
    }

    z: 300

    Behavior on coordinate {
        CoordinateAnimation {
            duration: 500
            easing.type: Easing.Linear
        }
    }

}
