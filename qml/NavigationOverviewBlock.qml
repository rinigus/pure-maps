/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2014 Osmo Salomaa, 2018 Rinigus
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
import "platform"
import "."

Item {
    id: block
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top

    height: visible ? mainRect.height : 0
    states: [
        State {
            when: showAtBottom
            AnchorChanges {
                target: block
                anchors.bottom: parent.bottom
                anchors.top: undefined
            }
        }
    ]
    visible: !app.modalDialog && (app.mode === modes.exploreRoute || app.mode === modes.navigate)
    z: 910

    property int    compactTotalWidth: compactLeft.width + compactLeft.anchors.rightMargin + compactRight.width
    property string destDist:  app.navigator.destDist
    property string destEta:   app.navigator.destEta
    property string destTime:  app.navigator.destTime
    // difference in height between main and button rectangles if the button
    // rectangle sticks out. zero otherwise. margins defined as in NavigationCurrentBlock
    property int    extrasAndCompactHeight: Math.max(destLabel.height, destEta.height, distLabel.height)
    property real   marginExtraLeft: leftRect.visible ? leftRect.height - mainRect.height : 0
    property real   marginExtraLeftSide: leftRect.visible ? leftRect.width : 0
    property real   marginExtraRight: leftRect.visible ? rightRect.height - mainRect.height : 0
    property real   marginExtraRightSide: leftRect.visible ? rightRect.width : 0
    property var    mode: {
        if (app.mode === modes.navigate) {
            var availableHalfSpace = block.width/2 - button.width -
                    compactRight.anchors.rightMargin - button.anchors.rightMargin;
            if (!app.portrait) {
                if (compactTotalWidth/2 < availableHalfSpace - styler.themePaddingLarge*2)
                    return blockModes.condensedSplit;
            }
            if (compactTotalWidth/2 < availableHalfSpace)
                return blockModes.condensedCentered;
            return blockModes.condensedNarrow;
        }
        return blockModes.full;
    }
    property bool   showAtBottom: app.mode === modes.navigate
    property string totalDist: app.navigator.totalDist

    readonly property var blockModes: QtObject {
        readonly property int full: 1
        readonly property int condensedCentered: 2
        readonly property int condensedSplit: 3
        readonly property int condensedNarrow: 4
    }


    Rectangle {
        id: mainRect
        anchors.top: parent.top
        color: styler.blockBg
        height: Math.max(infoLayout.visible ? infoLayout.height : 0,
                         mode !== blockModes.condensedSplit && compactLeft.visible ? compactLeft.height : 0,
                         mode !== blockModes.condensedSplit && compactRight.visible ? compactRight.height : 0,
                         app.mode !== modes.navigate ? button.height : 0) +
                (mode === blockModes.condensedSplit ? progress.height*3/2 : styler.themePaddingMedium*2)
        width: parent.width

        MouseArea {
            anchors.fill: parent
            onClicked: block.openNavigation()
        }
    }

    Rectangle {
        // shown only in condensedSplit mode
        id: leftRect
        anchors.bottom: parent.bottom
        anchors.bottomMargin: -radius
        anchors.left: parent.left
        anchors.leftMargin: -radius
        color: styler.blockBg
        height: compactLeft.height + styler.themePaddingMedium*2 + radius
        radius: styler.themePaddingMedium
        visible: mode === blockModes.condensedSplit
        width: compactLeft.width + compactLeft.anchors.leftMargin + styler.themePaddingLarge + radius
        MouseArea {
            anchors.fill: parent
            onClicked: block.openNavigation()
        }
    }

    Rectangle {
        // shown only in condensedSplit mode
        id: rightRect
        anchors.bottom: parent.bottom
        anchors.bottomMargin: -radius
        anchors.right: parent.right
        anchors.rightMargin: -radius
        color: styler.blockBg
        height: compactRight.height + compactRight.anchors.bottomMargin +
                compactRight.anchors.topMargin + radius
        radius: styler.themePaddingMedium
        visible: mode === blockModes.condensedSplit
        width: compactRight.width + compactRight.anchors.rightMargin +
               button.width + button.anchors.rightMargin +
               styler.themePaddingLarge + radius
        MouseArea {
            anchors.fill: parent
            onClicked: block.openNavigation()
        }
    }

    RouteOverallInfo {
        // when in full mode - showing info on top of the screen
        id: infoLayout
        anchors.top: parent.top
        anchors.topMargin: styler.themePaddingMedium
        anchors.right: button.left
        anchors.rightMargin: styler.themePaddingMedium
        activeColors: true
        visible: mode === blockModes.full
    }

    Row {
        id: compactLeft
        anchors.bottom: parent.bottom
        anchors.bottomMargin: styler.themePaddingMedium
        anchors.leftMargin: styler.themeHorizontalPageMargin
        anchors.right: compactRight.left
        anchors.rightMargin: styler.themePaddingLarge
        height: extrasAndCompactHeight
        states: [
            State {
                when: mode === blockModes.condensedCentered
                AnchorChanges {
                    target: compactLeft
                    anchors.left: undefined
                    anchors.right: undefined
                }
                PropertyChanges {
                    target: compactLeft
                    x: block.width/2 - compactTotalWidth/2
                }
            },
            State {
                when: mode === blockModes.condensedSplit
                AnchorChanges {
                    target: compactLeft
                    anchors.left: block.left
                    anchors.right: undefined
                }
            },
            State {
                // condensedNarrow
                AnchorChanges {
                    target: compactLeft
                    anchors.left: undefined
                    anchors.right: button.left
                    anchors.horizontalCenter: undefined
                }
                PropertyChanges {
                    target: compactLeft
                    x: undefined
                }
            }
        ]
        visible: mode !== blockModes.full
        width: visible ? implicitWidth : 0

        LabelPL {
            id: distLabel
            color: styler.themePrimaryColor
            font.pixelSize: styler.themeFontSizeMedium
            text: block.destDist
        }

        Spacer {
            width: styler.themePaddingLarge
        }

        LabelPL {
            anchors.baseline: distLabel.baseline
            color: styler.themePrimaryColor
            font.pixelSize: styler.themeFontSizeMedium
            text: block.destTime
        }
    }

    Row {
        id: compactRight
        anchors.bottom: parent.bottom
        anchors.bottomMargin: styler.themePaddingMedium
        anchors.leftMargin: styler.themePaddingLarge
        anchors.right: button.left
        anchors.rightMargin: styler.themePaddingMedium
        anchors.topMargin: styler.themePaddingMedium
        height: extrasAndCompactHeight
        states: [
            State {
                when: mode === blockModes.condensedCentered
                AnchorChanges {
                    target: compactRight
                    anchors.left: compactLeft.right
                    anchors.right: undefined
                }
            },
            State {
                AnchorChanges {
                    target: compactRight
                    anchors.left: undefined
                    anchors.right: button.left
                }
            }
        ]
        visible: mode !== blockModes.full
        width: visible ? implicitWidth : 0

        LabelPL {
            // Estimated time of arrival: ETA label
            id: destEta
            anchors.baseline: destLabel.baseline
            color: styler.themeSecondaryColor
            font.pixelSize: styler.themeFontSizeSmall
            text: app.tr("ETA")
        }

        Spacer {
            width: styler.themePaddingSmall
        }

        LabelPL {
            // Estimated time of arrival: shown during navigation and exploreRoute
            id: destLabel
            color: styler.themePrimaryColor
            font.pixelSize: styler.themeFontSizeMedium
            height: text ? implicitHeight : 0
            text: block.destEta
        }
    }

    IconButtonPL {
        id: button
        anchors.bottom: block.showAtBottom ? parent.bottom : undefined
        anchors.right: parent.right
        anchors.rightMargin: styler.themeHorizontalPageMargin
        anchors.top: !block.showAtBottom ? parent.top : undefined
        iconHeight: app.mode !== modes.navigate ?
                        styler.themeIconSizeSmall :
                        (compactRight.height + compactRight.anchors.bottomMargin +
                         compactRight.anchors.topMargin) / (1+padding)
        iconName: styler.iconManeuvers
        onClicked: block.openNavigation()
    }

    Item {
        id: progress
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        height: styler.themePaddingSmall*2/3
        states: [
            State {
                when: showAtBottom
                AnchorChanges {
                    target: progress
                    anchors.bottom: parent.bottom
                    anchors.top: undefined
                }
            }
        ]
        Rectangle {
            id: progressTotal
            anchors.left: parent.left
            anchors.leftMargin: styler.themeHorizontalPageMargin
            anchors.right: parent.right
            anchors.rightMargin: styler.themeHorizontalPageMargin
            color: styler.themePrimaryColor
            height: parent.height
            opacity: 0.15
            radius: height / 2
        }
        Rectangle {
            id: progressComplete
            anchors.left: parent.left
            anchors.leftMargin: progressTotal.anchors.leftMargin
            color: styler.themeHighlightColor
            height: parent.height
            opacity: 0.75
            radius: height / 2
            width: app.navigator.progress * progressTotal.width
        }
    }


    function openNavigation() {
        if (visible) app.showNavigationPages()
    }
}
