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

QtObject {
    function get(option) {
        // Return value of configuration option.
        return py.call_sync("poor.conf.get", [option]);
    }
    function set(option, value) {
        // Set the value of configuration option.
        return py.call_sync("poor.conf.set", [option, value]);
    }
    function set_add(option, item) {
        // Add item to option of type set.
        return py.call_sync("poor.conf.set_add", [option, item]);
    }
    function set_contains(option, item) {
        // Return true if configuration option of type set contains item.
        return py.call_sync("poor.conf.set_contains", [option, item]);
    }
    function set_remove(option, item) {
        // Remove item from option of type set.
        return py.call_sync("poor.conf.set_remove", [option, item]);
    }
}
