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
    allowedOrientations: Orientation.All
    SilicaListView {
        anchors.fill: parent
        delegate: ListItem {
            id: listItem
            contentHeight: nameLabel.height + sourceLabel.height
            ListItemLabel {
                id: nameLabel
                color: (active || listItem.highlighted) ?
                    Theme.highlightColor : Theme.primaryColor;
                height: implicitHeight + Theme.paddingMedium
                text: model.name
                verticalAlignment: Text.AlignBottom
            }
            ListItemLabel {
                id: sourceLabel
                anchors.top: nameLabel.bottom
                color: Theme.secondaryColor
                height: implicitHeight + Theme.paddingMedium
                font.pixelSize: Theme.fontSizeExtraSmall
                text: "Source: " + model.source
                verticalAlignment: Text.AlignTop
            }
            onClicked: {
                map.resetTiles();
                py.call_sync("poor.app.set_tilesource", [model.pid]);
                map.setAttribution(attribution);
                map.changed = true;
                app.pageStack.pop(mapPage, PageStackAction.Immediate);
            }
        }
        header: PageHeader { title: "Map Tiles" }
        model: ListModel { id: listModel }
        VerticalScrollDecorator {}
        Component.onCompleted: {
            // Load tilesource model entries from the Python backend.
            py.call("poor.util.get_tilesources", [], function(tilesources) {
                for (var i = 0; i < tilesources.length; i++)
                    listModel.append(tilesources[i]);
            });
        }
    }
}
