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
import "../qml"

Page {
    id: page
    allowedOrientations: app.defaultAllowedOrientations
    property bool loading: true
    property bool populated: false
    property var results: {}
    property string title: ""
    // Column widths to be set based on data.
    property int timeWidth: 0
    property int lineWidth: 0
    SilicaListView {
        id: listView
        anchors.fill: parent
        delegate: ListItem {
            id: listItem
            contentHeight: titleLabel.height + Theme.paddingMedium + bar.height +
                Theme.paddingMedium + repeater.height + finalLabel.height + Theme.paddingMedium
            property var result: page.results[model.alternative-1]
            Label {
                id: titleLabel
                anchors.left: parent.left
                anchors.leftMargin: Theme.horizontalPageMargin
                anchors.right: parent.right
                anchors.rightMargin: Theme.horizontalPageMargin
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeSmall
                height: implicitHeight + Theme.paddingMedium
                text: qsTranslate("", "Route %1. total %2")
                    .arg(listItem.result.alternative)
                    .arg(py.call_sync("poor.util.format_time", [listItem.result.duration]))
                verticalAlignment: Text.AlignBottom
            }
            Rectangle {
                id: bar
                anchors.left: parent.left
                anchors.leftMargin: Theme.horizontalPageMargin - 3*Theme.pixelRatio
                anchors.right: parent.right
                anchors.rightMargin: Theme.horizontalPageMargin - 3*Theme.pixelRatio
                anchors.top: titleLabel.bottom
                anchors.topMargin: Theme.paddingMedium
                color: "#00000000"
                height: 0.65*Theme.itemSizeSmall
            }
            Repeater {
                id: repeater
                anchors.top: bar.bottom
                anchors.topMargin: Theme.paddingMedium
                height: 0
                model: listItem.result.legs.length
                width: parent.width
                Item {
                    id: row
                    height: timeLabel.height
                    width: parent.width
                    property var leg: listItem.result.legs[index]
                    Rectangle {
                        id: barChunk
                        color: leg.color
                        height: bar.height
                        opacity: leg.mode === "WALK" ? 0.7 : 0.85
                        width: leg.duration/listItem.result.duration * bar.width - 3*Theme.pixelRatio
                        x: bar.x + (leg.dep_unix - listItem.result.legs[0].dep_unix) /
                            listItem.result.duration * bar.width + 3*Theme.pixelRatio
                        y: bar.y
                    }
                    Label {
                        id: barChunkLabel
                        height: barChunk.height
                        text: leg.line
                        verticalAlignment: Text.AlignVCenter
                        x: barChunk.x + Theme.paddingMedium
                        y: barChunk.y
                    }
                    Label {
                        id: timeLabel
                        height: implicitHeight + Theme.paddingSmall
                        horizontalAlignment: Text.AlignRight
                        text: leg.dep_time
                        verticalAlignment: Text.AlignVCenter
                        width: page.timeWidth
                        x: parent.x + Theme.horizontalPageMargin
                        y: repeater.y + index * row.height
                        Component.onCompleted: {
                            if (timeLabel.implicitWidth > page.timeWidth)
                                page.timeWidth = timeLabel.implicitWidth;
                        }
                    }
                    Label {
                        id: lineLabel
                        height: implicitHeight + Theme.paddingSmall
                        horizontalAlignment: Text.AlignRight
                        text: leg.line
                        verticalAlignment: Text.AlignVCenter
                        width: page.lineWidth
                        x: timeLabel.x + page.timeWidth + Theme.paddingMedium
                        y: repeater.y + index * row.height
                        Component.onCompleted: {
                            if (lineLabel.implicitWidth > page.lineWidth)
                                page.lineWidth = lineLabel.implicitWidth;
                        }
                    }
                    Label {
                        id: nameLabel
                        height: implicitHeight + Theme.paddingSmall
                        text: leg.mode === "WALK" ?
                            qsTranslate("", "Walk %1").arg(page.formatLength(leg.length)) :
                            qsTranslate("", "%1 → %2").arg(leg.dep_name).arg(leg.arr_name)
                        truncationMode: TruncationMode.Fade
                        verticalAlignment: Text.AlignVCenter
                        width: parent.width - x - Theme.horizontalPageMargin
                        x: lineLabel.x + page.lineWidth + Theme.paddingMedium
                        y: repeater.y + index * row.height
                    }
                    Component.onCompleted: {
                        repeater.height += row.height;
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
                x: parent.x + Theme.horizontalPageMargin
                Component.onCompleted: {
                    if (finalLabel.implicitWidth > page.timeWidth)
                        page.timeWidth = finalLabel.implicitWidth;
                }
            }
            onClicked: {
                app.hideMenu();
                map.addRoute({
                    "x": listItem.result.x,
                    "y": listItem.result.y,
                    "mode": "transit",
                    "attribution": qsTranslate("", "Routing courtesy of %1.").arg("Digitransit")
                });
                map.hidePoiBubbles();
                map.fitViewToRoute();
                map.addManeuvers(listItem.result.maneuvers);
            }
        }
        header: PageHeader { title: page.title }
        model: ListModel {}
        VerticalScrollDecorator {}
    }
    BusyModal {
        id: busy
        running: page.loading
    }
    onStatusChanged: {
        if (page.status === PageStatus.Activating) {
            if (page.populated) return;
            listView.model.clear();
            page.loading = true;
            page.title = "";
            busy.text = qsTranslate("", "Searching");
        } else if (page.status === PageStatus.Active) {
            listView.visible = true;
            if (page.populated) return;
            page.populate();
        } else if (page.status === PageStatus.Inactive) {
            listView.visible = false;
        }
    }
    function formatLength(length) {
        // Format length in meters to human-readable format.
        return py.call_sync("poor.util.format_distance", [length]);
    }
    function populate() {
        // Load routing results from the Python backend.
        var routePage = app.pageStack.previousPage();
        var args = [routePage.from, routePage.to, routePage.params];
        py.call("poor.app.router.route", args, function(results) {
            if (results && results.error && results.message) {
                page.title = "";
                busy.error = results.message;
            } else if (results && results.length > 0) {
                page.title = qsTranslate("", "Results");
                page.results = results;
                for (var i = 0; i < results.length; i++)
                    listView.model.append(results[i]);
            } else {
                page.title = "";
                busy.error = qsTranslate("", "No results");
            }
            page.loading = false;
            page.populated = true;
        });
    }
}
