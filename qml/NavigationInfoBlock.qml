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
import Sailfish.Silica 1.0

Rectangle {
    id: block
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.bottom: parent.bottom
    color: app.styler.blockBg
    height: app.mode === modes.navigate && app.portrait ? Theme.paddingSmall + (app.portrait ? speed.height : timeDest.height) : 0
    visible: app.mode === modes.navigate || app.mode === modes.followMe
    z: 500

    property string destDist:  app.navigationStatus.destDist
    property string destTime:  app.navigationStatus.destTime
    // used to track whether there are already too many elements on the
    // right side in landscape mode while navigating. this can happen when
    // rather large sign with directions shows up. by setting this property to false,
    // the right side data is temporarly not shown until the sign goes away
    property bool   rightSideTooBusy: false
    property int    shieldLeftHeight: (!app.portrait && app.mode === modes.navigate) || app.mode === modes.followMe ? speed.height + Theme.paddingMedium : 0
    property int    shieldLeftWidth:  (!app.portrait && app.mode === modes.navigate) || app.mode === modes.followMe ? speed.width + Theme.horizontalPageMargin + speedUnit.width + Theme.paddingSmall + Theme.paddingLarge : 0
    property int    shieldRightHeight: !app.portrait && app.mode === modes.navigate && !rightSideTooBusy ? timeDest.height + distDest.height + Theme.paddingMedium : 0
    property int    shieldRightWidth:  !app.portrait && app.mode === modes.navigate ? Math.max(timeDest.width, distDest.width) + Theme.horizontalPageMargin+ Theme.paddingLarge : 0

    Label {
        // speed
        id: speed
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: Theme.horizontalPageMargin
        color: Theme.primaryColor
        font.pixelSize: Theme.fontSizeHuge

        function update() {
            if (app.mode === modes.explore) return;
            // Update speed and positioning accuracy values in user's preferred units.
            if (!gps.position.speedValid) {
                text = ""
                return;
            }

            if (app.conf.units === "american") {
                text = "%1".arg(Math.round(gps.position.speed * 2.23694))
            } else if (app.conf.units === "british") {
                text = "%1".arg(Math.round(gps.position.speed * 2.23694))
            } else {
                text = "%1".arg(Math.round(gps.position.speed * 3.6))
            }
        }
    }

    Label {
        // speed unit
        id: speedUnit
        anchors.left: speed.right
        anchors.baseline: speed.baseline
        anchors.leftMargin: Theme.paddingSmall
        color: Theme.secondaryColor
        font.pixelSize: Theme.fontSizeMedium

        function update() {
            if (app.mode === modes.explore) return;
            if (app.conf.units === "american") {
                text = app.tr("mph")
            } else if (app.conf.units === "british") {
                text = app.tr("mph")
            } else {
                text = app.tr("km/h")
            }
        }
    }

    Label {
        // Time remaining to destination
        id: timeDest
        anchors.baseline: speed.baseline
        anchors.left: speedUnit.right
        anchors.leftMargin: Theme.paddingLarge
        anchors.right: distDest.left
        anchors.rightMargin: Theme.paddingLarge
        color: Theme.primaryColor
        font.pixelSize: Theme.fontSizeLarge
        fontSizeMode: Text.HorizontalFit
        horizontalAlignment: Text.AlignHCenter
        states: [
            State {
                when: !app.portrait
                AnchorChanges {
                    target: timeDest
                    anchors.baseline: undefined
                    anchors.bottom: distDest.top
                    anchors.left: undefined
                    anchors.right: parent.right
                }
                PropertyChanges {
                    target: timeDest
                    anchors.bottomMargin: Theme.padiingLarge
                    anchors.rightMargin: Theme.horizontalPageMargin
                    width: implicitWidth
                }
            }
        ]
        text: !rightSideTooBusy ? block.destTime : ""
        visible: app.mode === modes.navigate
    }

    Label {
        // Distance remaining to destination
        id: distDest
        anchors.baseline: speed.baseline
        anchors.right: parent.right
        anchors.rightMargin: Theme.horizontalPageMargin
        color: Theme.primaryColor
        font.pixelSize: Theme.fontSizeLarge
        text: !rightSideTooBusy ? block.destDist : ""
        visible: app.mode === modes.navigate
    }

    MouseArea {
        anchors.fill: parent
        onClicked: app.showMenu();
    }

    Connections {
        target: app
        onModeChanged: block.update()
        onPortraitChanged: block.checkIfBusy();
        onScreenHeightChanged: block.checkIfBusy();
    }

    Connections {
        target: app.conf
        onUnitsChanged: block.update()
    }

    Connections {
        target: gps
        onPositionChanged: speed.update()
    }

    Connections {
        target: northArrow
        onYChanged: block.checkIfBusy();
        onHeightChanged: block.checkIfBusy();
    }

    Component.onCompleted: {
        block.update();
        block.checkIfBusy();
    }

    function checkIfBusy() {
        if (app.mode !== modes.navigate || app.portrait) {
            block.rightSideTooBusy = false;
            return;
        }
        var top = northArrow.y+northArrow.height;
        var tofit = scaleBar.height + timeDest.height + distDest.height + Theme.paddingMedium + 2*Theme.paddingLarge;
        var bottom = app.screenHeight - tofit;
        block.rightSideTooBusy = bottom - top < 0;
    }

    function update() {
        speed.update();
        speedUnit.update();
    }

}
