/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2018 Rinigus
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

Page {
    id: page
    allowedOrientations: app.defaultAllowedOrientations

    property alias  content: loader.sourceComponent
    property bool   empty: false
    property string title

    SilicaFlickable {
        id: flickable
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: app.styler.themePaddingLarge
            width: parent.width

            PageHeader {
                title: page.title
                visible: !page.empty
            }

            Loader {
                id: loader
                active: !page.empty && sourceComponent
                width: parent.width
            }
        }

        VerticalScrollDecorator { flickable: flickable }
    }
}
