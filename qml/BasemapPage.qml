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

import "js/util.js" as Util

Page {
    id: page
    allowedOrientations: app.defaultAllowedOrientations

    property string title: app.tr("Maps")

    SilicaListView {
        id: listView
        anchors.fill: parent

        delegate: ListItem {
            id: listItem
            contentHeight: Theme.itemSizeSmall

            ListItemLabel {
                id: nameLabel
                color: (model.active || listItem.highlighted) ?
                    Theme.highlightColor : Theme.primaryColor;
                height: Theme.itemSizeSmall
                text: model.name
            }

            onClicked: {
                app.hideMenu();
                py.call_sync("poor.app.set_basemap", [model.pid]);
                map.setBasemap();
                for (var i = 0; i < listView.model.count; i++)
                    listView.model.setProperty(i, "active", false);
                model.active = true;
            }

        }

        header: PageHeader {
            title: page.title
        }

        model: ListModel {}

        VerticalScrollDecorator {}

        Component.onCompleted: {
            // Load basemap model items from the Python backend.
            py.call("poor.util.get_basemaps", [], function(basemaps) {
                Util.markDefault(basemaps, app.conf.getDefault("basemap"));
                Util.appendAll(listView.model, basemaps);
            });
        }

    }

}
