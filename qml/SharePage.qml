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
import "."
import "platform"

PagePL {
    id: page

    Column {
        spacing: styler.themePaddingLarge
        width: page.width

        ListItemLabel {
            id: messageLabel
            horizontalAlignment: Text.AlignHCenter
            lineHeight: 1.15
            linkColor: styler.themeHighlightColor
            text: page.formatMessage(true);
            truncMode: truncModes.none
            wrapMode: TextEdit.Wrap
            onLinkActivated: Qt.openUrlExternally(link);
        }

        Spacer {
            height: styler.themePaddingLarge
        }

        ButtonPL {
            id: smsButton
            anchors.horizontalCenter: parent.horizontalCenter
            text: app.tr("SMS")
            onClicked: {
                var m = app.sendSms(page.formatMessage(false));
                if (m) {
                    var msgs = [
                                app.tr("Launching the Messages application"),
                                app.tr("Message copied to the clipboard")
                            ];
                    infoLabel.text =
                            m.map(function (i) { return msgs[i]; }).join('\n');
                } else
                    infoLabel.text = app.tr("Error sending message");
            }
        }

        ButtonPL {
            id: emailButton
            anchors.horizontalCenter: parent.horizontalCenter
            text: app.tr("Email")
            onClicked: {
                var link = "mailto:?body=%1".arg(page.formatMessage(false));
                infoLabel.text = app.tr("Launching the Email application");
                Qt.openUrlExternally(link);
            }
        }

        ButtonPL {
            id: clipboardButton
            anchors.horizontalCenter: parent.horizontalCenter
            text: app.tr("Other")
            onClicked: {
                clipboard.copy(page.formatMessage(false));
                infoLabel.text = app.tr("Message copied to the clipboard");
            }
        }

        Spacer {
            height: styler.themePaddingLarge
        }

        ListItemLabel {
            id: infoLabel
            color: styler.themeHighlightColor
            horizontalAlignment: Text.AlignHCenter
        }

        TextSwitchPL {
            id: shareAddressSwitch
            checked: app.conf.get("share_address")
            text: app.tr("Add address")
            onCheckedChanged: {
                app.conf.set("share_address", checked);
            }
        }

        TextSwitchPL {
            id: shareOsmSwitch
            checked: app.conf.get("share_osm")
            text: app.tr("Add link to OpenStreetMaps")
            onCheckedChanged: {
                app.conf.set("share_osm", checked);
            }
        }

        TextSwitchPL {
            id: shareGoogleSwitch
            checked: app.conf.get("share_googlemaps")
            text: app.tr("Add link to Google Maps")
            onCheckedChanged: {
                app.conf.set("share_googlemaps", checked);
            }
        }

        Component.onCompleted: {
            page.shareAddressSwitch = shareAddressSwitch;
            page.shareOsmSwitch = shareOsmSwitch;
            page.shareGoogleSwitch = shareGoogleSwitch;
        }
    }

    // Required to be set by caller.
    property var coordinate: undefined
    property var poi: undefined

    property var shareAddressSwitch: undefined
    property var shareOsmSwitch: undefined
    property var shareGoogleSwitch: undefined

    function formatMessage(html) {
        return py.call_sync("poor.util.format_location_message", [
                                page.coordinate.longitude,
                                page.coordinate.latitude,
                                poi && poi.address ? poi.address : title,
                                html,
                                shareAddressSwitch.checked,
                                shareOsmSwitch.checked,
                                shareGoogleSwitch.checked,
                            ]);
    }

}
