/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2018 Osmo Salomaa
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
import "platform"

IconButtonPL {
    id: attributionButton
    anchors.left: parent.left
    anchors.leftMargin: styler.themePaddingLarge
    anchors.top: navigationBlock.bottom
    anchors.topMargin: styler.themePaddingLarge
    iconHeight: styler.themeIconSizeSmall
    iconSource: app.getIcon("icons/attribution/default")
    padding: 0
    states: [
        State {
            when: !app.portrait && navigationBlockLandscapeLeftShield.height > 0
            AnchorChanges {
                target: attributionButton
                anchors.top: navigationBlockLandscapeLeftShield.bottom
            }
        }
    ]
    z: 500

    property string logo: ""

    onClicked: app.push(Qt.resolvedUrl("AttributionPage.qml"), {}, true)
    onLogoChanged: attributionButton.iconSource = logo ?
        app.getIcon("icons/attribution/%1".arg(logo)) : "";

    Connections {
        target: styler
        onIconVariantChanged: attributionButton.iconSource = attributionButton.logo ?
                                  app.getIcon("icons/attribution/%1".arg(attributionButton.logo)) : "";
    }

}
