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

MouseArea {
    id: attributionButton
    anchors.left: parent.left
    anchors.leftMargin: styler.themePaddingLarge
    anchors.top: navigationBlock.bottom
    anchors.topMargin: styler.themePaddingLarge
    height: styler.themeIconSizeSmall
    states: [
        State {
            when: !app.portrait && navigationBlockLandscapeLeftShield.height > 0
            AnchorChanges {
                target: attributionButton
                anchors.top: navigationBlockLandscapeLeftShield.bottom
            }
        }
    ]
    width: extra.width + main.width
    z: 500

    property string logo: ""

    IconButtonPL {
        id: extra
        anchors.left: parent.left
        anchors.top: parent.top
        iconHeight: parent.height
        padding: 0
        visible: iconSource

        Connections {
            target: styler
            onIconVariantChanged: extra.setSource()
        }

        Component.onCompleted: setSource()
        onClicked: attributionButton.pushPage()

        function setSource() {
            if (logo && logo !== "default") extra.iconSource = app.getIcon("icons/attribution/%1".arg(logo));
            else extra.iconSource = "";
        }
    }

    IconButtonPL {
        id: main
        anchors.left: extra.right
        anchors.leftMargin: styler.themePaddingMedium
        anchors.top: parent.top
        iconHeight: parent.height
        iconSource: app.getIcon("icons/attribution/default")
        padding: 0

        Connections {
            target: styler
            onIconVariantChanged: main.iconSource = app.getIcon("icons/attribution/default")
        }

        onClicked: attributionButton.pushPage()
    }

    onClicked: pushPage()
    onLogoChanged: extra.setSource()

    function pushPage() {
        app.push(Qt.resolvedUrl("AttributionPage.qml"), {}, true);
    }
}
