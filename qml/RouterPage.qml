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
            contentHeight: nameLabel.height + descriptionLabel.height + attributionLabel.height

            ListItemLabel {
                id: nameLabel
                color: (model.active || listItem.highlighted) ?
                    Theme.highlightColor : Theme.primaryColor;
                height: implicitHeight + topMargin
                text: model.name
                verticalAlignment: Text.AlignBottom
                property real topMargin: (Theme.itemSizeSmall - implicitHeight) / 2
            }

            ListItemLabel {
                id: descriptionLabel
                anchors.top: nameLabel.bottom
                anchors.topMargin: Theme.paddingSmall
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                text: model.description + "\n" + qsTranslate("", "Modes: %1").arg(model.modes)
                verticalAlignment: Text.AlignTop
                wrapMode: Text.WordWrap
            }

            ListItemLabel {
                id: attributionLabel
                anchors.top: descriptionLabel.bottom
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                height: (visible ? implicitHeight : 0) + nameLabel.topMargin
                text: visible ? qsTranslate("", "Source: %1").arg(model.source) +
                    "\n" + model.attribution : ""
                // Avoid a seemigly irrelevant warning about a binding loop.
                // QML Label: Binding loop detected for property "_elideText"
                truncationMode: TruncationMode.None
                verticalAlignment: Text.AlignTop
                visible: model.show_attribution
                wrapMode: Text.WordWrap
            }

            onClicked: {
                dialog.pid = model.pid;
                dialog.accept();
            }

            onPressAndHold: {
                model.show_attribution = !model.show_attribution;
            }

        }

        header: DialogHeader {}
        model: ListModel {}

        VerticalScrollDecorator {}

        Component.onCompleted: {
            // Load router model items from the Python backend.
            py.call("poor.util.get_routers", [], function(routers) {
                Util.markDefault(routers, app.conf.getDefault("router"));
                Util.addProperties(routers, "show_attribution", false);
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
