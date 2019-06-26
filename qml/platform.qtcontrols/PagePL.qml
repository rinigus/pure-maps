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
import "."

Page {
    id: page
    header: HeaderBarImpl {
        page: page
        onAccepted: app.pages.navigateForward();
    }
    width: parent ? parent.width : undefined

    property string        acceptIconName // for compatibility
    property string        acceptText // for compatibility
    property bool          canNavigateForward: true
    default property alias content: itemCont.data
    readonly property bool empty: false
    property alias         pageMenu: page.footer
    property int           status: StackView.status

    signal pageStatusActivating
    signal pageStatusActive
    signal pageStatusInactive

    ScrollView {
        id: flickable        
        anchors.bottomMargin: styler.themePaddingLarge
        anchors.fill: parent
        anchors.topMargin: styler.themePaddingLarge
        contentHeight: itemCont.height
        contentWidth: page.width
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AsNeeded

        Item {
            id: itemCont
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: title.bottom
            anchors.topMargin: styler.themePaddingLarge
            height: childrenRect.height
            width: parent.width
        }
    }

    onStatusChanged: {
        if (page.status === StackView.Activating) pageStatusActivating();
        else if (page.status === StackView.Active) pageStatusActive();
        else if (page.status === StackView.Inactive) pageStatusInactive()
    }

    function scrollToTop() {
        flickable.contentY = 0;
    }
}
