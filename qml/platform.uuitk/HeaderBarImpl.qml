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
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0
import Lomiri.Components 1.3 as UC
import "."

UC.PageHeader {
    id: bar
    height: visible ? implicitHeight : 0
    navigationActions: UC.Action {
        iconSource: styler.iconBack
        onTriggered: app.pages.pop()
    }
    title: page.title
    width: page.width
    visible: page && (!(page.empty) || app.pages.currentIndex > 0)

    property string acceptDescription
    property var    page

    property bool _trailingVisible: !page.hideAcceptButton && (app.pages.hasAttached || !!page.isDialog)
    property list<QtObject> _actions: [
        UC.Action {
            id: acceptButton
            enabled: page.canNavigateForward === true
            iconSource: page.acceptIconName ? page.acceptIconName : styler.iconForward
            text: acceptDescription
            onTriggered: bar.accepted()
        }
    ]

    signal accepted

    Component.onCompleted: fillTrailingActions()
    on_TrailingVisibleChanged: fillTrailingActions()

    function fillTrailingActions() {
        if (!page) return;

        var trail = [];
        if (_trailingVisible)
            trail.push(acceptButton);

        if (page.pageMenu && page.pageMenu.items.length > 0)
            for (var i=0; i < page.pageMenu.items.length; i++)
                trail.push(page.pageMenu.items[i]);

        trailingActionBar.actions = trail;
        trailingActionBar.numberOfSlots = _trailingVisible ? 2 : 1
    }
}
