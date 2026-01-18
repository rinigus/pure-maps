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

Item {
    id: page
    height: parent ? parent.height : undefined
    width: parent ? parent.width : undefined

    default property alias content: itemCont.data
    readonly property bool empty: true
    property int           status: StackView.status
    property string        title

    signal pageStatusActivating
    signal pageStatusActive
    signal pageStatusInactive

    HeaderBarImpl {
        id: header
        anchors.top: parent.top
        page: page
        onAccepted: app.pages.navigateForward();
    }

    Item {
        id: itemCont
        anchors.bottom: parent.bottom
        anchors.top: header.bottom
        width: parent.width
    }

    onStatusChanged: {
        if (page.status === StackView.Activating) pageStatusActivating();
        else if (page.status === StackView.Active) pageStatusActive();
        else if (page.status === StackView.Inactive) pageStatusInactive()
    }
}
