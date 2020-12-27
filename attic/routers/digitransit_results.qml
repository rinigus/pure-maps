/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2014 Osmo Salomaa, 2019 Rinigus, 2019 Purism SPC
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
import "../qml"
import "../qml/platform"

import "../qml/js/util.js" as Util

PagePL {
    id: page

    property bool   loading: true
    property bool   populated: false
    property var    results: {}
    property string toText

    // Column widths to be set based on data.
    property int timeWidth: 0
    property int lineWidth: 0

    Column {
        spacing: styler.themePaddingLarge
        width: page.width

        /*
         * Single alternative route
         */

        Repeater {
            id: mainList
            delegate: ListItemPL {
                id: listItem
                contentHeight: titleLabel.height + styler.themePaddingMedium + bar.height +
                               styler.themePaddingMedium + repeater.height + finalLabel.height + styler.themePaddingMedium

                property real barGap: Math.round(3 * styler.themePixelRatio)
                property real barMargin: styler.themeHorizontalPageMargin - barGap
                property var  result: page.results[model.alternative-1]

                ListItemLabel {
                    id: titleLabel
                    color: styler.themeHighlightColor
                    font.pixelSize: styler.themeFontSizeSmall
                    height: implicitHeight + styler.themePaddingMedium
                    text: app.tr("Route %1. total %2",
                                 listItem.result.alternative,
                                 py.call_sync("poor.util.format_time",
                                              [listItem.result.duration]))

                    verticalAlignment: Text.AlignBottom
                }

                Rectangle {
                    id: bar
                    anchors.left: parent.left
                    anchors.leftMargin: listItem.barMargin
                    anchors.right: parent.right
                    anchors.rightMargin: listItem.barMargin
                    anchors.top: titleLabel.bottom
                    anchors.topMargin: styler.themePaddingMedium
                    color: "#00000000"
                    height: 0.65 * styler.themeItemSizeSmall
                }

                /*
             * Table of route legs
             */

                Repeater {
                    id: repeater
                    anchors.top: bar.bottom
                    anchors.topMargin: styler.themePaddingMedium
                    height: 0
                    model: listItem.result.legs.length
                    width: parent.width

                    /*
                 * Single route leg
                 */

                    Item {
                        id: row
                        height: timeLabel.height
                        width: parent.width

                        property real elapsed: leg.dep_unix - listItem.result.legs[0].dep_unix
                        property var  leg: listItem.result.legs[index]

                        Rectangle {
                            id: barChunk
                            color: leg.color
                            height: bar.height
                            opacity: leg.mode === "WALK" ? 0.7 : 0.85
                            width: leg.duration/listItem.result.duration * bar.width - listItem.barGap
                            x: bar.x + row.elapsed/listItem.result.duration * bar.width + listItem.barGap
                            y: bar.y
                        }

                        LabelPL {
                            id: barChunkLabel
                            height: barChunk.height
                            horizontalAlignment: Text.AlignHCenter
                            text: leg.line
                            verticalAlignment: Text.AlignVCenter
                            width: barChunk.width
                            x: barChunk.x
                            y: barChunk.y
                        }

                        LabelPL {
                            id: timeLabel
                            height: implicitHeight + styler.themePaddingSmall
                            horizontalAlignment: Text.AlignRight
                            text: leg.dep_time
                            verticalAlignment: Text.AlignVCenter
                            width: page.timeWidth
                            x: parent.x + styler.themeHorizontalPageMargin
                            y: repeater.y + index * row.height
                            Component.onCompleted: page.timeWidth = Math.max(
                                                       page.timeWidth, timeLabel.implicitWidth);
                        }

                        LabelPL {
                            id: lineLabel
                            height: implicitHeight + styler.themePaddingSmall
                            horizontalAlignment: Text.AlignRight
                            text: leg.line
                            verticalAlignment: Text.AlignVCenter
                            width: page.lineWidth
                            x: timeLabel.x + page.timeWidth + styler.themePaddingMedium
                            y: repeater.y + index * row.height
                            Component.onCompleted: page.lineWidth = Math.max(
                                                       page.lineWidth, lineLabel.implicitWidth);
                        }

                        LabelPL {
                            id: nameLabel
                            height: implicitHeight + styler.themePaddingSmall
                            text: leg.mode === "WALK" ?
                                      app.tr("Walk %1", page.formatLength(leg.length)) :
                                      app.tr("%1 → %2", leg.dep_name, leg.arr_name)
                            truncMode: truncModes.fade
                            verticalAlignment: Text.AlignVCenter
                            width: parent.width - x - styler.themeHorizontalPageMargin
                            x: lineLabel.x + page.lineWidth + styler.themePaddingMedium
                            y: repeater.y + index * row.height
                        }

                        Component.onCompleted: repeater.height += row.height;

                    }

                }

                LabelPL {
                    // Not a real leg, needed to show arrival time.
                    id: finalLabel
                    anchors.top: repeater.bottom
                    height: implicitHeight + styler.themePaddingSmall
                    horizontalAlignment: Text.AlignRight
                    text: listItem.result.legs[listItem.result.legs.length-1].arr_time
                    verticalAlignment: Text.AlignVCenter
                    width: page.timeWidth
                    x: parent.x + styler.themeHorizontalPageMargin
                    Component.onCompleted: page.timeWidth = Math.max(
                                               page.timeWidth, finalLabel.implicitWidth);
                }

                onClicked: {
                    app.hideMenu(app.tr("Route to %1", page.toText));
                    navigator.setRoute(listItem.result);
                    pois.hide();
                    map.fitViewToRoute();
                }

            }

            model: ListModel {}
        }

        Item {
            height: busy.visible ? page.height*3.0/4.0 : 0
            width: page.width
            BusyModal {
                id: busy
                running: page.loading
                visible: running || error
            }
        }
    }

    onPageStatusActivating: {
        if (page.populated) return;
        mainList.model.clear();
        page.loading = true;
        page.title = "";
        busy.text = app.tr("Searching");
    }

    onPageStatusActive: {
        mainList.visible = true;
        if (page.populated) return;
        page.populate();
    }

    onPageStatusInactive: {
        mainList.visible = false;
    }

    function formatLength(length) {
        // Format length in meters to human-readable format.
        return py.call_sync("poor.util.format_distance", [length]);
    }

    function populate() {
        // Load routing results from the Python backend.
        var routePage = app.pages.previousPage();
        if (routePage.saveDestination()) {
            var d = {
                'text': routePage.toText,
                'x': routePage.to[0],
                'y': routePage.to[1]
            };
            py.call_sync("poor.app.history.add_destination", [d]);
        }
        page.toText = routePage.toText;
        var args = [routePage.from, routePage.to, null, routePage.params];
        py.call("poor.app.router.route", args, function(results) {
            if (results && results.error && results.message) {
                page.title = "";
                busy.error = results.message;
            } else if (results && results.length > 0) {
                // save found route
                if (routePage.toText && routePage.to && routePage.fromText && routePage.from) {
                    var r = {
                        'to': {
                            'text': routePage.toText,
                            'x': routePage.to[0],
                            'y': routePage.to[1]
                        },
                        'from': {
                            'text': routePage.fromText,
                            'x': routePage.from[0],
                            'y': routePage.from[1]
                        }
                    };
                    py.call_sync("poor.app.history.add_route", [r]);
                }
                // show results
                page.title = app.tr("Results");
                page.results = results;
                Util.appendAll(mainList.model, results);
            } else {
                page.title = "";
                busy.error = app.tr("No results");
                if (routePage.autoRoute) {
                    routePage.notify(app.tr("No results"));
                    app.pages.popAttached();
                }
            }
            page.loading = false;
            page.populated = true;
        });
    }

}
