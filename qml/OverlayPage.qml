/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2015 Osmo Salomaa
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

import "js/util.js" as Util

Page {
    id: page
    allowedOrientations: app.defaultAllowedOrientations

    SilicaListView {
        id: listView
        anchors.fill: parent

        delegate: ListItem {
            id: listItem
            contentHeight: overlaySwitch.height

            TextSwitch {
                id: overlaySwitch
                checked: model.active
                description: model.show_attribution ?
                    app.tr("Source: %1", model.source) + "\n" + model.attribution : ""
                text: model.name
                // Avoid implicit line breaks.
                width: 3 * parent.width
                onCheckedChanged: {
                    app.hideMenu();
                    map.clearTiles();
                    overlaySwitch.checked ?
                        py.call_sync("poor.app.add_overlays", [model.pid]) :
                        py.call_sync("poor.app.remove_overlays", [model.pid]);
                }
                onPressAndHold: {
                    model.show_attribution = !model.show_attribution;
                }
            }

        }

        header: PageHeader {
            title: app.tr("Overlays")
        }

        model: ListModel {}

        VerticalScrollDecorator {}

        Component.onCompleted: {
            // Load overlay model items from the Python backend.
            py.call("poor.util.get_overlays", [], function(overlays) {
                Util.addProperties(overlays, "show_attribution", false);
                Util.appendAll(listView.model, overlays);
            });
        }

    }

}
