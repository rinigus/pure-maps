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
import Sailfish.Silica 1.0

QtObject {
    id: styler

    property string bg            // main foreground color (scale bar, metrics)
    property string fg            // main foreground color (scale bar, metrics)
    property string iconVariant   // type of icons, let empty for default version, "white" for white icons
    property string maneuver      // maneuver circle inner color
    property string position      // variant of position marker, set to "" for default
    property string route         // route color on the map. also used for maneuver markers
    property real   routeOpacity  // opacity of route
    property string streetFg      // street name foreground
    property string streetBg      // street name outline

    function apply(guistyle) {
        defaults();
        if (guistyle == null) return;
        for (var i in guistyle) {
            if (guistyle.hasOwnProperty(i) && styler.hasOwnProperty(i)) {
                styler[i] = guistyle[i];
            }
        }
    }

    function defaults() {
        bg = "#e6e6e6";
        fg = "black";
        iconVariant = "";
        maneuver = "white";
        position = "";
        route = "#0540ff";
        routeOpacity = 0.5;
        streetFg = "black";
        streetBg = "white";
    }
}
