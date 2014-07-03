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

Page {
    id: page
    allowedOrientations: Orientation.All
    property bool loading: true
    property var results: {}
    property string title: ""
    // Column widths to be set based on data.
    property int timeWidth: 0
    property int lineWidth: 0
    SilicaListView {
        anchors.fill: parent
        delegate: ListItem {
            id: listItem
            contentHeight: Theme.paddingLarge*2 +
                titleLabel.height + finalLabel.height
            property var result: page.results[model.alternative-1]
            Label {
                id: titleLabel
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingLarge
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingLarge
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeSmall
                height: implicitHeight + Theme.paddingLarge
                text: "Route " + listItem.result.alternative + ". total " +
                    Math.round(listItem.result.duration) + " min"
                verticalAlignment: Text.AlignVCenter
            }
            Repeater {
                id: repeater
                anchors.top: titleLabel.bottom
                height: 0
                model: listItem.result.legs.length
                width: parent.width
                Item {
                    id: row
                    height: timeLabel.height
                    width: parent.width
                    property var leg: listItem.result.legs[index]
                    Rectangle {
                        id: bar
                        color: leg.color
                        height: row.height
                        opacity: 0.6
                        width: (leg.duration/listItem.result.duration) * parent.width
                        x: ((leg.dep_unix - listItem.result.legs[0].dep_unix) /
                            listItem.result.duration) * parent.width
                        y: repeater.y + index * row.height
                    }
                    Label {
                        id: timeLabel
                        anchors.top: bar.top
                        height: implicitHeight + Theme.paddingSmall
                        horizontalAlignment: Text.AlignRight
                        text: leg.dep_time
                        verticalAlignment: Text.AlignVCenter
                        width: page.timeWidth
                        x: parent.x + Theme.paddingLarge
                        Component.onCompleted: {
                            if (timeLabel.implicitWidth > page.timeWidth)
                                page.timeWidth = timeLabel.implicitWidth;
                        }
                    }
                    Label {
                        id: lineLabel
                        anchors.top: bar.top
                        height: implicitHeight + Theme.paddingSmall
                        horizontalAlignment: Text.AlignRight
                        text: leg.line
                        verticalAlignment: Text.AlignVCenter
                        width: page.lineWidth
                        x: parent.x + Theme.paddingLarge +
                            page.timeWidth + Theme.paddingMedium
                        Component.onCompleted: {
                            if (lineLabel.implicitWidth > page.lineWidth)
                                page.lineWidth = lineLabel.implicitWidth;
                        }
                    }
                    Label {
                        id: nameLabel
                        anchors.top: bar.top
                        height: implicitHeight + Theme.paddingSmall
                        text: leg.mode == "walk" ?
                            "Walk " + page.formatLength(leg.length) :
                            leg.dep_name + " → " + leg.arr_name
                        truncationMode: TruncationMode.Fade
                        verticalAlignment: Text.AlignVCenter
                        x: parent.x + Theme.paddingLarge +
                            page.timeWidth + Theme.paddingMedium +
                            page.lineWidth + Theme.paddingMedium
                    }
                    Component.onCompleted: {
                        repeater.height += row.height;
                        listItem.contentHeight += row.height;
                    }
                }
            }
            Label {
                id: finalLabel
                anchors.top: repeater.bottom
                height: implicitHeight + Theme.paddingSmall
                horizontalAlignment: Text.AlignRight
                text: listItem.result.legs[listItem.result.legs.length-1].arr_time
                verticalAlignment: Text.AlignVCenter
                width: page.timeWidth
                x: parent.x + Theme.paddingLarge
                Component.onCompleted: {
                    if (finalLabel.implicitWidth > page.timeWidth)
                        page.timeWidth = finalLabel.implicitWidth;
                }
            }
            onClicked: {
                map.addRoute(listItem.result.x, listItem.result.y);
                map.fitViewToRoute();
                map.addManeuvers(listItem.result.maneuvers);
                app.pageStack.pop(mapPage, PageStackAction.Immediate);
            }
        }
        header: PageHeader { title: page.title }
        model: ListModel { id: listModel }
        VerticalScrollDecorator {}
    }
    Label {
        id: busyLabel
        anchors.bottom: busyIndicator.top
        color: Theme.highlightColor
        font.pixelSize: Theme.fontSizeLarge
        height: Theme.itemSizeLarge
        horizontalAlignment: Text.AlignHCenter
        text: "Searching"
        verticalAlignment: Text.AlignVCenter
        visible: page.loading || text != "Searching"
        width: parent.width
    }
    BusyIndicator {
        id: busyIndicator
        anchors.centerIn: parent
        running: page.loading
        size: BusyIndicatorSize.Large
        visible: page.loading
    }
    onStatusChanged: {
        if (page.status == PageStatus.Activating) {
            page.loading = true;
            busyLabel.text = "Searching"
        } else if (page.status == PageStatus.Active) {
            page.populate();
        } else if (page.status == PageStatus.Inactive) {
            listModel.clear();
            page.title = ""
        }
    }
    function formatLength(length) {
        // Format length in meters to human-readable format.
        return py.call_sync("poor.util.format_distance", [length, 2, "m"]);
    }
    function populate() {
        // Load routing results from the Python backend.
        var routePage = app.pageStack.previousPage();
        var args = [routePage.from, routePage.to, routePage.params];
        py.call("poor.app.router.route", args, function(results) {
            if (results && results.length > 0) {
                page.title = "Results";
                page.results = results;
                for (var i = 0; i < results.length; i++)
                    listModel.append(results[i]);
            } else {
                page.title = "";
                busyLabel.text = "No route found"
            }
            page.loading = false;
        });
    }
}
