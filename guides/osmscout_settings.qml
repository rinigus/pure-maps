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
    ValueButton {
        id: nameButton
        label: app.tr("Name")
        height: Theme.itemSizeSmall
        value: ""
        onClicked: {
            var dialog = app.pageStack.push("osmscout_name.qml");
            dialog.accepted.connect(function() {
                nameButton.value = dialog.query;
                page.params.name = dialog.query;
                py.call_sync("poor.app.history.add_place_name", [dialog.query]);
            });
        }

        Component.onCompleted: {
            page.params.name = ""
        }
    }
}
