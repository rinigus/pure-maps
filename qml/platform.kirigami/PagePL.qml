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
import "."

Kirigami.ScrollablePage {
    id: page
    leftPadding: 0
    rightPadding: 0
    Kirigami.ColumnView.fillWidth: false
    Kirigami.Theme.colorSet: Kirigami.Theme.Window

    property string        acceptIconName: styler.iconForward
    property alias         acceptText: mainAction.text
    property var           acceptCallback
    property bool          canNavigateForward: true
    property bool          currentPage: app.pages.currentItem === page
    readonly property bool empty: false
    property var           pageMenu

    signal pageStatusActivating
    signal pageStatusActive
    signal pageStatusInactive

    actions {
        main: Kirigami.Action {
            id: mainAction
            enabled: page.canNavigateForward === true
            icon.name: page.acceptIconName
            visible: !page.hideAcceptButton && (page.isDialog || app.pages.hasAttached(page))
            text: app.tr("Accept")
            onTriggered: {
                if (acceptCallback) acceptCallback();
                else app.pages.navigateForward();
            }
        }

        contextualActions: page.pageMenu ? page.pageMenu.items : []
    }

    onCurrentPageChanged: {
        if (page.currentPage) {
            pageStatusActivating();
            pageStatusActive();
        } else pageStatusInactive();
    }

    function scrollToTop() {
        flickable.contentY = 0;
    }
}
