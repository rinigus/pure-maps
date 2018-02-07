/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2017 Osmo Salomaa
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

QtObject {
    id: route

    property string attribution: ""
    property string language: "en"
    property string mode: "car"
    property var    x: []
    property var    y: []

    function clear() {
        route.attribution = "";
        route.language = "en";
        route.mode = "car";
        route.x = [];
        route.y = [];
    }

    function getDestination() {
        // Return coordinates [x, y] of the route destination.
        return [route.x[route.x.length - 1],
                route.y[route.y.length - 1]];

    }

}
