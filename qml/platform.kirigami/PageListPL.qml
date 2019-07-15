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
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.2
import org.kde.kirigami 2.7 as Kirigami
import "."

Kirigami.ScrollablePage {
    id: page
    flickable: listView
    mainItem: listView
    Kirigami.ColumnView.fillWidth: false
    Kirigami.Theme.colorSet: Kirigami.Theme.Window

    property string acceptIconName: styler.iconForward
    property alias  acceptText: mainAction.text
    property var    acceptCallback
    property bool   active: page.isCurrentPage
    property bool   canNavigateForward: true
    property int    currentIndex: listView.currentIndex
    property bool   currentPage: app.pages.currentItem === page
    property alias  delegate: listView.delegate
    // has to be Component, so wrap it as Component { Item {} }
    property var    headerExtra
    property alias  model: listView.model
    property var    pageMenu
    property bool   placeholderEnabled: true
    property string placeholderText

    // hide all other items in this list
    // to avoid interference with Kirigami Page
    default property var _content

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

    ListView {
        id: listView

        currentIndex: -1
        header: Column {
            height: styler.themePaddingLarge +
                    (headerExtraLoader.height > 0 ? headerExtraLoader.height + styler.themePaddingLarge : 0)
            width: listView.width

            Item {
                height: styler.themePaddingLarge
                width: parent.width
            }

            Loader {
                id: headerExtraLoader
                active: sourceComponent ? true : false
                width: parent.width
                sourceComponent: page.headerExtra
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

        onCurrentIndexChanged: {
            if (page.currentIndex !== listView.currentIndex)
               page.currentIndex = listView.currentIndex;
        }
    }

    onCurrentIndexChanged: {
        // callLater is used to ensure that all property handlers by
        // listView, such as creation of delegates, are finished
        // before application of new currentIndex
        Qt.callLater(function (){
            listView.currentIndex = page.currentIndex;
        });
    }

    onCurrentPageChanged: {
        if (page.currentPage) {
            pageStatusActivating();
            pageStatusActive();
        } else pageStatusInactive();
    }

    function positionViewAtIndex(i) {
        listView.positionViewAtIndex(i, ListView.Center);
    }

}
