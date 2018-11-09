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

// QtQuick Controls 2 specific implementation
// for header bar that is used to display page
// title and navigation controls

ToolBar {
    id: bar
    height: visible ? implicitHeight : 0
    width: page.width
    visible: page && (!(page.empty) || app.pages.currentIndex > 0)

    property string acceptDescription
    property var    page

    signal accepted

    RowLayout {
        anchors.fill: parent
        spacing: app.styler.themePaddingLarge

        ToolButton {
            id: toolButton
            text: "\u25C0 "
            font.pointSize: app.styler.themeFontSizeExtraLarge
            onClicked: app.pages.pop()
        }

        Label {
            text: page.title
            elide: Label.ElideRight
            horizontalAlignment: Qt.AlignHCenter
            verticalAlignment: Qt.AlignVCenter
            Layout.fillWidth: true
            font.pointSize: app.styler.themeFontSizeExtraLarge
        }

        ToolButton {
            id: acceptButton
            font.pixelSize: app.styler.themeFontSizeExtraLarge
            text: bar.acceptDescription + (app.pages.hasAttached ? " \u25b6" : "")
            visible: text
            enabled: page.canNavigateForward === true
            onClicked: {
                bar.accepted();
            }
        }
    }
}
