/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2014 Osmo Salomaa, 2018 Rinigus
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
import "."

// This is used to show speed in follow me and navigationPost mode
Rectangle {
    id: block
    anchors.top: parent.top
    anchors.topMargin: -radius
    anchors.right: parent.right
    anchors.rightMargin: -radius
    color: mouse.pressed ? styler.blockPressed : styler.blockBg
    height: speed.height + styler.themePaddingMedium
    radius: styler.radius
    visible: !app.modalDialog && (app.mode === modes.followMe || app.mode === modes.navigatePost) && speed.text
    width: speed.width + styler.themePaddingLarge +
           speedUnit.width + styler.themePaddingSmall +
           styler.themeHorizontalPageMargin + radius
    z: 400

    MouseArea {
        id: mouse
        anchors.fill: parent
        onClicked: {
            if (app.mode === modes.followMe)
                app.pushMain(Qt.resolvedUrl("RoutePage.qml"));
            if (app.mode === modes.navigatePost)
                app.showNavigationPages();
        }
    }

    LabelPL {
        // speed
        id: speed
        anchors.right: speedUnit.left
        anchors.rightMargin: styler.themePaddingSmall
        anchors.top: parent.top
        color: styler.themePrimaryColor
        font.pixelSize: styler.themeFontSizeHuge
        height: implicitHeight + styler.themePaddingMedium - parent.anchors.rightMargin
        text: {
            if (!gps.speedValid)
                return "";

            if (app.conf.units === "american")
                return "%1".arg(Math.round(gps.speed * 2.23694));
            else if (app.conf.units === "british")
                return "%1".arg(Math.round(gps.speed * 2.23694));
            return "%1".arg(Math.round(gps.speed * 3.6)); // km/h
        }
        verticalAlignment: Text.AlignBottom
    }

    LabelPL {
        // speed unit
        id: speedUnit
        anchors.baseline: speed.baseline
        anchors.right: parent.right
        anchors.rightMargin: styler.themeHorizontalPageMargin - block.anchors.rightMargin
        color: styler.themeSecondaryColor
        font.pixelSize: styler.themeFontSizeMedium
        text: {
            if (app.conf.units === "american") return app.tr("mph");
            else if (app.conf.units === "british") return app.tr("mph");
            return app.tr("km/h")
        }
        visible: speed.text ? true : false
    }
}
