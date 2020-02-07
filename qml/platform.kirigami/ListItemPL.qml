/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2018-2019 Rinigus, 2019 Purism SPC
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
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.4 as Kirigami
import "."

// required properties:
//    contentHeight
//    menu
//
// highlighted can be used, if available, to give a feedback that an item is pressed
//
// signals: clicked
//
Item {
    id: root
    height: item.height
    width: parent.width

    default property alias content: itemData.data
    property real  contentHeight
    property alias highlighted: item.highlighted
    property var   menu

    signal clicked

    Kirigami.SwipeListItem {
        id: item
        actions: menu && menu.enabled ? menu.items : []
        bottomPadding: 0
        contentItem: RowLayout {
            Item {
                id: itemData
                implicitHeight: contentHeight
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                Layout.fillWidth: true
            }
        }
        implicitHeight: contentHeight
        topPadding: 0
        separatorVisible: false
        width: root.width
        onClicked: root.clicked()
    }
}
