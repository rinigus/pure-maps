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
    title: app.tr("Navigation")

    onPageStatusActive: app.navigationPageSeen = true;

    property bool partOfNavigationStack: true

    Column {
        id: column
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width

        Row {
            id: row
            height: Math.max(beginItem.height, rerouteItem.height, clearItem.height)
            width: parent.width

            property real contentWidth: width - 2 * app.styler.themeHorizontalPageMargin
            property real itemWidth: contentWidth / 3

            ToolItemPL {
                id: beginItem
                width: row.itemWidth + app.styler.themeHorizontalPageMargin
                icon.source: app.mode === modes.navigate ? app.styler.iconPause : app.styler.iconStart
                icon.sourceSize.height: app.styler.themeIconSizeMedium
                text: app.mode === modes.navigate ? app.tr("Pause") :
                                                    (app.navigationStarted ? app.tr("Resume") : app.tr("Begin"))
                onClicked: {
                    if (app.mode === modes.navigate) app.setModeExplore();
                    else app.setModeNavigate();
                    app.hideNavigationPages();
                }
            }

            ToolItemPL {
                id: rerouteItem
                width: row.itemWidth
                icon.source: app.styler.iconRefresh
                icon.sourceSize.height: app.styler.themeIconSizeMedium
                text: app.tr("Reroute")
                onClicked: {
                    app.reroute();
                    app.hideNavigationPages();
                }
            }

            ToolItemPL {
                id: clearItem
                width: row.itemWidth + app.styler.themeHorizontalPageMargin
                icon.source: app.styler.iconClear
                icon.sourceSize.height: app.styler.themeIconSizeMedium
                text: app.tr("Clear")
                onClicked: {
                    if (app.mode === modes.navigate) app.setModeExplore();
                    map.clearRoute();
                    app.showMap();
                }
            }

        }

        Spacer {
            height: app.styler.themePaddingLarge
        }

        SectionHeaderPL {
            text: app.tr("Status")
        }

        Spacer {
            height: app.styler.themePaddingLarge
        }

        Item {
            id: progress
            anchors.left: parent.left
            anchors.right: parent.right
            height: app.styler.themePaddingSmall
            Rectangle {
                id: progressTotal
                anchors.left: parent.left
                anchors.leftMargin: app.styler.themeHorizontalPageMargin
                anchors.right: parent.right
                anchors.rightMargin: app.styler.themeHorizontalPageMargin
                color: app.styler.themePrimaryColor
                height: app.styler.themePaddingSmall
                opacity: 0.15
                radius: height / 2
            }
            Rectangle {
                id: progressComplete
                anchors.left: parent.left
                anchors.leftMargin: app.styler.themeHorizontalPageMargin
                color: app.styler.themeHighlightColor
                height: app.styler.themePaddingSmall
                radius: height / 2
                width: app.navigationStatus.progress * progressTotal.width
            }
        }

        Spacer {
            height: app.styler.themePaddingLarge + app.styler.themePaddingSmall
        }

        Row {
            // Distance and time remaining
            anchors.left: parent.left
            anchors.leftMargin: app.styler.themeHorizontalPageMargin
            anchors.right: parent.right
            anchors.rightMargin: app.styler.themeHorizontalPageMargin
            height: app.styler.themeItemSizeExtraSmall
            LabelPL {
                id: remaining1
                height: app.styler.themeItemSizeExtraSmall
                text: app.tr("Remaining")
                truncMode: truncModes.fade
                verticalAlignment: Text.AlignVCenter
                width: parent.width / 3
            }
            LabelPL {
                anchors.baseline: remaining1.baseline
                horizontalAlignment: Text.AlignRight
                text: app.navigationStatus.destDist
                truncMode: truncModes.fade
                width: parent.width / 3
            }
            LabelPL {
                anchors.baseline: remaining1.baseline
                horizontalAlignment: Text.AlignRight
                text: app.navigationStatus.destTime
                truncMode: truncModes.fade
                width: parent.width / 3
            }
        }

        Row {
            // Total distance and time
            anchors.left: parent.left
            anchors.leftMargin: app.styler.themeHorizontalPageMargin
            anchors.right: parent.right
            anchors.rightMargin: app.styler.themeHorizontalPageMargin
            height: app.styler.themeItemSizeExtraSmall
            LabelPL {
                id: total1
                height: app.styler.themeItemSizeExtraSmall
                text: app.tr("Total")
                truncMode: truncModes.fade
                verticalAlignment: Text.AlignVCenter
                width: parent.width / 3
            }
            LabelPL {
                anchors.baseline: total1.baseline
                horizontalAlignment: Text.AlignRight
                text: app.navigationStatus.totalDist
                truncMode: truncModes.fade
                width: parent.width / 3
            }
            LabelPL {
                anchors.baseline: total1.baseline
                horizontalAlignment: Text.AlignRight
                text: app.navigationStatus.totalTime
                truncMode: truncModes.fade
                width: parent.width / 3
            }
        }

        Spacer {
            height: app.styler.themePaddingLarge
        }

        SectionHeaderPL {
            text: app.tr("Options")
        }

        Spacer {
            height: app.styler.themePaddingLarge
        }

        SliderPL {
            id: scaleSlider
            label: app.tr("Map scale")
            maximumValue: 4.0
            minimumValue: 0.5
            stepSize: 0.1
            value: map.route.mode != null ? app.conf.get("map_scale_navigation_" + map.route.mode) : 1
            valueText: value
            visible: map.route.mode != null
            width: parent.width
            onValueChanged: {
                if (map.route.mode == null) return;
                app.conf.set("map_scale_navigation_" + map.route.mode, scaleSlider.value);
                if (app.mode === modes.navigate) map.setScale(scaleSlider.value);
            }
        }

        Spacer {
            height: app.styler.themePaddingMedium
        }

    }

}
