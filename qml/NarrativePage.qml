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
            contentHeight: iconImage.height
            Image {
                id: iconImage
                anchors.left: parent.left
                fillMode: Image.Pad
                height: 2*Theme.paddingMedium + Math.max(
                    implicitHeight, narrativeLabel.implicitHeight +
                        lengthLabel.implicitHeight)
                horizontalAlignment: Image.AlignRight
                source: "icons/%1.png".arg(model.icon)
                verticalAlignment: Image.AlignVCenter
                width: implicitWidth + Theme.paddingLarge
            }
            Label {
                id: narrativeLabel
                anchors.left: iconImage.right
                anchors.leftMargin: Theme.paddingLarge
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingLarge
                color: (model.active || listItem.highlighted) ?
                    Theme.highlightColor : Theme.primaryColor
                font.pixelSize: Theme.fontSizeSmall
                height: implicitHeight + (iconImage.height -
                    implicitHeight - lengthLabel.implicitHeight) / 2
                text: model.narrative
                verticalAlignment: Text.AlignBottom
                wrapMode: Text.WordWrap
            }
            Label {
                id: lengthLabel
                anchors.left: iconImage.right
                anchors.leftMargin: Theme.paddingLarge
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingLarge
                anchors.top: narrativeLabel.bottom
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeSmall
                height: implicitHeight + (iconImage.height -
                    implicitHeight - narrativeLabel.implicitHeight) / 2
                text: model.index < listView.count-1 ?
                    "Continue for %1.".arg(model.length) :
                    map.route.attribution
                verticalAlignment: Text.AlignTop
            }
            onClicked: {
                map.autoCenter = false;
                map.setCenter(model.x, model.y);
                map.zoomLevel < 16 && map.setZoomLevel(16);
                app.clearMenu();
            }
        }
        header: Column {
            height: header.height + row.height + Theme.paddingLarge
            width: parent.width
            PageHeader {
                id: header
                title: "Navigation"
            }
            Row {
                id: row
                height: Theme.itemSizeSmall
                width: parent.width
                ListItem {
                    id: beginItem
                    contentHeight: Theme.itemSizeSmall
                    width: parent.width/3
                    Rectangle {
                        anchors.fill: parent
                        color: Theme.highlightColor
                        opacity: 0.1
                    }
                    ListItemLabel {
                        id: beginLabel
                        anchors.fill: parent
                        anchors.leftMargin: Theme.paddingLarge
                        anchors.rightMargin: Theme.paddingLarge
                        color: beginItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                        height: Theme.itemSizeSmall
                        horizontalAlignment: Text.AlignHCenter
                        text: "Begin"
                    }
                    onClicked: {
                        map.beginNavigating();
                        app.clearMenu();
                    }
                }
                ListItem {
                    id: pauseItem
                    contentHeight: Theme.itemSizeSmall
                    width: parent.width/3
                    Rectangle {
                        anchors.fill: parent
                        color: Theme.highlightColor
                        opacity: 0.1
                    }
                    ListItemLabel {
                        id: pauseLabel
                        anchors.fill: parent
                        anchors.leftMargin: Theme.paddingLarge
                        anchors.rightMargin: Theme.paddingLarge
                        color: pauseItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                        height: Theme.itemSizeSmall
                        horizontalAlignment: Text.AlignHCenter
                        text: "Pause"
                    }
                    onClicked: {
                        map.endNavigating();
                        app.clearMenu();
                    }
                }
                ListItem {
                    id: clearItem
                    contentHeight: Theme.itemSizeSmall
                    width: parent.width/3
                    Rectangle {
                        anchors.fill: parent
                        color: Theme.highlightColor
                        opacity: 0.1
                    }
                    ListItemLabel {
                        id: clearLabel
                        anchors.fill: parent
                        anchors.leftMargin: Theme.paddingLarge
                        anchors.rightMargin: Theme.paddingLarge
                        color: clearItem.highlighted ? Theme.highlightColor : Theme.primaryColor
                        height: Theme.itemSizeSmall
                        horizontalAlignment: Text.AlignHCenter
                        text: "Clear"
                    }
                    onClicked: {
                        map.endNavigating();
                        map.clearRoute();
                        app.clearMenu();
                    }
                }
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
            // the user can see the begin, pause and end buttons. On later
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
            for (var i = 0; i < maneuvers.length; i++)
                listView.model.append(maneuvers[i]);
        });
    }
    function scrollToActive() {
        // Scroll view to the active maneuver.
        for (var i = 0; i < listView.model.count; i++) {
            if (!listView.model.get(i).active) continue;
            listView.positionViewAtIndex(i, ListView.Center);
        }
    }
}
