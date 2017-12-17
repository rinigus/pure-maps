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

MapQuickItem {
    id: marker
    anchorPoint.x: sourceItem.width/2
    anchorPoint.y: sourceItem.height/2
    sourceItem: Image {
        smooth: true
        source: marker.passive ?
            app.getIcon("icons/node") :
            app.getIcon("icons/maneuver")
    }
    z: 201

    property real   duration: 0
    property string icon: "flag"
    property string narrative: ""
    property bool   passive: false
    property string verbalAlert: ""
    property string verbalPost: ""
    property string verbalPre: ""

}
