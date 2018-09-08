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

Item {
    id: conf

    // cache certain frequently used properties locally
    property string units

    Component.onCompleted: _update()

    Connections {
        target: py
        onConfigurationChanged: conf._update()
        onReadyChanged: conf._update()
    }

    function add(option, item) {
        // Add item to the value of option.
        return py.call_sync("poor.conf.add", [option, item]);
    }

    function contains(option, item) {
        // Return true if the value of option contains item.
        return py.call_sync("poor.conf.contains", [option, item]);
    }

    function get(option) {
        // Return the value of option.
        return py.call_sync("poor.conf.get", [option]);
    }

    function getDefault(option) {
        // Return default value of configuration option.
        return py.call_sync("poor.conf.get_default", [option]);
    }

    function remove(option, item) {
        // Remove item from the value of option.
        return py.call_sync("poor.conf.remove", [option, item]);
    }

    function set(option, value) {
        // Set the value of option.
        return py.call_sync("poor.conf.set", [option, value]);
    }

    function _update() {
        if (!py.ready) return;
        conf.units = get("units");
        console.log("Config updated");
    }

}
