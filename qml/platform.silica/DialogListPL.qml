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

import QtQuick 2.0
import Sailfish.Silica 1.0

Dialog {
    id: page
    allowedOrientations: app.defaultAllowedOrientations

    property string acceptIconName // for compatibility
    property string acceptText
    property bool   active: page.status === PageStatus.Active
    property alias  currentIndex: listView.currentIndex
    property alias  delegate: listView.delegate
    property var    headerExtra
    property alias  model: listView.model
    property alias  placeholderEnabled: viewPlaceholder.enabled
    property alias  placeholderText: viewPlaceholder.hintText
    property string title

    signal pageStatusActivating
    signal pageStatusActive
    signal pageStatusInactive

    SilicaListView {
        id: listView
        anchors.fill: parent

        header: Column {
            height: header.height + headerExtraLoader.height + styler.themePaddingLarge
            width: parent.width

            DialogHeader {
                id: header
            }

            Loader {
                id: headerExtraLoader
                active: sourceComponent ? true : false
                width: parent.width
                sourceComponent: page.headerExtra
            }
        }

        ViewPlaceholder {
            id: viewPlaceholder
        }

        VerticalScrollDecorator { flickable: listView }
    }

    onStatusChanged: {
        if (page.status === PageStatus.Activating) pageStatusActivating();
        else if (page.status === PageStatus.Active) pageStatusActive();
        else if (page.status === PageStatus.Inactive) pageStatusInactive()
    }
}
