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
import "."
import ".."

Column {
    id: section

    width: parent.width
    spacing: 0

    property int currentIndex // ignored

    property list<QtObject> selections
    default property alias  content: section.selections

    signal closeAll

    Repeater {
        delegate: Column {
            id: del

            spacing: 0
            width: section.width

            property bool expanded: false

            IconListItem {
                icon: expanded ? styler.iconDown : styler.iconForward
                iconHeight: styler.themeItemSizeSmall*0.5
                label: selections[model.index].title
                labelBold: expanded
                onClicked: {
                    if (!del.expanded) closeAll();
                    del.expanded = !del.expanded;
                }
            }

            Item {
                id: item
                anchors.left: parent.left
                anchors.leftMargin: styler.themeHorizontalPageMargin
                anchors.right: parent.right
                anchors.rightMargin: styler.themeHorizontalPageMargin
                data: selections[model.index]
                height: childrenRect.height
                visible: del.expanded
            }

            Spacer {
                height: styler.themePaddingLarge
                visible: expanded
            }

            Connections {
                target: section
                onCloseAll: del.expanded = false
            }
        }

        model: selections.length
    }
}
