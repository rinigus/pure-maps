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
import "platform"

Rectangle {
    id: master
    anchors.bottom: referenceBlockBottom.y > menuButton.y && menuButton.visible ?
                    menuButton.top :
                    referenceBlockBottom.top
    anchors.bottomMargin: styler.themePaddingSmall
    anchors.horizontalCenter: parent.horizontalCenter
    color: "transparent"
    height: !navigationOverview.streetNameInOverview ? cover.height : 0
    visible: !app.modalDialog && !navigationOverview.streetNameInOverview
    width: cover.width
    z: 400

    property int maxWidth: parent.width - 2*_x
    property int _x: {
        var speed = speedLimit.visible ? speedLimit.x + speedLimit.width : 0;
        var left = Math.max(speed, referenceBlockBottomLeft.width);
        var right = referenceBlockBottomRight.width;
        return Math.max(left, right) + styler.themePaddingLarge
    }

    Rectangle {
        id: cover
        anchors.centerIn: streetname
        color: styler.itemBg
        height: streetname.height
        opacity: 0.75
        radius: styler.radius
        visible: streetname.visible
        width: streetname.width + 2*styler.themePaddingMedium
    }

    LabelPL {
        id: streetname
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        color: styler.itemFg
        font.pixelSize: styler.themeFontSizeLarge
        maximumLineCount: 1
        text: gps.streetName
        truncMode: truncModes.fade
        visible: (app.mode === modes.navigate || app.mode === modes.followMe || app.mode === modes.navigatePost) && (text !== undefined && text !== null && text.length>0)
        width: implicitWidth > master.maxWidth - 4*styler.themePaddingMedium ?
                   master.maxWidth-4*styler.themePaddingMedium : implicitWidth
    }
}
