/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2014 Osmo Salomaa, 2018-2020 Rinigus
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
    z: 400

    property int    compactTotalWidth: compactLeft.width + compactLeft.anchors.rightMargin + compactRight.width
    property string destDist:  showNextLocation ? navigator.nextLocationDist : app.navigator.destDist
    property string destEta:   showNextLocation ? navigator.nextLocationEta : app.navigator.destEta
    property string destTime:  showNextLocation ? navigator.nextLocationTime : app.navigator.destTime
    // difference in height between main and button rectangles if the button
    // rectangle sticks out. zero otherwise. margins defined as in NavigationCurrentBlock
    property int    extrasAndCompactHeight: Math.max(destLabel.height, destEta.height, distLabel.height)
    property real   marginExtraLeft: leftRect.visible ? leftRect.height - mainRect.height : 0
    property real   marginExtraLeftSide: leftRect.visible ? leftRect.width : 0
    property real   marginExtraRight: leftRect.visible ? rightRect.height - mainRect.height : 0
    property real   marginExtraRightSide: leftRect.visible ? rightRect.width : 0
    property var    mode: {
        if (app.mode === modes.navigate) {
            if (!app.portrait) {
                if (_splitPossible) {
                    if (streetName) return blockModes.condensedWithStreet;
                    return blockModes.condensedSplit;
                }
            }
            if (compactTotalWidth/2 < _availableHalfSpace)
                return blockModes.condensedCentered;
            return blockModes.condensedNarrow;
        }
        return blockModes.full;
    }
    property bool   showAtBottom: app.mode === modes.navigate
    property bool   showNextLocation: app.mode === modes.navigate &&
                                      navigator.hasNextLocation
    property string streetName: (gps.streetName !== undefined && gps.streetName !== null &&
                                 gps.streetName.length>0) ? gps.streetName : ""
    property bool   streetNameInOverview: app.mode === modes.navigate && !app.portrait && _splitPossible
    property string totalDist: app.navigator.totalDist

    // spacing properties
    property int    _availableHalfSpace: block.width/2 - button.width -
                                         compactRight.anchors.rightMargin - button.anchors.rightMargin
    property bool   _splitPossible: compactTotalWidth/2 < _availableHalfSpace - styler.themePaddingLarge*2

    // press feedback
    property var    _colorBg: _pressed ? styler.blockPressed : styler.blockBg
    property bool   _pressed: mainRectMouse.pressed || leftRectMouse.pressed || rightRectMouse.pressed

    readonly property var blockModes: QtObject {
        readonly property int full: 1
        readonly property int condensedCentered: 2
        readonly property int condensedSplit: 3
        readonly property int condensedNarrow: 4
        readonly property int condensedWithStreet: 5
    }


    Rectangle {
        id: mainRect
        anchors.top: parent.top
        color: _colorBg
        height: Math.max(infoLayout.visible ? infoLayout.height : 0,
                         mode !== blockModes.condensedSplit && compactLeft.visible ? compactLeft.height : 0,
                         mode !== blockModes.condensedSplit && compactRight.visible ? compactRight.height : 0,
                         mode === blockModes.condensedWithStreet && streetLabel.visible ? streetLabel.height : 0,
                         app.mode !== modes.navigate ? button.height : 0) +
                    (mode === blockModes.condensedSplit ? progress.height*3/2 : styler.themePaddingMedium*2)
        width: parent.width

        MouseArea {
            id: mainRectMouse
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
        color: _colorBg
        height: compactLeft.height + styler.themePaddingMedium*2 + radius
        radius: styler.radius
        visible: mode === blockModes.condensedSplit
        width: compactLeft.width + compactLeft.anchors.leftMargin + styler.themePaddingLarge + radius
        MouseArea {
            id: leftRectMouse
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
        color: _colorBg
        height: compactRight.height + compactRight.anchors.bottomMargin +
                compactRight.anchors.topMargin + radius
        radius: styler.radius
        visible: mode === blockModes.condensedSplit
        width: compactRight.width + compactRight.anchors.rightMargin +
               button.width + button.anchors.rightMargin +
               styler.themePaddingLarge + radius
        MouseArea {
            id: rightRectMouse
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
        activeColors: _pressed ? false : true
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
                when: mode === blockModes.condensedSplit || mode === blockModes.condensedWithStreet
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
            anchors.baseline: distLabel.baseline
            color: _pressed ? styler.themeSecondaryHighlightColor : styler.themeSecondaryColor
            font.pixelSize: styler.themeFontSizeMedium
            text: navigator.nextLocationDestination ?
                      // TRANSLATORS: "(D)" corresponds to the abbreviated destination
                      app.tr("(D)") :
                      // TRANSLATORS: "(W)" corresponds to the abbreviated waypoint
                      app.tr("(W)")
            visible: showNextLocation
        }

        Spacer {
            width: styler.themePaddingLarge
        }

        LabelPL {
            id: distLabel
            color: _pressed ? styler.themeHighlightColor : styler.themePrimaryColor
            font.pixelSize: styler.themeFontSizeMedium
            text: block.destDist
        }

        Spacer {
            width: styler.themePaddingLarge
        }

        LabelPL {
            anchors.baseline: distLabel.baseline
            color: _pressed ? styler.themeHighlightColor : styler.themePrimaryColor
            font.pixelSize: styler.themeFontSizeMedium
            text: block.destTime
        }
    }

    LabelPL {
        // Current street
        id: streetLabel
        anchors.bottom: parent.bottom
        anchors.bottomMargin: styler.themePaddingMedium
        anchors.left: compactLeft.right
        anchors.leftMargin: {
            // position into the center if possible
            var ref = compactLeft.x + compactLeft.width;
            var xmin = compactLeft.x + compactLeft.width + styler.themePaddingLarge;
            var xcenter = parent.width / 2 - implicitWidth / 2;
            var xright = compactRight.x - anchors.rightMargin - implicitWidth;
            if (xcenter > xmin) return xcenter - ref;
            if (xright > xmin) return xright - ref;
            return styler.themePaddingLarge;
        }
        anchors.right: compactRight.left
        anchors.rightMargin: styler.themePaddingLarge
        color: _pressed ? styler.themeHighlightColor : styler.themePrimaryColor
        font.pixelSize: styler.themeFontSizeMedium
        text: block.streetName
        truncMode: truncModes.fade
        visible: mode === blockModes.condensedWithStreet && text
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
            color: _pressed ? styler.themeSecondaryHighlightColor : styler.themeSecondaryColor
            font.pixelSize: styler.themeFontSizeSmall
            text: {
                if (mode === blockModes.condensedSplit && showNextLocation) {
                    return navigator.nextLocationDestination ?
                                // TRANSLATORS: "(D)" corresponds to the abbreviated destination
                                app.tr("(D) ETA") :
                                // TRANSLATORS: "(W)" corresponds to the abbreviated waypoint
                                app.tr("(W) ETA")
                }
                return app.tr("ETA");
            }
        }

        Spacer {
            width: styler.themePaddingSmall
        }

        LabelPL {
            // Estimated time of arrival: shown during navigation and exploreRoute
            id: destLabel
            color: _pressed ? styler.themeHighlightColor : styler.themePrimaryColor
            font.pixelSize: styler.themeFontSizeMedium
            height: text ? implicitHeight : 0
            text: block.destEta
        }
    }

    IconPL {
        id: button
        anchors.bottom: block.showAtBottom ? parent.bottom : undefined
        anchors.bottomMargin: compactRight.anchors.bottomMargin
        anchors.right: parent.right
        anchors.rightMargin: styler.themeHorizontalPageMargin
        anchors.top: !block.showAtBottom ? parent.top : undefined
        anchors.topMargin: styler.themePaddingMedium
        height: iconHeight
        iconHeight: app.mode !== modes.navigate ? styler.themeIconSizeSmall :
                                                  compactRight.height
        iconName: styler.iconManeuvers
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
