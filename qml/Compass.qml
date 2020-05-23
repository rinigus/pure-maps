/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2020 Rinigus
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
import QtSensors 5.2

Item {
    property alias active:  compass.active
    property real  azimuth: active && compass.reading !== undefined &&
                            compass.reading.azimuth !== undefined ?
                                compass.reading.azimuth + app.compassOrientationOffset : 0

    Compass {
        id: compass
        // It makes sense to use compass on low speeds, with valid position and speed
        active: app.conf.compassUse && app.running && gps.ready &&
                gps.position.speedValid && gps.position.speed < 2.78 // limiting to 10 km/h
        alwaysOn: false
        skipDuplicates: true
    }
}
