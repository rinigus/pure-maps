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
import Sailfish.Silica 1.0

Rectangle {
    id: block
    anchors.left: parent.left
    anchors.right: parent.right
    anchors.top: parent.top
    color: "#e6000000"
    height: {
        if (!destDist) return 0;
        if (!app.portrait && notify) {
            var h1 = Theme.paddingMedium + Theme.fontSizeLarge - Theme.fontSizeMedium + narrativeLabel.height;
            var h2 = Theme.paddingMedium + destLabel.height;
            var h3 = streetLabel.height;
            return Math.max(h1, h2, h3);
        } else {
            var h1 = iconImage.height + 2 * Theme.paddingLarge;
            var h2 = manLabel.height + Theme.paddingSmall + narrativeLabel.height;
            var h3 = manLabel.height + streetLabel.height;
            // If far off route, manLabel defines the height of the block,
            // but we need padding to make a sufficiently large tap target.
            var h4 = notify ? 0 : manLabel.height + Theme.paddingMedium;
            return Math.max(h1, h2, h3, h4);
        }
    }
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
    z: 500

    property string destDist:  app.navigationStatus.destDist
    property string destEta:   app.navigationStatus.destEta
    property string destTime:  app.navigationStatus.destTime
    property string icon:      app.navigationStatus.icon
    property string manDist:   app.navigationStatus.manDist
    property string manTime:   app.navigationStatus.manTime
    property string narrative: app.navigationStatus.narrative
    property bool   notify:    app.navigationStatus.notify
    property var    street:    app.navigationStatus.street
    property int    shieldLeftHeight: !app.portrait && destDist && notify ? manLabel.height + Theme.paddingMedium + iconImage.height + iconImage.anchors.topMargin : 0
    property int    shieldLeftWidth:  !app.portrait && destDist && notify ? manLabel.anchors.leftMargin + Theme.paddingLarge + Math.max(manLabel.width, iconImage.width) : 0

    Label {
        // Distance remaining to the next maneuver
        id: manLabel
        anchors.left: iconImage.right
        anchors.leftMargin: iconImage.width > 0 || !app.portrait ? (app.portrait ? Theme.paddingLarge : Theme.horizontalPageMargin) : 0
        anchors.rightMargin: Theme.paddingLarge
        anchors.top: parent.top
        color: block.notify ? Theme.highlightColor : Theme.primaryColor
        font.family: block.notify ? Theme.fontFamilyHeading : Theme.fontFamily
        font.pixelSize: block.notify ? Theme.fontSizeHuge : Theme.fontSizeMedium
        height: block.destDist ? implicitHeight + Theme.paddingMedium : 0
        text: block.manDist
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

    Label {
        // Estimated time of arrival
        id: destLabel
        anchors.baseline: manLabel.baseline
        anchors.right: parent.right
        anchors.rightMargin: Theme.horizontalPageMargin
        color: Theme.primaryColor
        font.pixelSize: Theme.fontSizeLarge
        height: block.destDist ? implicitHeight + Theme.paddingMedium : 0
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

    Label {
        // Estimated time of arrival: ETA label
        id: destEta
        anchors.baseline: destLabel.baseline
        anchors.right: destLabel.left
        anchors.rightMargin: Theme.paddingSmall
        color: Theme.secondaryColor
        font.pixelSize: Theme.fontSizeMedium
        text: app.tr("ETA")
        visible: block.notify
    }

    Label {
        // Street name
        id: streetLabel
        anchors.left: iconImage.right
        anchors.leftMargin: iconImage.width > 0 ? Theme.paddingLarge : 0
        anchors.right: parent.right
        anchors.rightMargin: app.portrait ? Theme.horizontalPageMargin : Theme.paddingLarge
        anchors.top: manLabel.bottom
        color: Theme.primaryColor
        font.pixelSize: Theme.fontSizeExtraLarge
        height: text ? implicitHeight + Theme.paddingMedium : 0
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
            }
        ]
        text: app.navigationPageSeen && block.notify ? streetName : ""
        truncationMode: TruncationMode.Fade
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

    Label {
        // Instruction text for the next maneuver
        id: narrativeLabel
        anchors.left: iconImage.right
        anchors.leftMargin: iconImage.width > 0 ? Theme.paddingLarge : 0
        anchors.right: parent.right
        anchors.rightMargin: app.portrait ? Theme.horizontalPageMargin : Theme.paddingLarge
        anchors.top: manLabel.bottom
        anchors.topMargin: Theme.paddingSmall
        color: Theme.primaryColor
        font.pixelSize: Theme.fontSizeMedium
        height: text ? implicitHeight + Theme.paddingMedium : 0
        states: [
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
        text: app.navigationPageSeen ?
            (block.notify && !streetLabel.text ? block.narrative : "") :
            (block.notify ? app.tr("Tap to review maneuvers or begin navigating") : "")
        verticalAlignment: Text.AlignTop
        wrapMode: Text.WordWrap
    }

    Image {
        // Icon for the next maneuver
        id: iconImage
        anchors.left: parent.left
        anchors.leftMargin: Theme.horizontalPageMargin
        anchors.rightMargin: Theme.paddingLarge
        anchors.top: parent.top
        anchors.topMargin: height ? Theme.paddingLarge : 0
        fillMode: Image.Pad
        height: block.notify ? sourceSize.height : 0
        opacity: 0.9
        smooth: true
        source: block.notify ? "icons/navigation/%1.svg".arg(block.icon || "flag") : ""
        sourceSize.height: (Screen.sizeCategory >= Screen.Large ? 1.7 : 1) * Theme.iconSizeLarge
        sourceSize.width: (Screen.sizeCategory >= Screen.Large ? 1.7 : 1) * Theme.iconSizeLarge
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

    MouseArea {
        anchors.fill: parent
        onClicked: app.showNavigationPages();
    }

}
