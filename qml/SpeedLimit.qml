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

Rectangle {
    id: ring

    anchors.left: parent.left
    anchors.leftMargin: styler.themePaddingLarge
    anchors.bottom: referenceBlockBottomLeft.top
    anchors.bottomMargin: styler.themePaddingLarge
    border.width: 0.7*styler.themePaddingLarge
    border.color: "red"
    color: "white"
    height: width
    radius: width/2
    width: Math.round(Math.max(limit.width,limit.height) + 1.6*styler.themePaddingLarge + styler.themePaddingSmall)
    visible: {
        if (app.modalDialog) return false;
        if (app.mapMatchingMode !== "car" || app.conf.showSpeedLimit==="never")
            return false;
        if (app.conf.showSpeedLimit==="exceeding") {
            if (!gps.speedValid || gps.streetSpeedLimit==null || gps.streetSpeedLimit < 0)
                return false;
            if (gps.speed <= gps.streetSpeedLimit)
                return false;
        }
        return limit.text.length > 0
    }
    z: 400

    Text {
        id: limit
        anchors.centerIn: parent
        color: "black"
        font.bold: true
        font.family: "sans-serif"
        font.pixelSize: styler.themeFontSizeLarge
        style: Text.Outline
        styleColor: "white"
        text: {
            // Update speed limit in user's preferred units.
            if (app.mapMatchingMode !== "car")
                return "";

            if (gps.streetSpeedLimit==null || gps.streetSpeedLimit < 0)
                return "";

            // speed limit in m/s
            if (app.conf.units === "american") {
                return "%1".arg(Math.round(gps.streetSpeedLimit * 2.23694))
            } else if (app.conf.units === "british") {
                return "%1".arg(Math.round(gps.streetSpeedLimit * 2.23694))
            } else {
                return "%1".arg(gps.streetSpeedLimit * 3.6)
            }
        }
    }
}
