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

ValueButtonPL {
    height: Math.max(styler.themeItemSizeSmall, implicitHeight)
    value: text
    // Avoid putting label and value on different lines.
    width: 3 * parent.width

    property string comment
    property var    coordinates: null

    property string query
    property string text
    property string title

    signal updated;

    BusyIndicatorSmallPL {
        anchors.right: parent.right
        anchors.rightMargin: styler.themeHorizontalPageMargin + (parent.width - page.width)
        anchors.verticalCenter: parent.verticalCenter
        running: text === app.tr("Current position") && !gps.ready
        z: parent.z + 1
    }

    onClicked: {
        var dialog = app.push(Qt.resolvedUrl("RoutePointPage.qml"), {
                                  "comment": comment,
                                  "currentSelection": text,
                                  "query": query,
                                  "title": title,
                                  "searchPlaceholderText": label
                              });
        dialog.accepted.connect(function() {
            query = dialog.query;
            if (dialog.selection.selectionType === dialog.selectionTypes.currentPosition) {
                coordinates = app.getPosition();
                text = app.tr("Current position");
            }
            else if (dialog.selection.coordinate) {
                coordinates = [dialog.selection.coordinate.longitude, dialog.selection.coordinate.latitude];
                text = dialog.selection.title || app.tr("Unnamed point");
            } else {
                console.log("RoutePoint: " + label + " selection error: " + JSON.stringify(dialog.selection))
            }
            updated();
        });
    }
}
