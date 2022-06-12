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
    title: app.tr("Search engine")

    property string pid: py.evaluate("poor.app.guide.id")

    delegate: ListItemPL {
        id: listItem
        contentHeight: defaultHeader.height + nameLabel.height +
                       descriptionLabel.anchors.topMargin + descriptionLabel.height

        SectionHeaderPL {
            id: defaultHeader
            height: model.header ? implicitHeight : 0
            text: model.name
            visible: !!model.header
        }

        ListItemLabel {
            id: nameLabel
            anchors.top: defaultHeader.bottom
            color: {
                if (!model.available)
                    return styler.themeSecondaryHighlightColor;
                if (model.active || listItem.highlighted)
                    return styler.themeHighlightColor;
                return styler.themePrimaryColor;
            }
            height: text && visible ? implicitHeight + app.listItemVerticalMargin : 0
            text: model.available ? model.name :
                                    app.tr("%1 (disabled, %2)", model.name, model.available_message)
            verticalAlignment: Text.AlignBottom
            visible: !model.header
        }

        ListItemLabel {
            id: descriptionLabel
            anchors.top: nameLabel.bottom
            anchors.topMargin: height > 0 ? styler.themePaddingSmall : 0
            color: listItem.highlighted || !model.available? styler.themeSecondaryHighlightColor : styler.themeSecondaryColor
            font.pixelSize: styler.themeFontSizeExtraSmall
            height: text && visible ? implicitHeight + app.listItemVerticalMargin : 0
            lineHeight: 1.15
            text: model.description
            verticalAlignment: Text.AlignTop
            wrapMode: Text.WordWrap
            visible: !model.header
        }

        Component.onCompleted: {
            if (model.active) {
                dialog.currentIndex = model.index;
            }
        }
        onClicked: {
            if (model.header || !model.available) return;
            dialog.pid = model.pid;
            dialog.accept();
        }
    }

    model: ListModel {}

    Component.onCompleted: {
        // Load guide model items from the Python backend.
        py.call("poor.util.get_guides", [], function(guides) {
            Util.sortDefaultFirst(guides);
            Util.appendAll(dialog.model, guides);
        });
    }

    onAccepted: {
        py.call_sync("poor.app.set_guide", [dialog.pid]);
    }

}
