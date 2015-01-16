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
import QtPositioning 5.3

MouseArea {
    id: mouseArea
    anchors.fill: parent
    onClicked: {
        mouseArea.coord = map.toCoordinate(Qt.point(mouse.x, mouse.y));
        clickTimer.start();
    }
    onDoubleClicked: {
        clickTimer.stop();
        map.centerOnPosition();
    }
    property var coord
    Timer {
        id: clickTimer
        interval: 300
        onTriggered: {
            map.addPois([{"x": mouseArea.coord.longitude,
                          "y": mouseArea.coord.latitude,
                          "title": "Unnamed point",
                          "text": "Unnamed point"}]);

        }
    }
}
