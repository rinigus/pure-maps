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
    id: block
    anchors.right: parent.right
    anchors.rightMargin: -styler.themePaddingMedium
    anchors.top: referenceBlockTopRight.bottom
    anchors.topMargin: height > 0 ? styler.themePaddingSmall : 0
    color: "#3768B7"
    height: {
        if (!app.conf.showNavigationSign) return 0;
        var h1 = numLabel.height;
        var h2 = nameLabel.height;
        var h3 = towardLabel.height;
        var h4 = branchLabel.height;
        var h = h1 + h2 + h3 + h4;
        if (h) return h + 2*styler.themePaddingMedium;
        return 0;
    }
    radius: styler.radius
    visible: !app.modalDialog && app.conf.showNavigationSign
    width: {
        if (!app.conf.showNavigationSign) return 0;
        var w1 = numLabel.text ? numLabel.width + exitLabel.width + styler.themePaddingSmall : 0;
        var w2 = nameLabel.implicitWidth;
        var w3 = towardLabel.implicitWidth;
        var w4 = branchLabel.implicitWidth;
        var w  = Math.max(w1, Math.min(parent.width/3, Math.max(w2, w3, w4)));
        if (w) return w + 2*styler.themePaddingLarge;
        return 0;
    }
    z: 400

    property var    sign:   app.navigator.sign
    property var    street: app.navigator.street
    property bool   signActive: app.mode === modes.navigate && sign!=null && (sign.exit_number!=null || sign.exit_name!=null || sign.exit_toward!=null || sign.exit_branch!=null)

    Rectangle {
        id: signBorder
        anchors.fill: parent
        anchors.margins: styler.themePaddingSmall/2
        border.color: "white"
        border.width: styler.themePaddingSmall/2
        color: "transparent"
        radius: styler.radius
    }
    
    LabelPL {
        // Exit number
        id: numLabel
        anchors.right: parent.right
        anchors.rightMargin: styler.themePaddingLarge
        anchors.top: parent.top
        anchors.topMargin: block.signActive ? styler.themePaddingMedium : 0
        color: "white"
        font.bold: true
        font.pixelSize: styler.themeFontSizeLarge
        height: text ? implicitHeight + 0*styler.themePaddingSmall: 0
        text: block.getstr("exit_number", " ")
        verticalAlignment: Text.AlignBottom
        width: text ? implicitWidth : 0
    }

    LabelPL {
        // Word "Exit"
        id: exitLabel
        anchors.baseline: numLabel.baseline
        anchors.right: numLabel.left
        anchors.rightMargin: styler.themePaddingSmall
        color: "white"
        height: numLabel.text ? implicitHeight : 0
        font.pixelSize: styler.themeFontSizeMedium
        text: app.tr("EXIT")
        visible: numLabel.text
        width: numLabel.text ? implicitWidth : 0
    }

    LabelPL {
        // Exit name
        id: nameLabel
        anchors.right: parent.right
        anchors.rightMargin: styler.themePaddingLarge
        anchors.top: numLabel.bottom
        color: "white"
        font.pixelSize: styler.themeFontSizeMedium
        height: text ? implicitHeight + 0*styler.themePaddingSmall: 0
        maximumLineCount: 1
        text: block.getstr("exit_name", "\n", 1)
        truncMode: truncModes.fade
        verticalAlignment: Text.AlignBottom
        width: text ? elementWidth() : 0
    }

    LabelPL {
        // Exit towards
        id: towardLabel
        anchors.right: parent.right
        anchors.rightMargin: styler.themePaddingLarge
        anchors.top: nameLabel.bottom
        color: "white"
        font.bold: true
        font.capitalization: Font.AllUppercase
        font.pixelSize: styler.themeFontSizeMedium
        height: text ? implicitHeight + 0*styler.themePaddingSmall: 0
        text: block.getstr("exit_toward", "\n", 3)
        truncMode: truncModes.fade
        verticalAlignment: Text.AlignBottom
        width: text ? elementWidth() : 0
    }

    LabelPL {
        // Exit branch
        id: branchLabel
        anchors.right: parent.right
        anchors.rightMargin: styler.themePaddingLarge
        anchors.top: towardLabel.bottom
        color: "white"
        font.bold: true
        font.pixelSize: styler.themeFontSizeMedium
        height: text ? implicitHeight + 0*styler.themePaddingSmall: 0
        text: block.getstr("exit_branch", " ", 2)
        truncMode: truncModes.fade
        verticalAlignment: Text.AlignBottom
        width: text ? Math.min(implicitWidth,elementWidth()) : 0
    }

    function elementWidth() {
        return block.width - 2*styler.themePaddingLarge;
    }

    function getstr(data_id, conn, maxnr) {
        if (!block.signActive || !block.sign || !block.sign[data_id]) return "";
        var data = block.sign[data_id];
        var s = "";
        for (var i in data) {
            if (maxnr!==undefined && i >= maxnr) return s;
            if (s != "") s += conn;
            s += data[i];
        }
        return s;
    }

}
