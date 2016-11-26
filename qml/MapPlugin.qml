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

/*
 * XXX: While waiting for QtLocation's Map component to support dynamic
 * custom tile sources, we need to use an existing map plugin to be able
 * to use the map canvas, pan, pinch-zoom, overlaid objects etc.
 * Luckily, we can use the Nokia plugin, but not load any Nokia tiles,
 * and overlay our own tiles as MapQuickItems.
 *
 * http://bugreports.qt.io/browse/QTBUG-32937
 * http://bugreports.qt.io/browse/QTBUG-36581
 * http://bugreports.qt.io/browse/QTBUG-40994
 * http://bugreports.qt.io/browse/QTBUG-43762
 */

Plugin {
    name: "here"
    parameters: [
        PluginParameter { name: "app_id"; value: "N7qPce6rxX5gKujr6ia3"; },
        PluginParameter { name: "app_code"; value: "4kEWsRWtJQpNFfQmpnknfA"; },
        PluginParameter { name: "mapping.cache.directory"; value: "/dev/null"; },
        PluginParameter { name: "mapping.host"; value: "127.0.0.1:65536"; }
    ]
}
