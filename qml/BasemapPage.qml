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

    property string title: app.tr("Basemaps")

    SilicaListView {
        id: listView
        anchors.fill: parent

        delegate: ListItem {
            id: listItem
            contentHeight: visible ? nameLabel.height + attributionLabel.anchors.topMargin +
                attributionLabel.height : 0
            visible: model.visible

            ListItemLabel {
                id: nameLabel
                color: (model.active || listItem.highlighted) ?
                    Theme.highlightColor : Theme.primaryColor;
                height: implicitHeight + app.listItemVerticalMargin
                text: model.name
                verticalAlignment: Text.AlignBottom
            }

            ListItemLabel {
                id: attributionLabel
                anchors.top: nameLabel.bottom
                anchors.topMargin: visible ? Theme.paddingSmall : 0
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                height: (visible ? implicitHeight : 0) + app.listItemVerticalMargin
                lineHeight: 1.15
                text: visible ? app.tr("Source: %1", model.source) + "\n" + model.attribution : ""
                truncationMode: TruncationMode.None
                verticalAlignment: Text.AlignTop
                visible: model.show_attribution
                wrapMode: Text.WordWrap
            }

            onClicked: {
                app.hideMenu();
                py.call_sync("poor.app.set_basemap", [model.pid]);
                map.setBasemap();
                for (var i = 0; i < listView.model.count; i++) {
                    listView.model.setProperty(i, "active", false);
                    listView.model.setProperty(i, "show_attribution", false);
                }
                model.active = true;
            }

            onPressAndHold: {
                model.show_attribution = !model.show_attribution;
            }

        }

        header: PageHeader {
            title: page.title
        }

        model: ListModel {}

        PullDownMenu {
            MenuItem {
                text: app.tr("All")
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
            MenuItem {
                text: "@3x"
                onClicked: page.setFilter("@3x");
            }
            MenuItem {
                text: "@4x"
                onClicked: page.setFilter("@4x");
            }
        }

        VerticalScrollDecorator {}

        Component.onCompleted: {
            // Load basemap model items from the Python backend.
            py.call("poor.util.get_basemaps", [], function(basemaps) {
                Util.markDefault(basemaps, app.conf.getDefault("basemap"));
                Util.addProperties(basemaps, "show_attribution", false);
                Util.addProperties(basemaps, "visible", false);
                Util.appendAll(listView.model, basemaps);
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
        var filter = app.conf.get("basemap_filter"), item;
        for (var i = 0; i < listView.count; i++) {
            item = listView.model.get(i);
            item.visible = item.name.indexOf(filter) > -1;
        }
        page.title = filter.length > 0 ?
            app.tr("Basemaps %1", filter) :
            app.tr("Basemaps");
    }

    function setFilter(value) {
        // Set value of the scale filter and update.
        app.conf.set("basemap_filter", value);
        page.filterBasemaps();
    }

}
