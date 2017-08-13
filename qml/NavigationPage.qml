/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2017 Osmo Salomaa
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

    property bool partOfNavigationStack: true

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.implicitHeight
        contentWidth: parent.width

        Column {
            id: column
            anchors.fill: parent

            PageHeader {
                title: app.tr("Navigation")
            }

            Row {
                id: row
                height: startItem.height
                width: parent.width

                property real contentWidth: width - 2 * Theme.horizontalPageMargin
                property real itemWidth: contentWidth / 3

                ToolItem {
                    id: startItem
                    width: row.itemWidth + Theme.horizontalPageMargin
                    icon: app.navigationActive ? "image://theme/icon-m-pause" : "image://theme/icon-m-play"
                    text: app.navigationActive ? app.tr("Pause") :
                        (app.navigationStarted ? app.tr("Resume") : app.tr("Begin"))
                    onClicked: {
                        app.navigationActive ? map.endNavigating() : map.beginNavigating();
                        app.hideMenu();
                    }
                }

                ToolItem {
                    id: rerouteItem
                    width: row.itemWidth
                    icon: "image://theme/icon-m-refresh"
                    text: app.tr("Reroute")
                    onClicked: {
                        app.reroute();
                        map.beginNavigating();
                        app.hideMenu();
                    }
                }

                ToolItem {
                    id: clearItem
                    width: row.itemWidth + Theme.horizontalPageMargin
                    icon: "image://theme/icon-m-clear"
                    text: app.tr("Clear")
                    onClicked: {
                        map.endNavigating();
                        map.clearRoute();
                        app.hideMenu();
                    }
                }

            }

            SectionHeader {
                text: app.tr("Status")
            }

            Spacer {
                height: Theme.paddingLarge
            }

            Item {
                id: progress
                anchors.left: parent.left
                anchors.right: parent.right
                height: Theme.paddingSmall
                Rectangle {
                    id: progressTotal
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.horizontalPageMargin
                    anchors.right: parent.right
                    anchors.rightMargin: Theme.horizontalPageMargin
                    color: Theme.primaryColor
                    height: Theme.paddingSmall
                    opacity: 0.15
                    radius: height / 2
                }
                Rectangle {
                    id: progressComplete
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.horizontalPageMargin
                    color: Theme.highlightColor
                    height: Theme.paddingSmall
                    radius: height / 2
                    width: (app.navigationStatus &&
                            app.navigationStatus.progress ||
                            0) * progressTotal.width

                }
            }

            Spacer {
                height: Theme.paddingLarge + Theme.paddingSmall
            }

            Item {
                anchors.left: parent.left
                anchors.right: parent.right
                height: Theme.itemSizeExtraSmall
                ListItemLabel {
                    font.pixelSize: Theme.fontSizeSmall
                    height: Theme.itemSizeExtraSmall
                    text: app.navigationStatus ? app.tr("%1 remaining")
                        .arg(app.navigationStatus.dest_dist || "?") : ""
                }
                ListItemLabel {
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeSmall
                    height: Theme.itemSizeExtraSmall
                    horizontalAlignment: Text.AlignRight
                    text: app.navigationStatus ? app.tr("total %1")
                        .arg(app.navigationStatus.total_dist || "?") : ""
                }
            }

            Item {
                anchors.left: parent.left
                anchors.right: parent.right
                height: Theme.itemSizeExtraSmall
                ListItemLabel {
                    font.pixelSize: Theme.fontSizeSmall
                    height: Theme.itemSizeExtraSmall
                    text: app.navigationStatus ? app.tr("%1 remaining")
                        .arg(app.navigationStatus.dest_time || "?") : ""
                }
                ListItemLabel {
                    color: Theme.secondaryColor
                    font.pixelSize: Theme.fontSizeSmall
                    height: Theme.itemSizeExtraSmall
                    horizontalAlignment: Text.AlignRight
                    text: app.navigationStatus ? app.tr("total %1")
                        .arg(app.navigationStatus.total_time || "?") : ""
                }
            }

            SectionHeader {
                text: app.tr("Options")
            }

            TextSwitch {
                id: rerouteSwitch
                checked: enabled && app.conf.get("reroute")
                enabled: map.route.mode === "car"
                text: app.tr("Reroute automatically")
                onCheckedChanged: enabled && app.conf.set("reroute", rerouteSwitch.checked);
            }

            Spacer {
                height: Theme.paddingMedium
            }

        }

        VerticalScrollDecorator {}

    }

    onStatusChanged: {
        if (page.status === PageStatus.Active)
            app.navigationPageSeen = true;
    }

}
