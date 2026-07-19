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
import QtQuick.Controls
import org.kde.kirigami as Kirigami
import pm.platform 1.0

Kirigami.ScrollablePage {
    id: page

    Kirigami.ColumnView.fillWidth: false
    Kirigami.Theme.colorSet: Kirigami.Theme.Window
    actions: page.pageMenu ? [mainAction].concat(page.pageMenu.items) : [mainAction]
    flickable: listView
    leftPadding: 0
    rightPadding: 0

    property var    acceptCallback
    property string acceptIconName: styler.iconForward
    property alias  acceptText: mainAction.text
    property bool   active: page.isCurrentPage
    property bool   canNavigateForward: true
    property alias  currentIndex: listView.currentIndex
    property bool   currentPage: app.pages.currentItem === page || page.isCurrentPage
    property alias  delegate: listView.delegate
    property var    headerExtra
    property bool   hideAcceptButton: false
    property bool   isDialog: false
    property alias  model: listView.model
    property var    pageMenu
    property bool   placeholderEnabled: true
    property string placeholderText

    default property var _content

    signal pageStatusActivating
    signal pageStatusActive
    signal pageStatusInactive

    Kirigami.Action {
        id: mainAction

        displayHint: Kirigami.DisplayHint.KeepVisible
        enabled: page.canNavigateForward === true
        icon.name: page.acceptIconName
        text: app.tr("Accept")
        visible: !page.hideAcceptButton && (page.isDialog || app.pages.hasAttached(page))

        onTriggered: {
            if (acceptCallback) acceptCallback();
            else app.pages.navigateForward();
        }
    }

    ListView {
        id: listView

        currentIndex: -1
        width: page.width

        header: Column {
            height: styler.themePaddingLarge + (headerExtraLoader.height > 0 ? headerExtraLoader.height + styler.themePaddingLarge : 0)
            width: listView.width

            Item {
                height: styler.themePaddingLarge
                width: parent.width
            }

            Loader {
                id: headerExtraLoader

                active: sourceComponent ? true : false
                sourceComponent: page.headerExtra
                width: parent.width
            }
        }

        footer: Label {
            height: placeholderEnabled ? implicitHeight : 0
            horizontalAlignment: Text.AlignHCenter
            text: placeholderEnabled ? placeholderText : ""
            verticalAlignment: Text.AlignVCenter
            visible: placeholderEnabled
            width: placeholderEnabled ? listView.width : 0
            wrapMode: Text.WordWrap
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

    function positionViewAtIndex(i) {
        listView.positionViewAtIndex(i, ListView.Center);
    }
}
