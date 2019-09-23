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
        },
        State {
            when: showAtBottom
            AnchorChanges {
                target: block
                anchors.bottom: undefined
                anchors.top: parent.top
            }
        }
    ]
    visible: !app.modalDialog && (app.mode === modes.exploreRoute || app.mode === modes.navigate)
    z: 910

    property bool   showAtBottom: app.mode === modes.navigate
    property bool   condensedMode: app.mode === modes.navigate
    property string destDist:  app.navigationStatus.destDist
    property string destEta:   app.navigationStatus.destEta
    property string destTime:  app.navigationStatus.destTime
    // difference in height between main and button rectangles if the button
    // rectangle sticks out. zero otherwise
    property real   marginExtra: Math.max(button.height - mainRect.height, 0)
    property string totalDist: app.navigationStatus.totalDist

    Rectangle {
        id: mainRect
        anchors.top: parent.top
        color: styler.blockBg
        height: Math.max(infoLayout.visible ? infoLayout.height : 0,
                         extrasAndCompact.height,
                         block.condensedMode ? 0 : button.height) + styler.themePaddingMedium*2
        width: parent.width

        MouseArea {
            anchors.fill: parent
            onClicked: block.openNavigation()
        }

        RouteOverallInfo {
            id: infoLayout
            anchors.top: parent.top
            anchors.topMargin: styler.themePaddingMedium
            anchors.right: button.left
            anchors.rightMargin: styler.themePaddingMedium
            activeColors: true
            visible: !block.condensedMode
        }

        Row {
            id: extrasAndCompact
            anchors.top: parent.top
            anchors.topMargin: styler.themePaddingMedium
            anchors.right: button.left
            anchors.rightMargin: styler.themePaddingMedium
            height: destLabel.height
            states: [
                State {
                    when: extrasAndCompact.canCenter
                    AnchorChanges {
                        target: extrasAndCompact
                        anchors.right: undefined
                        anchors.horizontalCenter: mainRect.horizontalCenter
                    }
                },
                State {
                    AnchorChanges {
                        target: extrasAndCompact
                        anchors.right: button.left
                        anchors.horizontalCenter: undefined
                    }
                }
            ]
            visible: block.condensedMode
            width: visible ? implicitWidth : 0

            property bool canCenter: block.condensedMode &&
                                     (extrasAndCompact.implicitWidth / 2 < parent.width/2 - button.width -
                                      anchors.rightMargin - button.anchors.rightMargin)

            LabelPL {
                anchors.baseline: destLabel.baseline
                color: styler.themePrimaryColor
                font.pixelSize: styler.themeFontSizeMedium
                text: block.destDist
            }

            Spacer {
                visible: block.condensedMode
                width: styler.themePaddingLarge
            }

            LabelPL {
                anchors.baseline: destLabel.baseline
                color: styler.themePrimaryColor
                font.pixelSize: styler.themeFontSizeMedium
                text: block.destTime
            }

            Spacer {
                visible: block.condensedMode
                width: styler.themePaddingLarge
            }

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

        Rectangle {
            id: button
            anchors.bottom: block.showAtBottom ? parent.bottom : undefined
            anchors.right: parent.right
            anchors.rightMargin: -styler.themePaddingSmall
            anchors.top: !block.showAtBottom ? parent.top : undefined
            color: styler.blockBg
            height: _button.height + (block.condensedMode ? 2*styler.themePaddingSmall : 0)
            radius: styler.themePaddingSmall
            width: _button.width + 2*styler.themePaddingSmall - anchors.rightMargin

            IconButtonPL {
                id: _button
                anchors.left: button.left
                anchors.leftMargin: styler.themePaddingSmall
                anchors.verticalCenter: button.verticalCenter
                iconHeight: styler.themeIconSizeSmall
                iconName: styler.iconManeuvers
                onClicked: block.openNavigation()
            }
        }
    }

    function openNavigation() {
        if (visible) app.showNavigationPages()
    }
}
