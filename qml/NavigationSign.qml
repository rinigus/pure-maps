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
import Sailfish.Silica 1.0

Rectangle {
    id: block
    anchors.right: parent.right
    anchors.rightMargin: -Theme.paddingMedium
    anchors.top: app.navigationBlock.bottom
    anchors.topMargin: Theme.paddingSmall
    color: "#3768B7"
    height: {
        if (!app.showNavigationSign) return 0;
        var h1 = numLabel.height;
        var h2 = nameLabel.height;
        var h3 = towardLabel.height;
        var h4 = branchLabel.height;
        var h = h1 + h2 + h3 + h4;
        if (h) return h + 2*Theme.paddingMedium;
        return 0;
    }
    radius: Theme.paddingMedium
    visible: app.showNavigationSign
    width: {
        if (!app.showNavigationSign) return 0;
        var w1 = numLabel.text ? numLabel.width + exitLabel.width + Theme.paddingSmall : 0;
        var w2 = nameLabel.implicitWidth;
        var w3 = towardLabel.implicitWidth;
        var w4 = branchLabel.implicitWidth;
        var w  = Math.max(w1, Math.min(parent.width/3, Math.max(w2, w3, w4)));
        if (w) return w + 2*Theme.paddingLarge;
        return 0;
    }
    z: 500

    property var    sign:   app.navigationStatus.sign
    property var    street: app.navigationStatus.street
    property bool   signActive: app.navigationActive && sign!=null && (sign.exit_number!=null || sign.exit_name!=null || sign.exit_toward!=null || sign.exit_branch!=null)

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

    function elementWidth() {
        return block.width - 2*Theme.paddingLarge;
    }

    Rectangle {
        id: signBorder
        anchors.fill: parent
        anchors.margins: Theme.paddingSmall/2
        border.color: "white"
        border.width: Theme.paddingSmall/2
        color: "transparent"
        radius: Theme.paddingMedium
    }
    
    Label {
        // Exit number
        id: numLabel
        anchors.right: parent.right
        anchors.rightMargin: Theme.paddingLarge
        anchors.top: parent.top
        anchors.topMargin: block.signActive ? Theme.paddingMedium : 0
        color: "white"
        font.bold: true
        font.pixelSize: Theme.fontSizeLarge
        height: text ? implicitHeight + 0*Theme.paddingSmall: 0
        text: block.getstr("exit_number", " ")
        verticalAlignment: Text.AlignBottom
        width: text ? implicitWidth : 0
    }

    Label {
        // Word "Exit"
        id: exitLabel
        anchors.baseline: numLabel.baseline
        anchors.right: numLabel.left
        anchors.rightMargin: Theme.paddingSmall
        color: "white"
        height: numLabel.text ? implicitHeight : 0
        font.pixelSize: Theme.fontSizeMedium
        text: app.tr("EXIT")
        visible: numLabel.text
        width: numLabel.text ? implicitWidth : 0
    }

    Label {
        // Exit name
        id: nameLabel
        anchors.right: parent.right
        anchors.rightMargin: Theme.paddingLarge
        anchors.top: numLabel.bottom
        color: "white"
        font.pixelSize: Theme.fontSizeMedium
        height: text ? implicitHeight + 0*Theme.paddingSmall: 0
        maximumLineCount: 1
        text: block.getstr("exit_name", "\n", 1)
        truncationMode: TruncationMode.Fade
        verticalAlignment: Text.AlignBottom
        width: text ? elementWidth() : 0
    }

    Label {
        // Exit towards
        id: towardLabel
        anchors.right: parent.right
        anchors.rightMargin: Theme.paddingLarge
        anchors.top: nameLabel.bottom
        color: "white"
        font.bold: true
        font.capitalization: Font.AllUppercase
        font.pixelSize: Theme.fontSizeMedium
        height: text ? implicitHeight + 0*Theme.paddingSmall: 0
        text: block.getstr("exit_toward", "\n", 3)
        truncationMode: TruncationMode.Fade
        verticalAlignment: Text.AlignBottom
        width: text ? elementWidth() : 0
    }

    Label {
        // Exit branch
        id: branchLabel
        anchors.right: parent.right
        anchors.rightMargin: Theme.paddingLarge
        anchors.top: towardLabel.bottom
        color: "white"
        font.bold: true
        font.pixelSize: Theme.fontSizeMedium
        height: text ? implicitHeight + 0*Theme.paddingSmall: 0
        text: block.getstr("exit_branch", " ", 2)
        truncationMode: TruncationMode.Fade
        verticalAlignment: Text.AlignBottom
        width: text ? Math.min(implicitWidth,elementWidth()) : 0
    }

}
