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

    property string pid: py.evaluate("poor.app.guide.id")

    SilicaListView {
        id: listView
        anchors.fill: parent

        delegate: ListItem {
            id: listItem
            contentHeight: nameLabel.height + descriptionLabel.anchors.topMargin +
                descriptionLabel.height + attributionLabel.height

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
                text: model.description
                verticalAlignment: Text.AlignTop
                wrapMode: Text.WordWrap
            }

            ListItemLabel {
                id: attributionLabel
                anchors.top: descriptionLabel.bottom
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                height: (visible ? implicitHeight : 0) + nameLabel.topMargin
                text: visible ? app.tr("Source: %1", model.source) + "\n" + model.attribution : ""
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
            // Load guide model items from the Python backend.
            py.call("poor.util.get_guides", [], function(guides) {
                Util.markDefault(guides, app.conf.getDefault("guide"));
                Util.addProperties(guides, "show_attribution", false);
                Util.appendAll(listView.model, guides);
            });
        }

    }

    onAccepted: {
        py.call_sync("poor.app.set_guide", [dialog.pid]);
    }

}
