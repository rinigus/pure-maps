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

    property string acceptIconName // for compatibility
    property string acceptText // for compatibility
    property bool   active: page.status === StackView.Active
    property bool   canNavigateForward: true
    property alias  currentIndex: listView.currentIndex
    property alias  delegate: listView.delegate
    // has to be Component, so wrap it as Component { Item {} }
    property var    headerExtra
    property alias  model: listView.model
    property alias  pageMenu: page.footer
    property alias  placeholderEnabled: viewPlaceholder.visible
    property alias  placeholderText: viewPlaceholder.text
    property int    status: StackView.status

    signal pageStatusActivating
    signal pageStatusActive
    signal pageStatusInactive

    ListView {
        id: listView

        anchors.bottomMargin: styler.themePaddingLarge
        anchors.fill: parent
        anchors.topMargin: styler.themePaddingLarge
        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

        header: Column {
            height: headerExtraLoader.height + styler.themePaddingLarge
            width: parent.width

            Loader {
                id: headerExtraLoader
                active: sourceComponent ? true : false
                width: parent.width
                sourceComponent: page.headerExtra
            }
        }
    }

    Label {
        id: viewPlaceholder
        anchors.fill: parent
        anchors.margins: styler.themeHorizontalPageMargin
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WordWrap
    }

    onStatusChanged: {
        if (page.status === StackView.Activating) pageStatusActivating();
        else if (page.status === StackView.Active) pageStatusActive();
        else if (page.status === StackView.Inactive) pageStatusInactive()
    }

    function positionViewAtIndex(i) {
        listView.positionViewAtIndex(i, ListView.Center);
    }

}
