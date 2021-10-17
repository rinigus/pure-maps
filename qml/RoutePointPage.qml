/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2014 Osmo Salomaa, 2019 Rinigus
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

DialogAutoPL {
    id: dialog

    pageMenu: PageMenuPL {
        PageMenuItemPL {
            iconName: styler.iconPreferences
            text: app.tr("Change provider (%1)").arg(name)
            property string name: py.evaluate("poor.app.geocoder.name")
            onClicked: {
                var dialog = app.push(Qt.resolvedUrl("GeocoderPage.qml"));
                dialog.accepted.connect(function() {
                    name = py.evaluate("poor.app.geocoder.name");
                });
            }
        }
    }

    property alias  comment: commentLabel.text
    property string currentSelection
    property alias  searchPlaceholderText: geo.searchPlaceholderText
    property alias  selection: geo.selection
    property alias  selectionTypes: geo.selectionTypes
    property alias  query: geo.query

    Column {
        spacing: styler.themePaddingMedium
        width: dialog.width

        ListItemLabel {
            id: commentLabel
            color: styler.themeHighlightColor
            font.pixelSize: styler.themeFontSizeSmall
            visible: text
            wrapMode: Text.WordWrap
        }

        ListItemLabel {
            font.pixelSize: styler.themeFontSizeSmall
            color: styler.themeHighlightColor
            horizontalAlignment: Text.AlignRight
            text: app.tr("Current selection: %1").arg(currentSelection)
            visible: currentSelection
            wrapMode: Text.WordWrap
        }

        Spacer {
            height: 0
        }

        GeocodeItem {
            id: geo
            active: true
            fillModel: false
            showCurrentPosition: true

            onSelectionChanged: {
                if (selection) {
                    accept();
                }
            }
        }
    }

    onPageStatusActive: {
        geo.fillModel = true;
        if (!query) geo.activate();
    }
}
