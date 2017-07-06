/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2014 Osmo Salomaa
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

import "js/util.js" as Util

Page {
    id: page
    allowedOrientations: app.defaultAllowedOrientations

    SilicaListView {
        id: listView
        anchors.fill: parent
        // Prevent list items from stealing focus.
        currentIndex: -1

        delegate: ListItem {
            id: listItem
            contentHeight: narrativeLabel.implicitHeight + Theme.paddingMedium +
                lengthLabel.implicitHeight + Theme.paddingMedium

            Image {
                id: icon
                anchors.left: parent.left
                anchors.leftMargin: Theme.horizontalPageMargin
                fillMode: Image.Pad
                height: narrativeLabel.implicitHeight + Theme.paddingMedium +
                    lengthLabel.implicitHeight + Theme.paddingMedium
                horizontalAlignment: Image.AlignRight
                opacity: 0.9
                smooth: true
                source: "icons/navigation/%1.svg".arg(model.icon)
                sourceSize.height: Theme.iconSizeMedium
                sourceSize.width: Theme.iconSizeMedium
                verticalAlignment: Image.AlignVCenter
            }

            Label {
                id: narrativeLabel
                anchors.left: icon.right
                anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.rightMargin: Theme.horizontalPageMargin
                color: (model.active || listItem.highlighted) ?
                    Theme.highlightColor : Theme.primaryColor
                font.pixelSize: Theme.fontSizeSmall
                height: implicitHeight + Theme.paddingMedium
                text: model.narrative
                verticalAlignment: Text.AlignBottom
                wrapMode: Text.WordWrap
            }

            Label {
                id: lengthLabel
                anchors.left: icon.right
                anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.rightMargin: Theme.horizontalPageMargin
                anchors.top: narrativeLabel.bottom
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
                height: implicitHeight + Theme.paddingMedium
                text: model.index < listView.count - 1 ?
                    app.tr("Continue for %1.", model.length) : map.route.attribution
                truncationMode: TruncationMode.Fade
                verticalAlignment: Text.AlignTop
            }

            onClicked: {
                map.autoCenter = false;
                map.setCenter(model.x, model.y);
                map.zoomLevel < 16 && map.setZoomLevel(16);
                app.clearMenu();
            }

        }

        footer: Spacer {
            height: Theme.paddingMedium
        }

        header: Column {
            height: header.height + row.height + spacer1.height +
                distItem.height + timeItem.height + spacer2.height
            width: parent.width

            PageHeader {
                id: header
                title: app.tr("Navigation")
            }

            Row {
                id: row
                height: Theme.itemSizeSmall
                width: parent.width
                property int count: 3
                ToolItem {
                    text: app.tr("Begin")
                    onClicked: {
                        map.beginNavigating();
                        app.clearMenu();
                    }
                }
                ToolItem {
                    text: app.tr("Pause")
                    onClicked: {
                        map.endNavigating();
                        app.clearMenu();
                    }
                }
                ToolItem {
                    text: app.tr("Clear")
                    onClicked: {
                        map.endNavigating();
                        map.clearRoute();
                        app.clearMenu();
                    }
                }
            }

            Spacer {
                id: spacer1
                height: Theme.paddingLarge
            }

            DetailItem {
                id: distItem
                label: app.tr("Distance remaining")
                value: app.navigationStatus ? "%1 / %2"
                    .arg(app.navigationStatus.dest_dist || "?")
                    .arg(app.navigationStatus.total_dist || "?") : ""
            }

            DetailItem {
                id: timeItem
                label: app.tr("Time remaining")
                value: app.navigationStatus ? "%1 / %2"
                    .arg(timeItem.format(app.navigationStatus.dest_time || "?"))
                    .arg(timeItem.format(app.navigationStatus.total_time || "?")) : ""
                function format(time) {
                    // For long time strings on small screens, shorten unit labels
                    // to single characters to hopefully fit on one line. Note that
                    // time strings are translatable. In English this shortens
                    // "# h # min" to "# h # m".
                    return (Screen.sizeCategory < Screen.Large &&
                            time.match(/^\d+ *[^\d ]+ *\d+ *[^\d ]+$/)) ?
                        time.replace(/([^\d ])[^\d ]+/, "$1") : time;
                }
            }

            Spacer {
                id: spacer2
                height: Theme.paddingLarge - Theme.paddingMedium
            }

        }

        model: ListModel {}

        VerticalScrollDecorator {}

    }

    onStatusChanged: {
        if (page.status === PageStatus.Activating) {
            listView.visible = false;
            page.populate();
        } else if (page.status === PageStatus.Active) {
            // On first time showing maneuvers, start at the top so that
            // the user can see the begin, pause and clear buttons. On later
            // views, scroll to the maneuver closest to the screen center,
            // allowing the user to tap through the maneuvers.
            app.narrativePageSeen && page.scrollToActive();
            app.narrativePageSeen = true;
            listView.visible = true;
        }
    }

    function populate() {
        // Load narrative from the Python backend.
        var args = [map.center.longitude, map.center.latitude];
        py.call("poor.app.narrative.get_maneuvers", args, function(maneuvers) {
            Util.appendAll(listView.model, maneuvers);
        });
    }

    function scrollToActive() {
        // Scroll view to the active maneuver.
        for (var i = 0; i < listView.model.count; i++) {
            listView.model.get(i).active &&
                listView.positionViewAtIndex(i, ListView.Center);
        }
    }

}
