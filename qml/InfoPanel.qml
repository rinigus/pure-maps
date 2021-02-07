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
        var h = 0;
        if (poiBlock.height > 0) h += poiFlickable.height + poiFlickable.anchors.topMargin;
        if (infoText) h += infoBg.height;
        else if (h > 0) h += styler.themePaddingLarge;
        return h;
    }
    mode: panelModes.bottom
    visible: !app.modalDialog

    property alias infoText: infoLabel.text
    property bool  showMenu: infoText

    signal poiHidden(string poiId);

    Flickable {
        id: poiFlickable
        anchors.top: parent.top
        anchors.topMargin: styler.themePaddingLarge
        boundsBehavior: Flickable.StopAtBounds
        clip: true
        contentHeight: poiBlock.height
        contentWidth: width
        height: Math.min(contentHeight,
                         map.height - anchors.topMargin -
                         (infoText ? infoBg.height : styler.themePaddingLarge))
        width: panel.width
        PoiBlock {
            id: poiBlock
            anchors.top: parent.top
        }
    }

    Rectangle {
        id: infoBg
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        color: infoBgMouse.pressed ? styler.blockPressed : "transparent"
        height: infoText ? Math.max(backButton.height, infoLabel.height, menuButton.height) + 2*styler.themePaddingLarge : 0

        MouseArea {
            id: infoBgMouse
            anchors.fill: parent
            onClicked: {
                app.showMenu();
                _hide();
            }
        }

        IconButtonPL {
            id: backButton
            anchors.left: parent.left
            anchors.leftMargin: styler.themeHorizontalPageMargin
            anchors.verticalCenter: infoBg.verticalCenter
            iconHeight: styler.themeIconSizeMedium
            iconName: showMenu ? styler.iconClose : ""
            padding: 0
            visible: showMenu
            onClicked: {
                app.resetMenu();
                _hide();
            }
        }

        ListItemLabel {
            id: infoLabel
            anchors.left: backButton.right
            anchors.leftMargin: styler.themePaddingLarge
            anchors.right: menuButton.left
            anchors.rightMargin: styler.themePaddingLarge
            anchors.verticalCenter: infoBg.verticalCenter
            color: infoBgMouse.pressed ? styler.themeHighlightColor : styler.themePrimaryColor
            font.pixelSize: styler.themeFontSizeLarge
            height: text ? implicitHeight: 0
            truncMode: truncModes.fade
            verticalAlignment: Text.AlignTop
        }

        IconPL {
            id: menuButton
            anchors.right: parent.right
            anchors.rightMargin: styler.themeHorizontalPageMargin
            anchors.verticalCenter: infoBg.verticalCenter
            height: iconHeight
            iconHeight: styler.themeIconSizeMedium
            iconName: showMenu ? styler.iconMenu : ""
            visible: showMenu
        }
    }

    onHidden: _hide()

    onSwipedOut: app.resetMenu()

    function _hide() {
        if (poiBlock.height > 0) {
            var pid = poiBlock.poiId;
            poiBlock.hide();
            poiHidden(pid);
        }
        infoText = "";
    }

    function hidePoi() {
        if (!poiBlock.height) return;
        var pid = poiBlock.poiId;
        poiBlock.hide();
        poiHidden(pid);
    }

    function showPoi(poi) {
        if (!poi) {
            hidePoi();
            return;
        }
        var old_poi = "";
        if (poiBlock.height > 0 && poi.poiId !== poiBlock.poiId)
            old_poi = poiBlock.poiId;
        poiBlock.show(poi);
        if (old_poi) poiHidden(old_poi);
    }
}
