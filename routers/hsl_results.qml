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
    SilicaListView {
        anchors.fill: parent
        delegate: ListItem {
            id: listItem
            contentHeight: titleLabel.height + finalLabel.height +
                Theme.paddingLarge
            property var result: page.results[model.alternative-1]
            Label {
                id: titleLabel
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingLarge
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingLarge
                color: Theme.highlightColor
                height: Theme.itemSizeSmall
                text: "Route " + listItem.result.alternative + ". total " +
                    Math.round(listItem.result.duration) + " min"
                truncationMode: TruncationMode.Fade
                verticalAlignment: Text.AlignVCenter
            }
            Repeater {
                id: repeater
                anchors.top: titleLabel.bottom
                height: 0
                model: listItem.result.legs.length
                width: parent.width
                Item {
                    id: item
                    height: legLabel.height
                    width: parent.width
                    property var leg: listItem.result.legs[index]
                    Rectangle {
                        id: bar
                        color: {"bus":   "#007AC9",
                                "ferry": "#00B9E4",
                                "metro": "#FF6319",
                                "train": "#2DBE2C",
                                "tram":  "#00985f",
                                "walk":  "#888888"}[leg.mode]

                        height: item.height
                        opacity: 0.7
                        width: (leg.duration/listItem.result.duration) * parent.width
                        x: (leg.dep_unix - listItem.result.legs[0].dep_unix) /
                            listItem.result.duration * parent.width
                        y: repeater.y + index * item.height
                    }
                    Label {
                        id: legLabel
                        anchors.left: parent.left
                        anchors.leftMargin: Theme.paddingLarge
                        anchors.right: parent.right
                        anchors.rightMargin: Theme.paddingLarge
                        anchors.top: bar.top
                        color: leg.mode == "walk" ?
                            Theme.secondaryColor : Theme.primaryColor
                        height: implicitHeight + Theme.paddingSmall
                        text: leg.dep_time + "   " +
                            (leg.mode == "walk" ? "Walk" : leg.line) +
                            " from " + leg.dep_name
                        truncationMode: TruncationMode.Fade
                        verticalAlignment: Text.AlignVCenter
                    }
                    Component.onCompleted: {
                        repeater.height += item.height;
                        listItem.contentHeight += item.height;
                    }
                }
            }
            Label {
                id: finalLabel
                anchors.left: parent.left
                anchors.leftMargin: Theme.paddingLarge
                anchors.right: parent.right
                anchors.rightMargin: Theme.paddingLarge
                anchors.top: repeater.bottom
                color: Theme.secondaryColor
                height: implicitHeight
                text: listItem.result.legs[listItem.result.legs.length-1].arr_time
                truncationMode: TruncationMode.Fade
                verticalAlignment: Text.AlignVCenter
            }
            onClicked: {
                map.addRoute(listItem.result.x, listItem.result.y);
                map.fitViewToRoute();
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
            page.populate(app.pageStack.previousPage());
        } else if (page.status == PageStatus.Inactive) {
            listModel.clear();
            page.title = ""
        }
    }
    function populate(routePage) {
        // Load routing results from the Python backend.
        py.call("poor.app.router.route",
                [routePage.from, routePage.to, routePage.params],
                function(results) {
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
