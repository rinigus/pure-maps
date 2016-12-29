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

Dialog {
    id: dialog
    allowedOrientations: app.defaultAllowedOrientations
    property string pid: py.evaluate("poor.app.guide.id")
    SilicaListView {
        id: listView
        anchors.fill: parent
        delegate: ListItem {
            id: listItem
            contentHeight: nameLabel.height + descriptionLabel.height
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
                text: [
                    model.description,
                    qsTranslate("", "Source: %1").arg(model.source),
                    model.attribution
                ].join("\n")
                verticalAlignment: Text.AlignTop
                wrapMode: Text.WordWrap
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
            // Load guide model entries from the Python backend.
            var defpid = app.conf.getDefault("guide");
            py.call("poor.util.get_guides", [], function(guides) {
                for (var i = 0; i < guides.length; i++) {
                    if (guides[i].pid === defpid)
                        guides[i].name = qsTranslate("", "%1 (default)").arg(guides[i].name);
                    listView.model.append(guides[i]);
                }
            });
        }
    }
    onAccepted: {
        py.call_sync("poor.app.set_guide", [dialog.pid]);
    }
}
