/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2014 Osmo Salomaa, 2018-2019 Rinigus, 2019 Purism SPC
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

Item {
    // Distance and time remaining + total
    id: infoLayout
    anchors.left: parent.left
    anchors.leftMargin: styler.themeHorizontalPageMargin
    anchors.right: parent.right
    anchors.rightMargin: styler.themeHorizontalPageMargin
    height: {
        if (!visible) return 0;
        var trLine = hasTraffic ? lr3.height + styler.themePaddingMedium : 0;
        if (willFit) return lr1.height + lr2.height + styler.themePaddingMedium + trLine;
        return lr1.height + lr2.height + t1.height + t2.height + 3*styler.themePaddingMedium + trLine;
    }
    states: [
        State {
            when: !infoLayout.willFit
            AnchorChanges {
                target: d1
                anchors.right: infoLayout.right
            }
            PropertyChanges {
                target: d1
                anchors.rightMargin: 0
                width: parent.width-infoLayout.col1w-styler.themePaddingLarge
            }
            AnchorChanges {
                target: t1
                anchors.baseline: undefined
                anchors.right: parent.right
                anchors.top: d1.bottom
            }
            PropertyChanges {
                target: t1
                width: parent.width
                anchors.topMargin: styler.themePaddingMedium
            }
            AnchorChanges {
                target: d2
                anchors.right: infoLayout.right
            }
            PropertyChanges {
                target: d2
                anchors.rightMargin: 0
                width: parent.width-infoLayout.col1w-styler.themePaddingLarge
            }
            AnchorChanges {
                target: t2
                anchors.baseline: undefined
                anchors.right: parent.right
                anchors.top: d2.bottom
            }
            PropertyChanges {
                target: t2
                width: parent.width
                anchors.topMargin: styler.themePaddingMedium
            }
            // no changes for t3 as it is traffic line
        }
    ]

    property bool activeColors: false
    property int  col1w: Math.max(lr1.implicitWidth, lr2.implicitWidth)
    property int  col2w: Math.max(d1.implicitWidth, d2.implicitWidth)
    property int  col3w: Math.max(t1.implicitWidth, t2.implicitWidth)
    property bool hasTraffic: app.navigator.hasTraffic
    property bool willFit: width - styler.themePaddingLarge*2- col1w - col2w - col3w > 0

    // Row 1
    LabelPL {
        id: lr1
        anchors.left: parent.left
        anchors.top: parent.top
        color: activeColors ? styler.themeSecondaryColor : styler.themeSecondaryHighlightColor
        horizontalAlignment: Text.AlignRight
        font.pixelSize: styler.themeFontSizeMedium
        text: app.tr("Remaining")
        width: infoLayout.col1w
    }
    LabelPL {
        id: d1
        anchors.baseline: lr1.baseline
        anchors.right: t1.left
        anchors.rightMargin: styler.themePaddingLarge
        color: activeColors ? styler.themePrimaryColor : styler.themeHighlightColor
        horizontalAlignment: Text.AlignRight
        font.pixelSize: styler.themeFontSizeMedium
        text: app.navigator.destDist
        width: infoLayout.col2w
    }
    LabelPL {
        id: t1
        anchors.baseline: lr1.baseline
        anchors.right: parent.right
        color: activeColors ? styler.themePrimaryColor : styler.themeHighlightColor
        horizontalAlignment: Text.AlignRight
        font.pixelSize: styler.themeFontSizeMedium
        text: app.navigator.destTime
        width: infoLayout.col3w
    }

    // Row 2
    LabelPL {
        id: lr2
        anchors.left: parent.left
        anchors.top: t1.bottom
        anchors.topMargin: styler.themePaddingMedium
        color: activeColors ? styler.themeSecondaryColor : styler.themeSecondaryHighlightColor
        horizontalAlignment: Text.AlignRight
        font.pixelSize: styler.themeFontSizeMedium
        text: app.tr("Total")
        width: infoLayout.col1w
    }
    LabelPL {
        id: d2
        anchors.baseline: lr2.baseline
        anchors.right: t2.left
        anchors.rightMargin: styler.themePaddingLarge
        color: activeColors ? styler.themePrimaryColor : styler.themeHighlightColor
        horizontalAlignment: Text.AlignRight
        font.pixelSize: styler.themeFontSizeMedium
        text: app.navigator.totalDist
        width: infoLayout.col2w
    }
    LabelPL {
        id: t2
        anchors.baseline: lr2.baseline
        anchors.right: parent.right
        color: activeColors ? styler.themePrimaryColor : styler.themeHighlightColor
        horizontalAlignment: Text.AlignRight
        font.pixelSize: styler.themeFontSizeMedium
        text: app.navigator.totalTime
        width: infoLayout.col3w
    }

    // Row 3
    LabelPL {
        id: lr3
        anchors.left: parent.left
        anchors.top: t2.bottom
        anchors.topMargin: styler.themePaddingMedium
        anchors.right: parent.right
        color: activeColors ? styler.themePrimaryColor : styler.themeHighlightColor
        horizontalAlignment: Text.AlignRight
        font.pixelSize: styler.themeFontSizeMedium
        text: app.tr("incl %1 traffic delay", app.navigator.totalTimeInTraffic)
        visible: infoLayout.hasTraffic
        width: infoLayout.col1w
    }
}
