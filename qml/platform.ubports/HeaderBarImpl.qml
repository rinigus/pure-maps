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
import "."

// QtQuick Controls 2 specific implementation
// for header bar that is used to display page
// title and navigation controls

ToolBar {
    id: bar
    height: visible ? styler.themeItemSizeSmall : 0
    width: page.width
    visible: page && (!(page.empty) || app.pages.currentIndex > 0)

    property string acceptDescription
    property var    page

    property int _buttonWidth: Math.max(toolButton.width, acceptButton.width)

    signal accepted

    Button {
        id: toolButton
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.verticalCenter: label.verticalCenter
        height: bar.height
        width: im.width + styler.themeHorizontalPageMargin + styler.themePaddingLarge

        IconPL {
            id: im
            anchors.left: parent.left
            anchors.leftMargin: styler.themeHorizontalPageMargin
            anchors.verticalCenter: parent.verticalCenter
            iconHeight: label.height
            iconSource: styler.iconBack
        }

        onClicked: app.pages.pop()
    }

    Label {
        id: label
        anchors.left: parent.left
        anchors.leftMargin: toolButton.anchors.leftMargin + _buttonWidth + styler.themePaddingLarge
        anchors.right: parent.right
        anchors.rightMargin: acceptButton.anchors.rightMargin + _buttonWidth + styler.themePaddingLarge
        anchors.verticalCenter: parent.verticalCenter
        text: page.title
        elide: Label.ElideRight
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter
        Layout.fillWidth: true
        font.pixelSize: styler.themeFontSizeMedium
        font.bold: true
    }

    Button {
        id: acceptButton
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.verticalCenter: label.verticalCenter
        enabled: page.canNavigateForward === true
        height: styler.themeItemSizeSmall
        text: acceptDescription
        rightPadding: imA.anchors.rightMargin + styler.themePaddingMedium + imA.width
        visible: !page.hideAcceptButton && (app.pages.hasAttached || !!page.isDialog)
        Layout.minimumWidth: toolButton.width

        IconPL {
            id: imA
            anchors.right: parent.right
            anchors.rightMargin: styler.themeHorizontalPageMargin
            anchors.verticalCenter: parent.verticalCenter
            iconHeight: label.height
            iconSource: page.acceptIconName ? page.acceptIconName : styler.iconForward
            opacity: enabled ? 1 : 0.25
        }

        onClicked: {
            bar.accepted();
        }
    }
}
