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

import QtQuick 2.0
import "."

ListItemPL {
    id: item
    anchors.left: parent.left
    anchors.right: parent.right
    contentHeight: Math.max(styler.themeItemSizeSmall, profileComboBox.height)

    default property alias  content: item.items
    property alias          iconName: icon.iconName
    property list<QtObject> items
    property alias          text: label.text

    IconPL {
        id: icon
        anchors.left: parent.left
        anchors.leftMargin: styler.themeHorizontalPageMargin
        anchors.verticalCenter: label.verticalCenter
        iconHeight: styler.themeItemSizeSmall*0.8
    }

    LabelPL {
        id: label
        anchors.left: icon.right
        anchors.leftMargin: styler.themePaddingMedium
        color: {
            if (!item.enabled) return styler.themeSecondaryHighlightColor;
            if (item.highlighted) return styler.themeHighlightColor;
            return styler.themePrimaryColor;
        }
        height: styler.themeItemSizeSmall
        truncMode: truncModes.fade
        verticalAlignment: Text.AlignVCenter
    }

    ComboBoxPL {
        id: profileComboBox
        anchors.left: label.right
        anchors.leftMargin: styler.themePaddingMedium
        anchors.right: parent.right
        anchors.top: styler.isSilica ? parent.top : undefined
        anchors.verticalCenter: styler.isSilica ? undefined : label.verticalCenter
        model: []
        onCurrentIndexChanged: {
            if (profileComboBox.currentIndex < 0 || profileComboBox.currentIndex >= items.length)
                return;
            items[profileComboBox.currentIndex].clicked();
        }
    }

    Component.onCompleted: {
        var active = 0;
        var model = [];
        for (var i=0; i < items.length; i++) {
            model.push(items[i].text);
            if (items[i].checked) active = i;
        }
        profileComboBox.model = model;
        profileComboBox.currentIndex = active;
    }

    onClicked: profileComboBox.activate()
}
