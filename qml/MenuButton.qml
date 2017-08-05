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
import "."

IconButton {
    anchors.bottom: parent.bottom
    anchors.bottomMargin: Theme.paddingSmall
    anchors.horizontalCenter: parent.horizontalCenter
    height: icon.sourceSize.height
    icon.smooth: false
    icon.source: app.getIcon("icons/menu")
    visible: py.ready
    z: 600
    onClicked: app.showMenu();
}
