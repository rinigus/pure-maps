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
import "."
import "platform"

PagePL {
    id: page
    title: app.tr("Maneuvers")

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
                    navigator.running = !navigator.running;
                }
            }

            ToolItemPL {
                id: rerouteItem
                width: row.itemWidth
                icon.iconHeight: styler.themeIconSizeMedium
                icon.iconName: styler.iconRefresh
                text: app.tr("Reroute")
                onClicked: {
                    navigator.reroute();
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
                    navigator.clearRoute();
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
