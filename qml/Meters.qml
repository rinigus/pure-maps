/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2015 Osmo Salomaa
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

import "js/util.js" as Util

Item {
    id: meters
    anchors.right: parent.right
    anchors.rightMargin: styler.themePaddingLarge
    anchors.top: navigationSign.bottom
    anchors.topMargin: styler.themePaddingLarge
    height: labels.implicitHeight
    opacity: 0.9
    states: State {
        when: hidden
        AnchorChanges {
            target: meters
            anchors.bottom: navigationSign.bottom
            anchors.top: undefined
        }
    }
    transitions: Transition {
        AnchorAnimation { duration: app.conf.animationDuration; }
    }
    width: parent.width
    visible: app.mode === modes.explore || app.mode === modes.exploreRoute
    z: 200

    property bool hidden: app.modalDialog || app.infoPanelOpen || (map.cleanMode && !app.conf.mapModeCleanShowMeters)

    Text {
        id: values
        anchors.bottom: parent.bottom
        anchors.right: labels.left
        color: styler.fg
        font.bold: true
        font.family: "sans-serif"
        font.pixelSize: styler.themeFontSizeOnMap
        horizontalAlignment: Text.AlignRight
        lineHeight: 1.25
    }

    Text {
        id: labels
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        color: styler.fg
        font.bold: true
        font.family: "sans-serif"
        font.pixelSize: styler.themeFontSizeOnMap
        horizontalAlignment: Text.AlignLeft
        lineHeight: 1.25
        text: "\n"
    }

    Timer {
        interval: 3000
        repeat: true
        running: app.running
        triggeredOnStart: true
        onTriggered: meters.update();
    }

    function update() {
        // Update speed and positioning accuracy values in user's preferred units.
        var lines = ["—", "—"];
        if (app.conf.units === "american") {
            labels.text = " %1\n %2".arg(app.tr("mph")).arg(app.tr("ft"))
            if (gps.speedValid)
                lines[0] = Math.round(gps.speed * 2.23694);
            if (gps.coordinateValid && gps.horizontalAccuracyValid)
                lines[1] = Util.siground(gps.horizontalAccuracy * 3.28084, 2);
            lines[1] = "\u2300 %1".arg(lines[1]);
            values.text = lines.join("\n");
            values.doLayout();

        } else if (app.conf.units === "british") {
            labels.text = " %1\n %2".arg(app.tr("mph")).arg(app.tr("yd"))
            if (gps.speedValid)
                lines[0] = Math.round(gps.speed * 2.23694);
            if (gps.coordinateValid && gps.horizontalAccuracyValid)
                lines[1] = Util.siground(gps.horizontalAccuracy * 1.09361, 2);
            lines[1] = "\u2300 %1".arg(lines[1]);
            values.text = lines.join("\n");
            values.doLayout();

        } else {
            labels.text = " %1\n %2".arg(app.tr("km/h")).arg(app.tr("m"))
            if (gps.speedValid)
                lines[0] = Math.round(gps.speed * 3.6);
            if (gps.coordinateValid && gps.horizontalAccuracyValid)
                lines[1] = Util.siground(gps.horizontalAccuracy, 2);
            lines[1] = "\u2300 %1".arg(lines[1]);
            values.text = lines.join("\n");
            values.doLayout();

        }
    }

}
