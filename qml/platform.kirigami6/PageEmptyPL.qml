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
import org.kde.kirigami as Kirigami

Kirigami.Page {
    id: page

    Kirigami.ColumnView.fillWidth: true
    Kirigami.ColumnView.pinned: true
    Kirigami.ColumnView.preventStealing: true
    bottomPadding: 0
    clip: true
    globalToolBarStyle: Kirigami.ApplicationHeaderStyle.None
    leftPadding: 0
    rightPadding: 0
    topPadding: 0

    default property alias content: itemCont.data
    readonly property bool empty: true
    property bool          currentPage: app.pages.currentItem === page || page.isCurrentPage
    property bool          isDialog: false

    signal pageStatusActivating
    signal pageStatusActive
    signal pageStatusInactive

    Item {
        id: itemCont
        anchors.fill: parent
    }

    MouseArea {
        id: protect

        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top

        states: State {
            when: page.currentPage

            AnchorChanges {
                target: protect
                anchors.bottom: parent.top
                anchors.right: parent.left
            }
        }
    }

    onCurrentPageChanged: {
        if (page.currentPage) {
            pageStatusActivating();
            pageStatusActive();
        } else {
            pageStatusInactive();
        }
    }
}
