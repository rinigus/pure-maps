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
import org.kde.kirigami 2.7 as Kirigami

Kirigami.Page {
    id: page
    bottomPadding: 0
    globalToolBarStyle: Kirigami.ApplicationHeaderStyle.None
    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    Kirigami.ColumnView.fillWidth: true
    Kirigami.ColumnView.pinned: true
    Kirigami.ColumnView.preventStealing: true

    default property alias content: itemCont.data
    readonly property bool empty: true
    property bool          currentPage: app.pages.currentItem === page

    signal pageStatusActivating
    signal pageStatusActive
    signal pageStatusInactive

    Item {
        id: itemCont
        anchors.fill: parent
    }

    MouseArea {
        // protect from interaction while not current. without
        // this protection we will get in the wide mode:
        // - when clicking navigation bar while in navigation or maneuver pages,
        //   removal of pages associated with currentIndex==0 of stack can be
        //   done after new pages are inserted. protection protects against the
        //   race condition.
        //
        // - when clicking and making map active, map view will swap between minimal
        //   and full view with corresponding changes in visibility of controls
        id: protect
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        states: [
            State {
                when: page.currentPage
                AnchorChanges {
                    target: protect
                    anchors.right: parent.left
                    anchors.bottom: parent.top
                }
            }
        ]
    }

    onCurrentPageChanged: {
        if (page.currentPage) {
            pageStatusActivating();
            pageStatusActive();
        } else pageStatusInactive();
    }
}
