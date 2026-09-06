/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2026 Rinigus
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

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Item {
    id: root

    height: item.height
    width: parent ? parent.width : 1

    default property alias content: itemData.data
    property real  contentHeight
    property alias highlighted: item.pressed
    property var   menu

    signal clicked

    Kirigami.SwipeListItem {
        id: item

        actions: menu && menu.enabled ? menu.items : []
        bottomPadding: 0
        contentItem: RowLayout {
            Item {
                id: itemData

                implicitHeight: root.contentHeight
                Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                Layout.fillWidth: true
            }
        }
        implicitHeight: root.contentHeight
        separatorVisible: false
        topPadding: 0
        width: root.width

        onClicked: root.clicked()
    }
}
