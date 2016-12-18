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
    id: page
    allowedOrientations: app.defaultAllowedOrientations
    property string title: qsTranslate("", "Basemaps")
    SilicaListView {
        id: listView
        anchors.fill: parent
        delegate: ListItem {
            id: listItem
            contentHeight: visible ? nameLabel.height + descriptionLabel.height : 0
            visible: model.visible
            ListItemLabel {
                id: nameLabel
                color: (model.active || listItem.highlighted) ?
                    Theme.highlightColor : Theme.primaryColor;
                height: implicitHeight + Theme.paddingMedium
                text: model.name
                verticalAlignment: Text.AlignBottom
            }
            ListItemLabel {
                id: descriptionLabel
                anchors.top: nameLabel.bottom
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                height: implicitHeight + 1.5*Theme.paddingMedium
                text: qsTranslate("", "Source: %1\n%2").arg(model.source).arg(model.attribution)
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
        header: PageHeader { title: page.title }
        model: ListModel {}
        PullDownMenu {
            MenuItem {
                text: qsTranslate("", "All")
                onClicked: page.setFilter("");
            }
            MenuItem {
                text: "@1x"
                onClicked: page.setFilter("@1x");
            }
            MenuItem {
                text: "@2x"
                onClicked: page.setFilter("@2x");
            }
        }
        VerticalScrollDecorator {}
        Component.onCompleted: {
            // Load basemap model entries from the Python backend.
            var defpid = app.conf.getDefault("basemap");
            py.call("poor.util.get_basemaps", [], function(basemaps) {
                for (var i = 0; i < basemaps.length; i++) {
                    if (basemaps[i].pid === defpid)
                        basemaps[i].name = qsTranslate("", "%1 (default)").arg(basemaps[i].name);
                    basemaps[i].visible = true;
                    listView.model.append(basemaps[i]);
                }
                page.filterBasemaps();
            });
        }
    }
    onStatusChanged: {
        page.status === PageStatus.Active &&
            app.pageStack.pushAttached("OverlayPage.qml");
    }
    function filterBasemaps() {
        // Show only basemaps that match the scale filter.
        var filter = app.conf.get("basemap_filter");
        for (var i = 0; i < listView.count; i++) {
            var visible = listView.model.get(i).name.indexOf(filter) > -1;
            listView.model.setProperty(i, "visible", visible);
        }
        page.title = filter.length > 0 ?
            qsTranslate("", "Basemaps %1").arg(filter) : qsTranslate("", "Basemaps");
    }
    function setFilter(value) {
        // Set value of the scale filter and update.
        app.conf.set("basemap_filter", value);
        page.filterBasemaps();
    }
}
