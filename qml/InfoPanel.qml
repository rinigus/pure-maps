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
import "."
import "platform"

Panel {
    id: panel

    contentHeight: {
        if (!hasData) return 0;
        var h = 0;
        if (poiBlock.contentHeight) h += poiBlock.contentHeight + app.styler.themePaddingLarge;
        if (hasInfo) h += infoBg.height;
        else h += app.styler.themePaddingLarge;
        return h;
    }
    hasData: hasInfo || poiBlock.hasData

    property alias infoText: infoLabel.text
    property bool  hasInfo: infoText
    property bool  showMenu: hasInfo

    PoiBlock {
        id: poiBlock
        anchors.top: parent.top
        anchors.topMargin: app.styler.themePaddingLarge
        z: parent.z + 10
    }

    Rectangle {
        id: infoBg
        anchors.bottom: panel.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        color: app.styler.blockBg
        height: hasInfo ? Math.max(infoLabel.height, menuButton.height) + 2*app.styler.themePaddingLarge : 0
        //height: hasInfo ? infoLabel.height + 2*app.styler.themePaddingLarge : 0
        z: parent.z + 20
    }

    ListItemLabel {
        id: infoLabel
        anchors.left: parent.left
        anchors.leftMargin: app.styler.themeHorizontalPageMargin
        anchors.right: menuButton.left
        anchors.rightMargin: app.styler.themePaddingLarge
        anchors.verticalCenter: infoBg.verticalCenter
        color: app.styler.themeHighlightColor
        font.pixelSize: app.styler.themeFontSizeLarge
        height: text ? implicitHeight: 0
        truncMode: truncModes.fade
        verticalAlignment: Text.AlignTop
        z: infoBg.z + 10
    }

    IconButtonPL {
        id: menuButton
        anchors.right: parent.right
        anchors.rightMargin: app.styler.themeHorizontalPageMargin
        anchors.verticalCenter: infoBg.verticalCenter
        icon.source: showMenu ? app.styler.iconMenu : ""
        icon.sourceSize.height: app.styler.themeIconSizeMedium
        visible: showMenu
        z: infoLabel.z
        onClicked: {
            app.showMenu();
            _hide();
        }
    }

    onHidden: _hide()

    function _hide() {
        poiBlock.hide();
        infoText = "";
        app.resetMenu();
    }

    function hidePoi() {
        poiBlock.hide();
    }

    function showPoi(poi) {
        if (!poi) {
            hide();
            return;
        }
        panel.noAnimation = panel.hasData;
        poiBlock.show(poi);
        panel.noAnimation = false;
    }
}
