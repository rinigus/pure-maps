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
import Sailfish.Silica 1.0

Column {
    ComboBox {
        id: comboBox
        label: "Type"
        menu: ContextMenu {
            MenuItem { text: "Car" }
            MenuItem { text: "Bicycle" }
            MenuItem { text: "Pedestrian" }
        }
        property var pids: ["fastest", "bicycle", "pedestrian"]
        Component.onCompleted: {
            var type = py.evaluate("poor.conf.routers.mapquest_open.type");
            comboBox.currentIndex = comboBox.pids.indexOf(type);
        }
        onCurrentIndexChanged: {
            py.call_sync("poor.conf.set",
                         ["routers.mapquest_open.type",
                          comboBox.pids[comboBox.currentIndex]]);

        }
    }
}
