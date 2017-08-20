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

    property bool   loading: true
    property string title: ""

    SilicaListView {
        id: listView
        anchors.fill: parent

        delegate: ListItem {
            id: listItem
            contentHeight: visible ? nameLabel.height + statLabel.height : 0
            menu: contextMenu

            ListItemLabel {
                id: nameLabel
                color: listItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                height: implicitHeight + app.listItemVerticalMargin
                text: model.name
                verticalAlignment: Text.AlignBottom
            }

            ListItemLabel {
                id: statLabel
                anchors.top: nameLabel.bottom
                anchors.topMargin: Theme.paddingSmall
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                height: implicitHeight + app.listItemVerticalMargin
                lineHeight: 1.15
                // model.count is negative during operations, see page.purge.
                text: model.count < 0 ? "· · ·" : app.tr("%1 tiles · %2", model.count, model.size)
                verticalAlignment: Text.AlignTop
            }

            RemorseItem {
                id: remorse
            }

            ContextMenu {
                id: contextMenu

                MenuItem {
                    text: app.tr("Remove older than one year")
                    onClicked: contextMenu.remove(365);
                }

                MenuItem {
                    text: app.tr("Remove older than one month")
                    onClicked: contextMenu.remove(30);
                }

                MenuItem {
                    text: app.tr("Remove older than one week")
                    onClicked: contextMenu.remove(7);
                }

                MenuItem {
                    text: app.tr("Remove all")
                    onClicked: contextMenu.remove(0);
                }

                function remove(age) {
                    remorse.execute(listItem, app.tr("Removing"), function() {
                        page.purge(model.index, model.directory, age);
                        if (age === 0) listItem.visible = false;
                    });
                }

            }

            ListView.onRemove: animateRemoval(listItem);
            onClicked: listItem.showMenu();

        }

        header: PageHeader {
            title: page.title
        }

        model: ListModel {}

        VerticalScrollDecorator {}

    }

    BusyModal {
        id: busy
        running: page.loading
    }

    Component.onCompleted: {
        page.loading = true;
        page.title = "";
        busy.text = app.tr("Calculating");
        page.populate();
    }

    function populate(query) {
        // Load cache statistics from the Python backend.
        listView.model.clear();
        py.call("poor.cache.stat", [], function(results) {
            if (results && results.length > 0) {
                page.title = app.tr("Map Tile Cache")
                Util.appendAll(listView.model, results);
                page.loading = false;
            } else {
                page.title = "";
                busy.error = app.tr("Empty cache, or error");
                page.loading = false;
            }
        });
    }

    function purge(index, directory, age) {
        // Remove tiles in cache and recalculate statistics.
        listView.model.setProperty(index, "count", -1);
        py.call("poor.cache.purge_directory", [directory, age], function(result) {
            py.call("poor.cache.stat_directory", [directory], function(result) {
                listView.model.setProperty(index, "count", result.count);
                listView.model.setProperty(index, "size", result.size);
            });
        });
    }

}
