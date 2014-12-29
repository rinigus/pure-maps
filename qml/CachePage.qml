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
    allowedOrientations: Orientation.Portrait
    property bool loading: true
    property string title: ""
    SilicaListView {
        id: listView
        anchors.fill: parent
        delegate: ListItem {
            id: listItem
            contentHeight: Theme.itemSizeSmall
            menu: contextMenu
            ListItemLabel {
                id: nameLabel
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingLarge
                anchors.right: statLabel.left
                anchors.rightMargin: 0
                height: Theme.itemSizeSmall
                text: model.name
            }
            ListItemLabel {
                id: statLabel
                anchors.left: undefined
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingLarge
                color: Theme.secondaryColor
                height: Theme.itemSizeSmall
                text: model.size
            }
            RemorseItem { id: remorse }
            ContextMenu {
                id: contextMenu
                MenuItem {
                    text: "Remove all"
                    onClicked: remorse.execute(listItem, "Removing", function() {
                        page.purge(model.directory, 0);
                    });
                }
            }
        }
        header: PageHeader { title: page.title }
        model: ListModel {}
        VerticalScrollDecorator {}
    }
    Label {
        id: busyLabel
        anchors.bottom: busyIndicator.top
        color: Theme.highlightColor
        font.pixelSize: Theme.fontSizeLarge
        height: Theme.itemSizeLarge
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        visible: page.loading || (text != "Calculating" && text != "Removing")
        width: parent.width
    }
    BusyIndicator {
        id: busyIndicator
        anchors.centerIn: parent
        running: page.loading
        size: BusyIndicatorSize.Large
        visible: page.loading
    }
    Component.onCompleted: {
        page.loading = true;
        page.title = "";
        busyLabel.text = "Calculating";
        page.populate();
    }
    function populate(query) {
        // Load cache use statistics from the Python backend.
        listView.model.clear();
        py.call("poor.cache.stat", [], function(results) {
            if (results && results.length > 0) {
                page.title = "Map Tile Cache"
                for (var i = 0; i < results.length; i++)
                    listView.model.append(results[i]);
            } else {
                page.title = "";
                busyLabel.text = "Error";
            }
            page.loading = false;
        });
    }
    function purge(directory, maxAge) {
        // Remove tiles in directory older than maxAge.
        listView.model.clear();
        page.loading = true;
        page.title = "";
        busyLabel.text = "Removing";
        var fun = "poor.cache.purge_directory";
        py.call(fun, [directory, maxAge], function() {
            busyLabel.text = "Calculating";
            page.populate();
        });
    }
}
