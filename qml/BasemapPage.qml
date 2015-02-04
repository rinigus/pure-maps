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

Page {
    allowedOrientations: Orientation.Portrait
    SilicaListView {
        id: listView
        anchors.fill: parent
        delegate: ListItem {
            id: listItem
            contentHeight: nameLabel.height + attributionLabel.height
            ListItemLabel {
                id: nameLabel
                color: (model.active || listItem.highlighted) ?
                    Theme.highlightColor : Theme.primaryColor;
                height: implicitHeight + Theme.paddingMedium
                text: model.name
                verticalAlignment: Text.AlignBottom
            }
            ListItemLabel {
                id: attributionLabel
                anchors.top: nameLabel.bottom
                color: Theme.secondaryColor
                height: implicitHeight + Theme.paddingMedium
                font.pixelSize: Theme.fontSizeExtraSmall
                text: "Source: " + model.source + "\n" + model.attribution
                verticalAlignment: Text.AlignTop
            }
            onClicked: {
                app.hideMenu();
                map.clearTiles();
                py.call_sync("poor.app.set_basemap", [model.pid]);
                map.changed = true;
                for (var i = 0; i < listView.model.count; i++)
                    listView.model.setProperty(i, "active", false);
                listView.model.setProperty(model.index, "active", true);
            }
        }
        header: PageHeader { title: "Basemaps" }
        model: ListModel {}
        VerticalScrollDecorator {}
        Component.onCompleted: {
            // Load basemap model entries from the Python backend.
            py.call("poor.util.get_basemaps", [], function(basemaps) {
                for (var i = 0; i < basemaps.length; i++)
                    listView.model.append(basemaps[i]);
            });
        }
    }
}
