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

Dialog {
    id: dialog
    allowedOrientations: app.defaultAllowedOrientations

    property string pid: py.evaluate("poor.app.router.id")

    SilicaListView {
        id: listView
        anchors.fill: parent

        delegate: ListItem {
            id: listItem
            contentHeight: defaultHeader.height + nameLabel.height +
                descriptionLabel.anchors.topMargin + descriptionLabel.height +
                alternativesHeader.height

            SectionHeader {
                id: defaultHeader
                height: model.default ? implicitHeight : 0
                text: app.tr("Default")
                visible: model.default && !listItem.highlighted
            }

            ListItemLabel {
                id: nameLabel
                anchors.top: defaultHeader.bottom
                color: (model.active || listItem.highlighted) ?
                    Theme.highlightColor : Theme.primaryColor;
                height: implicitHeight + app.listItemVerticalMargin
                text: model.name
                verticalAlignment: Text.AlignBottom
            }

            ListItemLabel {
                id: descriptionLabel
                anchors.top: nameLabel.bottom
                anchors.topMargin: Theme.paddingSmall
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                height: implicitHeight + app.listItemVerticalMargin
                lineHeight: 1.15
                text: model.description + "\n" + app.tr("Modes: %1", model.modes)
                verticalAlignment: Text.AlignTop
                wrapMode: Text.WordWrap
            }

            SectionHeader {
                id: alternativesHeader
                anchors.top: descriptionLabel.bottom
                height: model.default ? implicitHeight : 0
                text: app.tr("Alternatives")
                visible: model.default && !listItem.highlighted
            }

            onClicked: {
                dialog.pid = model.pid;
                dialog.accept();
            }

        }

        header: DialogHeader {}
        model: ListModel {}

        VerticalScrollDecorator {}

        Component.onCompleted: {
            // Load router model items from the Python backend.
            py.call("poor.util.get_routers", [], function(routers) {
                Util.sortDefaultFirst(routers);
                for (var i = 0; i < routers.length; i++)
                    routers[i].modes = routers[i].modes.join(", ");
                Util.appendAll(listView.model, routers);
            });
        }

    }

    onAccepted: {
        py.call_sync("poor.app.set_router", [dialog.pid]);
    }

}
