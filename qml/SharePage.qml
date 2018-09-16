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
    allowedOrientations: app.defaultAllowedOrientations

    // Required to be set by caller.
    property var    coordinate: undefined
    property string title: ""

    PageHeader {
        id: header
        title: page.title
    }

    ListItemLabel {
        id: messageLabel
        anchors.top: header.bottom
        anchors.topMargin: Theme.paddingLarge
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
        anchors.topMargin: 2 * Theme.paddingLarge
        text: app.tr("SMS")
        onClicked: {
            // XXX: SMS links don't work without a recipient.
            // https://together.jolla.com/question/84134/
            Clipboard.text = page.formatMessage(false);
            infoLabel.text = [
                app.tr("Message copied to the clipboard"),
                app.tr("Launching the Messages application"),
            ].join("\n");
            py.call("poor.util.popen", [
                "/usr/bin/invoker",
                "--type=silica-qt5",
                "/usr/bin/jolla-messages",
            ], null);
        }
    }

    Button {
        id: emailButton
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: smsButton.bottom
        anchors.topMargin: Theme.paddingLarge
        text: app.tr("Email")
        onClicked: {
            var link = "mailto:?body=%1".arg(page.formatMessage(false));
            infoLabel.text = app.tr("Launching the Email application");
            Qt.openUrlExternally(link);
        }
    }

    Button {
        id: clipboardButton
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: emailButton.bottom
        anchors.topMargin: Theme.paddingLarge
        text: app.tr("Other")
        onClicked: {
            Clipboard.text = page.formatMessage(false);
            infoLabel.text = app.tr("Message copied to the clipboard");
        }
    }

    ListItemLabel {
        id: infoLabel
        anchors.top: clipboardButton.bottom
        anchors.topMargin: 2 * Theme.paddingLarge
        color: Theme.highlightColor
        horizontalAlignment: Text.AlignHCenter
    }

    TextSwitch {
        id: shareOsmSwitch
        anchors.top: infoLabel.bottom
        anchors.topMargin: 2 * Theme.paddingLarge
        checked: app.conf.get("share_osm")
        text: app.tr("Add link to OpenStreetMaps")
        onCheckedChanged: {
            app.conf.set("share_osm", shareOsmSwitch.checked);
        }
    }

    TextSwitch {
        id: shareGoogleSwitch
        anchors.top: shareOsmSwitch.bottom
        anchors.topMargin: Theme.paddingMedium
        checked: app.conf.get("share_googlemaps")
        text: app.tr("Add link to Google Maps")
        onCheckedChanged: {
            app.conf.set("share_googlemaps", shareGoogleSwitch.checked);
        }
    }

    function formatMessage(html) {
        return py.call_sync("poor.util.format_location_message", [
            page.coordinate.longitude,
            page.coordinate.latitude,
            html,
            shareOsmSwitch.checked,
            shareGoogleSwitch.checked,
        ]);
    }

}
