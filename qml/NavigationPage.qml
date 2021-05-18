/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2017 Osmo Salomaa, 2018 Rinigus
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
import QtPositioning 5.4
import QtQuick.Layouts 1.1
import "."
import "platform"

PagePL {
    id: page
    title: app.tr("Navigation")

    Column {
        id: column
        width: parent.width

        Row {
            id: row
            height: Math.max(beginItem.height, rerouteItem.height, clearItem.height)
            width: parent.width

            property real contentWidth: width - 2 * styler.themeHorizontalPageMargin
            property real itemWidth: contentWidth / 3

            ToolItemPL {
                id: beginItem
                width: row.itemWidth + styler.themeHorizontalPageMargin
                icon.iconHeight: styler.themeIconSizeMedium
                icon.iconName: (app.mode === modes.navigate || app.mode === modes.navigatePost) ? styler.iconPause : styler.iconStart
                text: (app.mode === modes.navigate || app.mode === modes.navigatePost) ? app.tr("Pause") : app.tr("Navigate")
                onClicked: {
                    app.hideNavigationPages();
                    app.navigator.running = !app.navigator.running;
                }
            }

            ToolItemPL {
                id: rerouteItem
                width: row.itemWidth
                icon.iconHeight: styler.themeIconSizeMedium
                icon.iconName: styler.iconRefresh
                text: app.tr("Reroute")
                onClicked: {
                    app.navigator.reroute();
                    app.hideNavigationPages();
                }
            }

            ToolItemPL {
                id: clearItem
                width: row.itemWidth + styler.themeHorizontalPageMargin
                icon.iconHeight: styler.themeIconSizeMedium
                icon.iconName: styler.iconClear
                text: app.tr("Clear")
                onClicked: {
                    app.navigator.clearRoute();
                    app.showMap();
                }
            }

        }

        Spacer {
            height: styler.themePaddingLarge
        }

        SectionHeaderPL {
            text: app.tr("Status")
        }

        Spacer {
            height: styler.themePaddingLarge
        }

        Item {
            id: progress
            anchors.left: parent.left
            anchors.right: parent.right
            height: styler.themePaddingSmall
            Rectangle {
                id: progressTotal
                anchors.left: parent.left
                anchors.leftMargin: styler.themeHorizontalPageMargin
                anchors.right: parent.right
                anchors.rightMargin: styler.themeHorizontalPageMargin
                color: styler.themePrimaryColor
                height: styler.themePaddingSmall
                opacity: 0.15
                radius: height / 2
            }
            Rectangle {
                id: progressComplete
                anchors.left: parent.left
                anchors.leftMargin: styler.themeHorizontalPageMargin
                color: styler.themeHighlightColor
                height: styler.themePaddingSmall
                radius: height / 2
                width: app.navigator.progress * progressTotal.width
            }
        }

        Spacer {
            height: styler.themePaddingLarge + styler.themePaddingSmall
        }

        Row {
            // ETA
            anchors.left: parent.left
            anchors.leftMargin: styler.themeHorizontalPageMargin
            anchors.right: parent.right
            anchors.rightMargin: styler.themeHorizontalPageMargin
            height: styler.themeItemSizeExtraSmall
            visible: app.mode !== modes.navigatePost
            LabelPL {
                id: eta
                color: styler.themeSecondaryHighlightColor
                height: styler.themeItemSizeExtraSmall
                text: app.tr("Estimated time of arrival")
                truncMode: truncModes.fade
                verticalAlignment: Text.AlignVCenter
                width: parent.width * 2 / 3
            }
            LabelPL {
                anchors.baseline: eta.baseline
                color: styler.themeHighlightColor
                horizontalAlignment: Text.AlignRight
                text: app.navigator.destEta
                truncMode: truncModes.fade
                width: parent.width / 3
            }
        }

        RouteOverallInfo {
            visible: app.mode !== modes.navigatePost
        }

        LabelPL {
            anchors.left: parent.left
            anchors.leftMargin: styler.themeHorizontalPageMargin
            anchors.right: parent.right
            anchors.rightMargin: styler.themeHorizontalPageMargin
            color: styler.themeHighlightColor
            height: implicitHeight + styler.themePaddingLarge
            horizontalAlignment: Text.AlignHCenter
            text: app.tr("Destination reached")
            visible: app.mode === modes.navigatePost
            verticalAlignment: Text.AlignTop
            wrapMode: Text.WordWrap
        }

        Spacer {
            height: styler.themePaddingLarge + styler.themePaddingSmall
            visible: app.mode !== modes.navigatePost
        }

        SectionHeaderPL {
            text: app.tr("Destinations and waypoints")
        }

        Repeater {
            id: locRep
            delegate: ListItemPL {
                id: locRepItem
                contentHeight: locItem.height
                menu: ContextMenuPL {
                    enabled: !model.final && !model.origin && model.activeIndex > 0
                    ContextMenuItemPL {
                        iconName: styler.iconDelete
                        text: app.tr("Remove")
                        onClicked: if (!model.final && model.activeIndex > 0)
                                       locRep.removeLocationAndReroute(model.activeIndex)
                    }
                }

                Item {
                    id: locItem
                    height: Math.max(locColumn.height + styler.themePaddingLarge,
                                     styler.themeItemSizeSmall)
                    width: parent.width

                    Column {
                        id: locColumn
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: styler.themePaddingMedium
                        width: parent.width

                        ListItemLabel {
                            color: locRepItem.highlighted ? styler.themeHighlightColor : styler.themePrimaryColor
                            text: {
                                if (model.origin)
                                    return model.text ? app.tr("Origin: %1", model.text) : app.tr("Origin");
                                if (model.final)
                                    return model.text ? app.tr("Final destination: %1", model.text) :
                                                        app.tr("Final destination");
                                return model.destination ?
                                            app.tr("Destination: %1", model.text ? model.text : "") :
                                            app.tr("Waypoint: %1", model.text ? model.text : "");
                            }
                        }

                        // Remaining info
                        GridLayout {
                            id: glayout
                            anchors.left: parent.left
                            anchors.leftMargin: styler.themeHorizontalPageMargin
                            anchors.right: parent.right
                            anchors.rightMargin: styler.themeHorizontalPageMargin
                            columnSpacing: styler.themePaddingMedium
                            columns: {
                                var col1 =
                                        2*columnSpacing +
                                        Math.max(lr1.implicitWidth + d1.implicitWidth + t1.implicitWidth,
                                                 lr2.implicitWidth + t2.implicitWidth,
                                                 lr3.implicitWidth + d3.implicitWidth + t3.implicitWidth,
                                                 lr4.implicitWidth + t4.implicitWidth);
                                var col2 =
                                        columnSpacing +
                                        Math.max(lr1.implicitWidth, lr2.implicitWidth,
                                                 lr3.implicitWidth, lr4.implicitWidth) +
                                        Math.max(d1.implicitWidth, t1.implicitWidth,
                                                 t2.implicitWidth,
                                                 d3.implicitWidth, t3.implicitWidth,
                                                 t4.implicitWidth);
                                if (col1 < width) return 3;
                                if (col2 < width) return 2;
                                return 1;
                            }
                            rowSpacing: styler.themePaddingMedium
                            visible: hasRow3 || hasRow2 || hasRow1 || hasRow4

                            property bool hasRow1: !model.arrived && model.dist
                            property bool hasRow2: !model.arrived && model.eta
                            property bool hasRow3: !model.arrived && model.legDist
                            property bool hasRow4: model.arrived
                            property var textColor: locRepItem.highlighted ? styler.themeSecondaryColor :
                                                                             styler.themeSecondaryHighlightColor

                            LabelPL {
                                id: lr1
                                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                                Layout.fillWidth: true
                                Layout.rowSpan: glayout.columns===2 ? 2 : 1
                                color: glayout.textColor
                                font.pixelSize: styler.themeFontSizeMedium
                                horizontalAlignment: Text.AlignLeft
                                text: visible ? app.tr("Remaining") : ""
                                visible: glayout.hasRow1
                            }

                            LabelPL {
                                id: d1
                                Layout.alignment: Qt.AlignRight | Qt.AlignTop
                                color: glayout.textColor
                                font.pixelSize: styler.themeFontSizeMedium
                                text: visible ? model.dist : ""
                                visible: glayout.hasRow1
                            }

                            LabelPL {
                                id: t1
                                Layout.alignment: Qt.AlignRight | Qt.AlignTop
                                color: glayout.textColor
                                font.pixelSize: styler.themeFontSizeMedium
                                text: visible ? model.time : ""
                                visible: glayout.hasRow1
                            }

                            LabelPL {
                                id: lr2
                                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                                Layout.fillWidth: true
                                color: glayout.textColor
                                font.pixelSize: styler.themeFontSizeMedium
                                horizontalAlignment: Text.AlignLeft
                                text: visible ? app.tr("ETA") : ""
                                visible: glayout.hasRow2
                            }

                            LabelPL {
                                id: t2
                                Layout.alignment: Qt.AlignRight | Qt.AlignTop
                                Layout.columnSpan: glayout.columns==3 ? 2 : 1
                                color: glayout.textColor
                                font.pixelSize: styler.themeFontSizeMedium
                                text: visible ? model.eta : ""
                                visible: glayout.hasRow2
                            }

                            LabelPL {
                                id: lr3
                                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                                Layout.fillWidth: true
                                Layout.rowSpan: glayout.columns===2 ? 2 : 1
                                color: glayout.textColor
                                font.pixelSize: styler.themeFontSizeMedium
                                horizontalAlignment: Text.AlignLeft
                                // TRANSLATORS: Leg corresponds to the trip leg between two destinations, such as intermediate destinations on the route
                                text: visible ? app.tr("Leg") : ""
                                visible: glayout.hasRow3
                            }

                            LabelPL {
                                id: d3
                                Layout.alignment: Qt.AlignRight | Qt.AlignTop
                                color: glayout.textColor
                                font.pixelSize: styler.themeFontSizeMedium
                                text: visible ? model.legDist : ""
                                visible: glayout.hasRow3
                            }

                            LabelPL {
                                id: t3
                                Layout.alignment: Qt.AlignRight | Qt.AlignTop
                                color: glayout.textColor
                                font.pixelSize: styler.themeFontSizeMedium
                                text: visible ? model.legTime : ""
                                visible: glayout.hasRow3
                            }

                            LabelPL {
                                id: lr4
                                Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                                Layout.fillWidth: true
                                color: glayout.textColor
                                font.pixelSize: styler.themeFontSizeMedium
                                horizontalAlignment: Text.AlignLeft
                                text: visible ? app.tr("Arrived") : ""
                                visible: glayout.hasRow4
                            }

                            LabelPL {
                                id: t4
                                Layout.alignment: Qt.AlignRight | Qt.AlignTop
                                Layout.columnSpan: glayout.columns==3 ? 2 : 1
                                color: glayout.textColor
                                font.pixelSize: styler.themeFontSizeMedium
                                text: visible ? model.arrivedAt : ""
                                visible: glayout.hasRow4
                            }
                        }
                    }
                }

                onClicked: {
                    map.center = QtPositioning.coordinate(model.y, model.x);
                    map.zoomLevel < 15 && map.setZoomLevel(15);
                    app.hideNavigationPages();
                }
            }
            model: app.navigator.locationsModel
            visible: app.mode !== modes.navigatePost

            function removeLocationAndReroute(index) {
                // has to be outside the location delegate as it will be destroyed
                // on removal of location
                if (!app.navigator.locationRemove(index)) return;
                app.navigator.reroute();
                app.hideNavigationPages();
            }
        }

        Spacer {
            height: styler.themePaddingLarge + styler.themePaddingSmall
            visible: app.mode !== modes.navigatePost
        }

        SectionHeaderPL {
            text: app.tr("Maneuvers")
        }

        NarrativeItem {
            id: narrative
        }
    }

    onPageStatusActivating: {
        if (!app.narrativePageSeen) {
            app.narrativePageSeen = true;
        }
    }
}
