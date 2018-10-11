/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2014 Osmo Salomaa, 2018 Rinigus
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
import "."
import "platform"

import "js/util.js" as Util

DialogListPL {
    id: dialog

    delegate: ListItemPL {
        id: listItem
        contentHeight: defaultHeader.height + nameLabel.height +
                       descriptionLabel.anchors.topMargin + descriptionLabel.height +
                       alternativesHeader.height

        SectionHeaderPL {
            id: defaultHeader
            height: model.default ? implicitHeight : 0
            text: app.tr("Default")
            visible: model.default && !listItem.highlighted
        }

        ListItemLabel {
            id: nameLabel
            anchors.top: defaultHeader.bottom
            color: (model.active || listItem.highlighted) ?
                       app.styler.themeHighlightColor : app.styler.themePrimaryColor;
            height: implicitHeight + app.listItemVerticalMargin
            text: model.name
            verticalAlignment: Text.AlignBottom
        }

        ListItemLabel {
            id: descriptionLabel
            anchors.top: nameLabel.bottom
            anchors.topMargin: app.styler.themePaddingSmall
            color: app.styler.themeSecondaryColor
            font.pixelSize: app.styler.themeFontSizeExtraSmall
            height: implicitHeight + app.listItemVerticalMargin
            lineHeight: 1.15
            text: model.description + "\n" + app.tr("Modes: %1", model.modes)
            verticalAlignment: Text.AlignTop
            wrapMode: Text.WordWrap
        }

        SectionHeaderPL {
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

    model: ListModel {}

    property string pid: py.evaluate("poor.app.router.id")

    Component.onCompleted: {
        // Load router model items from the Python backend.
        py.call("poor.util.get_routers", [], function(routers) {
            Util.sortDefaultFirst(routers);
            for (var i = 0; i < routers.length; i++)
                routers[i].modes = routers[i].modes.join(", ");
            Util.appendAll(dialog.model, routers);
        });
    }

    onAccepted: {
        py.call_sync("poor.app.set_router", [dialog.pid]);
    }

}
