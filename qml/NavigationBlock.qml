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

Panel {
    id: block
    anchors.left: parent.left
    anchors.right: parent.right
    contentHeight: {
        if (app.mode === modes.exploreRoute) {
            var h1 = app.styler.themePaddingMedium + remainingRow.height + totalRow.height + helpLabel.height;
            return h1;
        }
        if (app.mode !== modes.navigate) return 0;
        if (!app.portrait && notify) {
            var h1 = app.styler.themePaddingMedium + app.styler.themeFontSizeLarge - app.styler.themeFontSizeMedium + narrativeLabel.height;
            var h2 = app.styler.themePaddingMedium + destLabel.height;
            var h3 = app.styler.themePaddingMedium + streetLabel.height;
            return Math.max(h1, h2, h3);
        } else {
            var h1 = iconImage.height + 2 * app.styler.themePaddingLarge;
            var h2 = manLabel.height + app.styler.themePaddingSmall + narrativeLabel.height;
            var h3 = manLabel.height + streetLabel.height;
            // If far off route, manLabel defines the height of the block,
            // but we need padding to make a sufficiently large tap target.
            var h4 = notify ? 0 : manLabel.height + app.styler.themePaddingMedium;
            return Math.max(h1, h2, h3, h4);
        }
    }
    mode: panelModes.top
    states: [
        State {
            when: !app.portrait && destDist && notify
            AnchorChanges {
                target: block
                anchors.left: undefined
            }
            PropertyChanges {
                target: block
                width: parent.width - shieldLeftWidth
            }
        }
    ]

    property string destDist:  app.navigationStatus.destDist
    property string destEta:   app.navigationStatus.destEta
    property string destTime:  app.navigationStatus.destTime
    property string icon:      app.navigationStatus.icon
    property string manDist:   app.navigationStatus.manDist
    property string manTime:   app.navigationStatus.manTime
    property string narrative: app.navigationStatus.narrative
    property bool   notify:    app.navigationStatus.notify
    property var    street:    app.navigationStatus.street
    property int    shieldLeftHeight: !app.portrait && destDist && notify ? manLabel.height + app.styler.themePaddingMedium + iconImage.height + iconImage.anchors.topMargin : 0
    property int    shieldLeftWidth:  !app.portrait && destDist && notify ? manLabel.anchors.leftMargin + app.styler.themePaddingLarge + Math.max(manLabel.width, iconImage.width) : 0
    property string totalDist: app.navigationStatus.totalDist
    property string totalTime: app.navigationStatus.totalTime

    // information about route displayed while exploreRoute is active
    Row {
        // Distance and time remaining
        id: remainingRow
        anchors.left: parent.left
        anchors.leftMargin: app.styler.themeHorizontalPageMargin
        anchors.right: parent.right
        anchors.rightMargin: app.styler.themeHorizontalPageMargin
        anchors.top: parent.top
        anchors.topMargin: app.styler.themePaddingMedium
        height: visible ? remaining1.height + app.styler.themePaddingMedium : 0
        visible: app.mode === modes.exploreRoute
        LabelPL {
            anchors.baseline: remaining1.baseline
            color: app.styler.themeSecondaryColor
            font.pixelSize: app.styler.themeFontSizeMedium
            text: app.tr("Remaining")
            truncMode: truncModes.fade
            width: parent.width / 3
        }
        LabelPL {
            id: remaining1
            anchors.top: parent.top
            color: app.styler.themePrimaryColor
            font.pixelSize: app.styler.themeFontSizeMedium
            horizontalAlignment: Text.AlignRight
            text: app.navigationStatus.destDist
            truncMode: truncModes.fade
            verticalAlignment: Text.AlignTop
            width: parent.width / 3
        }
        LabelPL {
            anchors.baseline: remaining1.baseline
            color: app.styler.themePrimaryColor
            font.pixelSize: app.styler.themeFontSizeMedium
            horizontalAlignment: Text.AlignRight
            text: app.navigationStatus.destTime
            truncMode: truncModes.fade
            width: parent.width / 3
        }
    }

    Row {
        // Total distance and time
        id: totalRow
        anchors.left: parent.left
        anchors.leftMargin: app.styler.themeHorizontalPageMargin
        anchors.right: parent.right
        anchors.rightMargin: app.styler.themeHorizontalPageMargin
        anchors.top: remainingRow.bottom
        height: visible ? total.height + app.styler.themePaddingMedium : 0
        visible: app.mode === modes.exploreRoute
        LabelPL {
            anchors.baseline: total.baseline
            color: app.styler.themeSecondaryColor
            font.pixelSize: app.styler.themeFontSizeMedium
            text: app.tr("Total")
            truncMode: truncModes.fade
            width: parent.width / 3
        }
        LabelPL {
            id: total
            anchors.top: parent.top
            color: app.styler.themePrimaryColor
            font.pixelSize: app.styler.themeFontSizeMedium
            horizontalAlignment: Text.AlignRight
            text: app.navigationStatus.totalDist
            truncMode: truncModes.fade
            verticalAlignment: Text.AlignTop
            width: parent.width / 3
        }
        LabelPL {
            anchors.baseline: total.baseline
            color: app.styler.themePrimaryColor
            font.pixelSize: app.styler.themeFontSizeMedium
            horizontalAlignment: Text.AlignRight
            text: app.navigationStatus.totalTime
            truncMode: truncModes.fade
            width: parent.width / 3
        }
    }

    LabelPL {
        // help label
        id: helpLabel
        anchors.left: parent.left
        anchors.leftMargin: app.styler.themeHorizontalPageMargin
        anchors.right: parent.right
        anchors.rightMargin: app.styler.themeHorizontalPageMargin
        anchors.top: totalRow.bottom
        color: app.styler.themePrimaryColor
        font.pixelSize: app.styler.themeFontSizeMedium
        height: text ? implicitHeight + app.styler.themePaddingMedium : 0
        text: {
            if (app.mode !== modes.exploreRoute) return "";
            if (!totalDist)
                return app.tr("Processing route");
            if (!app.navigationPageSeen)
                return app.tr("Tap to review maneuvers or begin navigating");
            return "";
        }
        verticalAlignment: Text.AlignTop
        wrapMode: Text.WordWrap
    }


    // information displayed while navigating
    LabelPL {
        // Distance remaining to the next maneuver
        id: manLabel
        anchors.left: iconImage.right
        anchors.leftMargin: iconImage.width > 0 || !app.portrait ? (app.portrait ? app.styler.themePaddingLarge : app.styler.themeHorizontalPageMargin) : 0
        anchors.rightMargin: app.styler.themePaddingLarge
        anchors.top: parent.top
        color: block.notify ? app.styler.themeHighlightColor : app.styler.themePrimaryColor
        font.family: block.notify ? app.styler.themeFontFamilyHeading : app.styler.themeFontFamily
        font.pixelSize: block.notify ? app.styler.themeFontSizeHuge : app.styler.themeFontSizeLarge
        height: text ? implicitHeight + app.styler.themePaddingMedium : 0
        text: app.mode === modes.navigate ? block.manDist : ""
        verticalAlignment: Text.AlignBottom
        states: [
            State {
                when: !app.portrait && block.destDist && block.notify
                AnchorChanges {
                    target: manLabel
                    anchors.left: undefined
                    anchors.right: parent.left
                    anchors.top: iconImage.bottom
                }
            }
        ]
    }

    LabelPL {
        // Estimated time of arrival: shown during navigation and exploreRoute
        id: destLabel
        anchors.baseline: manLabel.baseline
        anchors.right: parent.right
        anchors.rightMargin: app.styler.themeHorizontalPageMargin
        color: app.styler.themePrimaryColor
        font.pixelSize: app.styler.themeFontSizeLarge
        height: text ? implicitHeight + app.styler.themePaddingMedium : 0
        text: block.notify ? block.destEta : ""
        states: [
            State {
                when: !app.portrait && streetLabel.text
                AnchorChanges {
                    target: destLabel
                    anchors.baseline: streetLabel.baseline
                }
            },
            State {
                when: !app.portrait
                AnchorChanges {
                    target: destLabel
                    anchors.baseline: undefined
                    anchors.top: parent.top
                }
                PropertyChanges {
                    target: destLabel
                    verticalAlignment: Text.AlignBottom
                }
            }
        ]
    }

    LabelPL {
        // Estimated time of arrival: ETA label
        id: destEta
        anchors.baseline: destLabel.baseline
        anchors.right: destLabel.left
        anchors.rightMargin: app.styler.themePaddingSmall
        color: app.styler.themeSecondaryColor
        font.pixelSize: app.styler.themeFontSizeMedium
        text: app.tr("ETA")
        visible: destLabel.height
    }

    LabelPL {
        // Street name
        id: streetLabel
        anchors.left: iconImage.right
        anchors.leftMargin: iconImage.width > 0 ? app.styler.themePaddingLarge : 0
        anchors.right: parent.right
        anchors.rightMargin: app.portrait ? app.styler.themeHorizontalPageMargin : app.styler.themePaddingLarge
        anchors.top: manLabel.bottom
        color: app.styler.themePrimaryColor
        font.pixelSize: app.styler.themeFontSizeExtraLarge
        height: text ? implicitHeight + app.styler.themePaddingMedium : 0
        maximumLineCount: 1
        states: [
            State {
                when: !app.portrait
                AnchorChanges {
                    target: streetLabel
                    anchors.left: iconImage.width > manLabel.width ? iconImage.right : manLabel.right
                    anchors.right: destEta.left
                    anchors.top: parent.top
                }
                PropertyChanges {
                    target: streetLabel
                    verticalAlignment: Text.AlignBottom
                }
            }
        ]
        text: app.navigationPageSeen && block.notify ? streetName : ""
        truncMode: truncModes.fade
        verticalAlignment: Text.AlignTop

        property string streetName: {
            if (!block.street) return "";
            var s = "";
            for (var i in block.street) {
                if (s != "") s += "; "
                s += block.street[i];
            }
            return s;
        }
    }

    LabelPL {
        // Instruction text for the next maneuver
        id: narrativeLabel
        anchors.left: iconImage.right
        anchors.leftMargin: iconImage.width > 0 ? app.styler.themePaddingLarge : 0
        anchors.right: parent.right
        anchors.rightMargin: app.portrait ? app.styler.themeHorizontalPageMargin : app.styler.themePaddingLarge
        anchors.top: manLabel.bottom
        anchors.topMargin: app.styler.themePaddingSmall
        color: app.styler.themePrimaryColor
        font.pixelSize: app.styler.themeFontSizeMedium
        height: text ? implicitHeight + app.styler.themePaddingMedium : 0
        states: [
            State {
                when: !app.navigationPageSeen && app.modes === modes.exploreRoute
                AnchorChanges {
                    target: narrativeLabel
                    anchors.left: parent.left
                    anchors.right: destEta.left
                    anchors.top: totalTimeLabel.bottom
                }
            },
            State {
                when: !app.portrait
                AnchorChanges {
                    target: narrativeLabel
                    anchors.baseline: destLabel.baseline
                    anchors.left: iconImage.width > manLabel.width ? iconImage.right : manLabel.right
                    anchors.right: destEta.left
                    anchors.top: undefined
                }
            }
        ]
        text: block.notify && !streetLabel.text ? block.narrative : ""
        verticalAlignment: Text.AlignTop
        wrapMode: Text.WordWrap
    }

    Image {
        // Icon for the next maneuver
        id: iconImage
        anchors.left: parent.left
        anchors.leftMargin: app.styler.themeHorizontalPageMargin
        anchors.rightMargin: app.styler.themePaddingLarge
        anchors.top: parent.top
        anchors.topMargin: height ? app.styler.themePaddingLarge : 0
        fillMode: Image.Pad
        height: block.notify ? sourceSize.height : 0
        opacity: 0.9
        smooth: true
        source: block.notify ? "icons/navigation/%1-%2.svg".arg(block.icon || "flag").arg(app.styler.navigationIconsVariant) : ""
        sourceSize.height: (app.screenLarge ? 1.7 : 1) * app.styler.themeIconSizeLarge
        sourceSize.width: (app.screenLarge ? 1.7 : 1) * app.styler.themeIconSizeLarge
        states: [
            State {
                when: !app.portrait && block.destDist && block.notify && iconImage.width < manLabel.width
                AnchorChanges {
                    target: iconImage
                    anchors.left: undefined
                    anchors.horizontalCenter: manLabel.horizontalCenter
                }
            },
            State {
                when: !app.portrait && block.destDist && block.notify
                AnchorChanges {
                    target: iconImage
                    anchors.left: undefined
                    anchors.right: parent.right
                }
            }
        ]
        width: block.notify ? sourceSize.width : 0
    }

    onClicked: app.showNavigationPages();

    onSwipedOut: {
        app.setModeExplore();
        map.clearRoute();
    }
}
