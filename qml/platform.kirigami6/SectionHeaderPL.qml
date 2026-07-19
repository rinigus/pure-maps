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
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Item {
    id: item

    Kirigami.FormData.isSection: true
    Kirigami.FormData.label: text
    Layout.preferredHeight: sep.Layout.preferredHeight
    Layout.preferredWidth: sep.Layout.preferredWidth
    implicitHeight: txt.height + sep.height + styler.themePaddingSmall
    width: parent.width

    property bool   inForm: parent.isFormLayout ? true : false
    property string text
    property alias  wrapMode: txt.wrapMode

    Kirigami.Separator {
        id: sep
        width: parent.width
    }

    Kirigami.Heading {
        id: txt

        anchors.left: parent.left
        anchors.leftMargin: styler.themeHorizontalPageMargin
        anchors.right: parent.right
        anchors.rightMargin: styler.themeHorizontalPageMargin
        anchors.top: sep.bottom
        anchors.topMargin: styler.themePaddingSmall
        height: inForm ? 0 : implicitHeight
        horizontalAlignment: Text.AlignLeft
        level: 4
        text: inForm ? "" : item.text
        visible: text
    }
}
