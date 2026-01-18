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

import QtQuick 2.9
import QtQuick.Controls 2.2

// required properties:
//    contentHeight
//    menu
//
// highlighted can be used, if available, to give a feedback that an item is pressed
//
// signals: clicked
//
Item {
    id: main

    height: item.height
    width: parent.width

    property real contentHeight
    property bool highlighted: false
    property var  menu

    signal clicked

    ItemDelegate {
        id: item

        height: contentHeight
        width: parent.width

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.RightButton
            propagateComposedEvents: true
            onClicked: {
                if (!menu || !menu.enabled) return
                menu.x = mouse.x
                menu.y = mouse.y
                menu.visibleChanged.connect(function (){
                    main.highlighted = menu.visible;
                })
                menu.open();
            }
            onPressed: main.highlighted = pressed
            onReleased: main.highlighted = pressed || (!!menu && menu.visible)
        }

        onClicked: parent.clicked()
    }
}
