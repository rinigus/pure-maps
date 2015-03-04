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
import Sailfish.Silica 1.0
import "."

Page {
    id: page
    allowedOrientations: Orientation.Portrait
    // Required to be set by caller.
    property var coordinate
    property string title
    PageHeader {
        id: header
        title: page.title
    }
    ListItemLabel {
        id: messageLabel
        anchors.leftMargin: 3*Theme.paddingLarge
        anchors.rightMargin: 3*Theme.paddingLarge
        anchors.top: header.bottom
        anchors.topMargin: Theme.paddingLarge
        font.pixelSize: Theme.fontSizeMedium
        horizontalAlignment: Text.AlignHCenter
        lineHeight: 1.15
        linkColor: Theme.highlightColor
        text: page.formatMessage(true);
        wrapMode: TextEdit.Wrap
        onLinkActivated: Qt.openUrlExternally(link);
    }
    Button {
        id: smsButton
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: messageLabel.bottom
        anchors.topMargin: 2*Theme.paddingLarge
        text: "SMS"
        onClicked: {
            // XXX: SMS links don't work without a recipient.
            // http://together.jolla.com/question/84134/
            Clipboard.text = page.formatMessage(false);
            infoLabel.text = "Message copied to the clipboard\nLaunching the Messages application";
            var args = ["/usr/bin/invoker", "--type=silica-qt5", "/usr/bin/jolla-messages"];
            py.call("poor.util.popen", args, null);
        }
    }
    Button {
        id: emailButton
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: smsButton.bottom
        anchors.topMargin: Theme.paddingLarge
        text: "Email"
        onClicked: {
            var link = "mailto:?body=" + page.formatMessage(false);
            infoLabel.text = "Launching the Email application";
            Qt.openUrlExternally(link);
        }
    }
    Button {
        id: clipboardButton
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: emailButton.bottom
        anchors.topMargin: Theme.paddingLarge
        text: "Other"
        onClicked: {
            Clipboard.text = page.formatMessage(false);
            infoLabel.text = "Message copied to the clipboard";
        }
    }
    ListItemLabel {
        id: infoLabel
        anchors.top: clipboardButton.bottom
        anchors.topMargin: 2*Theme.paddingLarge
        color: Theme.highlightColor
        horizontalAlignment: Text.AlignHCenter
    }
    function formatMessage(html) {
        return py.call_sync("poor.util.format_location_message",
                            [page.coordinate.longitude,
                             page.coordinate.latitude,
                             html]);

    }
}
