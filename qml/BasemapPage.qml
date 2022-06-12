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

PageListPL {
    id: page
    title: app.tr("Maps")

    delegate: ListItemPL {
        id: listItem
        contentHeight: styler.themeItemSizeSmall

        ListItemLabel {
            id: nameLabel
            color: {
                if (!model.available)
                    return styler.themeSecondaryHighlightColor;
                if (model.active || listItem.highlighted)
                    return styler.themeHighlightColor;
                return styler.themePrimaryColor;
            }
            height: styler.themeItemSizeSmall
            text: {
                var isDefault = (model.pid === defaultId);
                if (model.available)
                    return isDefault ? app.tr("%1 (default)", model.name) :
                                       model.name;
                // Assume that basemap was disabled due to missing API key
                return isDefault ? app.tr("%1 (default, disabled, API key missing)", model.name) :
                                   app.tr("%1 (disabled, API key missing)", model.name)
            }
        }

        onClicked: {
            if (!model.available) return;
            app.hideMenu(app.tr("Map: %1").arg(model.name));
            py.call_sync("poor.app.set_basemap", [model.pid]);
            update();
        }
    }

    model: ListModel {}

    property string defaultId: ""

    Component.onCompleted: update()

    function update() {
        // Load basemap model items from the Python backend.
        py.call("poor.app.basemap.list", [], function(basemaps) {
            page.model.clear();
            defaultId = app.conf.getDefault("basemap");
            Util.appendAll(page.model, basemaps);
        });
    }
}
