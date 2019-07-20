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
        if (poiBlock.height > 0) h += poiBlock.height + styler.themePaddingLarge;
        if (infoText) h += infoBg.height;
        else if (h > 0) h += styler.themePaddingLarge;
        return h;
    }
    mode: panelModes.bottom
    visible: !app.modalDialog

    property alias infoText: infoLabel.text
    property bool  showMenu: infoText

    signal poiHidden(string poiId);

    PoiBlock {
        id: poiBlock
        anchors.top: parent.top
        anchors.topMargin: styler.themePaddingLarge
    }

    Item {
        id: infoBg
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: infoText ? Math.max(backButton.height, infoLabel.height, menuButton.height) + 2*styler.themePaddingLarge : 0

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
            color: styler.themePrimaryColor
            font.pixelSize: styler.themeFontSizeLarge
            height: text ? implicitHeight: 0
            truncMode: truncModes.fade
            verticalAlignment: Text.AlignTop
        }

        IconButtonPL {
            id: menuButton
            anchors.right: parent.right
            anchors.rightMargin: styler.themeHorizontalPageMargin
            anchors.verticalCenter: infoBg.verticalCenter
            iconHeight: styler.themeIconSizeMedium
            iconName: showMenu ? styler.iconMenu : ""
            padding: 0
            visible: showMenu
            onClicked: {
                app.showMenu();
                _hide();
            }
        }
    }

    onClicked: {
        if (!infoText) return;
        if (mouse.y >= infoBg.y && mouse.y <= infoBg.y + infoBg.height
                && mouse.x >= infoBg.x + infoLabel.x
                && mouse.x <= infoBg.x + infoLabel.x + infoLabel.width) {
            // consider as a click on menu button
            app.showMenu();
            _hide();
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
