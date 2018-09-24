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

    property bool partOfNavigationStack: true

    SilicaListView {
        id: listView
        anchors.fill: parent
        // Prevent list items from stealing focus.
        currentIndex: -1

        delegate: ListItem {
            id: listItem
            contentHeight: narrativeLabel.height + departLabel.height + arriveLabel.height + lengthLabel.height + 2.0*Theme.paddingLarge

            Image {
                id: icon
                anchors.left: parent.left
                anchors.leftMargin: Theme.horizontalPageMargin
                anchors.top: spacer.bottom
                fillMode: Image.Pad
                height: narrativeLabel.height + departLabel.height + arriveLabel.height + lengthLabel.height
                horizontalAlignment: Image.AlignRight
                opacity: 0.9
                smooth: true
                source: "icons/navigation/%1.svg".arg(model.icon)
                sourceSize.height: Theme.iconSizeMedium
                sourceSize.width: Theme.iconSizeMedium
                verticalAlignment: Image.AlignTop
            }

            Spacer {
                id: spacer
                height: Theme.paddingLarge
            }

            Label {
                id: narrativeLabel
                anchors.left: icon.right
                anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.rightMargin: Theme.horizontalPageMargin
                anchors.top: spacer.bottom
                color: (model.active || listItem.highlighted) ?
                    Theme.highlightColor : Theme.primaryColor
                font.pixelSize: Theme.fontSizeSmall
                height: implicitHeight + Theme.paddingSmall
                text: model.narrative
                verticalAlignment: Text.AlignTop
                wrapMode: Text.WordWrap
            }

            Label {
                id: departLabel
                anchors.left: icon.right
                anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.rightMargin: Theme.horizontalPageMargin
                anchors.top: narrativeLabel.bottom
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
                height: text ? implicitHeight + Theme.paddingSmall : 0
                text: model.depart_instruction ? model.depart_instruction : ""
                verticalAlignment: Text.AlignTop
                wrapMode: Text.WordWrap
            }

            Label {
                id: arriveLabel
                anchors.left: icon.right
                anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.rightMargin: Theme.horizontalPageMargin
                anchors.top: departLabel.bottom
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
                height: text ? implicitHeight + Theme.paddingSmall : 0
                text: model.arrive_instruction ? model.arrive_instruction : ""
                verticalAlignment: Text.AlignTop
                wrapMode: Text.WordWrap
            }

            Label {
                id: lengthLabel
                anchors.left: icon.right
                anchors.leftMargin: Theme.paddingMedium
                anchors.right: parent.right
                anchors.rightMargin: Theme.horizontalPageMargin
                anchors.top: arriveLabel.bottom
                anchors.topMargin: Theme.paddingSmall
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
                height: implicitHeight + Theme.paddingSmall
                lineHeight: 1.15
                text: model.index < listView.count - 1 ?
                    app.tr("Continue for %1.", model.length) : ""
                truncationMode: TruncationMode.Fade
                verticalAlignment: Text.AlignTop
            }

            onClicked: {
                app.setModeExplore();
                map.setCenter(model.x, model.y);
                map.zoomLevel < 15 && map.setZoomLevel(15);
                app.hideNavigationPages();
            }

        }

        footer: Spacer {
            height: Theme.paddingMedium
        }

        header: PageHeader {
            title: app.tr("Maneuvers")
        }

        model: ListModel {}

        VerticalScrollDecorator {}

    }

    onStatusChanged: {
        if (page.status === PageStatus.Activating)
            page.populate();
    }

    function populate() {
        // Load narrative from the Python backend.
        listView.model.clear();
        var args = [map.center.longitude, map.center.latitude];
        py.call("poor.app.narrative.get_maneuvers", args, function(maneuvers) {
            Util.appendAll(listView.model, maneuvers);
            app.narrativePageSeen && page.scrollToActive();
            app.narrativePageSeen = true;
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
