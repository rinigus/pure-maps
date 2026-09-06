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
    leftPadding: 0
    rightPadding: 0

    property var           acceptCallback
    property string        acceptIconName: styler.iconForward
    property alias         acceptText: mainAction.text
    property bool          canNavigateForward: true
    property bool          currentPage: app.pages.currentItem === page || page.isCurrentPage
    readonly property bool empty: false
    property bool          hideAcceptButton: false
    property bool          isDialog: false
    property var           pageMenu

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

    onCurrentPageChanged: {
        if (page.currentPage) {
            pageStatusActivating();
            pageStatusActive();
        } else {
            pageStatusInactive();
        }
    }

    function scrollToTop() {
        flickable.contentY = 0;
    }
}
