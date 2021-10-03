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

    height: visible ? mainRect.height + mainRect.anchors.topMargin : 0
    visible: !app.modalDialog && app.mode === modes.navigate
    z: 400

    property string icon:      app.navigator.icon
    property string manDist:   app.navigator.manDist
    property string manTime:   app.navigator.manTime
    // difference in height between main and shields if the shield's
    // rectangle sticks out. zero otherwise
    property real   marginExtraLeft: {
        var le = leftShield.visible ? Math.max(leftShield.height + leftShield.anchors.topMargin -
                                               (mainRect.height + mainRect.anchors.topMargin), 0) : 0;
        var ln = nextAfterNextShield.visible ? nextAfterNextShield.height +
                                               nextAfterNextShield.anchors.topMargin : 0;
        return le + ln;
    }
    property real   marginExtraLeftSide: {
        var le = leftShield.visible ? leftShield.width + leftShield.anchors.leftMargin : 0;
        var ln = nextAfterNextShield.visible ? nextAfterNextShield.width +
                                               nextAfterNextShield.anchors.leftMargin : 0;
        return Math.max(le, ln);
    }
    property real   marginExtraRight: speedShield.visible ?
                                          Math.max(speedShield.height + speedShield.anchors.topMargin -
                                                   (mainRect.height + mainRect.anchors.topMargin), 0) : 0
    property real   marginExtraRightSide: speedShield.visible ? speedShield.width + speedShield.anchors.rightMargin : 0
    property string narrative: app.navigator.narrative
    property bool   nextAfterNextVisible: notify && nextIcon
    property string nextIcon:  app.navigator.nextIcon
    property string nextManDist:  app.navigator.nextManDist
    property bool   notify:    app.navigator.notify
    property int    roundaboutExit: app.navigator.roundaboutExit
    property var    street:    app.navigator.street

    // press feedback
    property var    _colorBg: _pressed ? styler.blockPressed : styler.blockBg
    property bool   _pressed: mainRectMouse.pressed || leftShieldMouse.pressed ||
                              speedShieldMouse.pressed || nextAfterNextShieldMouse.pressed

    Rectangle {
        id: mainRect
        anchors.top: parent.top
        anchors.topMargin: -radius
        color: _colorBg
        height: {
            if (!block.notify) return styler.themePaddingMedium + manLabel.height + radius;
            if (app.portrait) {
                var h0 = styler.themePaddingMedium + styler.themePaddingLarge + iconImage.height;
                var h1 = styler.themePaddingMedium + manLabel.height + streetLabel.height + narrativeLabel.height;
                return Math.max(h0, h1) + radius;
            }
            return styler.themePaddingMedium + streetLabel.height + narrativeLabel.height + radius;
        }
        radius: width < parent.width ? styler.radius : 0
        width: {
            if (!app.portrait) {
                var sp = speedShield.x - styler.themePaddingLarge*3;
                var p = 0;
                if (!block.notify) {
                    if (!manLabel.truncated) {
                        p = manLabel.x + manLabel.anchors.leftMargin + manLabel.implicitWidth;
                        if (p < sp)
                            return p + 2*styler.themePaddingLarge;
                    }
                } else if (streetLabel.text) {
                    if (!streetLabel.truncated) {
                        p = streetLabel.x + streetLabel.anchors.leftMargin + streetLabel.implicitWidth;
                        if (p < sp)
                            return p + 2*styler.themePaddingLarge;
                    }
                } else if (narrativeLabel.text && !narrativeLabel.truncated) {
                    p = narrativeLabel.x + narrativeLabel.anchors.leftMargin + narrativeLabel.implicitWidth;
                    if (p < sp)
                        return p + 2*styler.themePaddingLarge;
                }
            }
            return parent.width;
        }
        x: -radius

        MouseArea {
            id: mainRectMouse
            anchors.fill: parent
            onClicked: block.openNavigation()
        }
    }

    Rectangle {
        id: leftShield
        anchors.top: parent.top
        anchors.topMargin: -radius
        anchors.left: parent.left
        anchors.leftMargin: -radius
        color: _colorBg
        height: manLabel.height + styler.themePaddingMedium +
                iconImage.height + iconImage.anchors.topMargin + radius
        radius: styler.radius
        visible: !app.portrait &&  leftShield.height > mainRect.height && block.notify
        width: manLabel.anchors.leftMargin + styler.themePaddingLarge +
               contentWidth + radius
        property int contentWidth: Math.max(manLabel.width, iconImage.width)
        MouseArea {
            id: leftShieldMouse
            anchors.fill: parent
            onClicked: block.openNavigation()
        }
    }

    Rectangle {
        id: speedShield
        anchors.top: parent.top
        anchors.topMargin: -radius
        anchors.right: block.right
        anchors.rightMargin: -radius
        color: _colorBg
        height: speed.height + styler.themePaddingMedium + radius
        radius: styler.radius
        visible: speed.text && (speedShield.height > mainRect.height || mainRect.width < parent.width) ? true : false
        width: speed.width + styler.themePaddingLarge +
               speedUnit.width + styler.themePaddingSmall +
               styler.themeHorizontalPageMargin + radius

        MouseArea {
            id: speedShieldMouse
            anchors.fill: parent
            onClicked: block.openNavigation()
        }
    }

    Rectangle {
        id: nextAfterNextShield
        anchors.top: leftShield.visible ? leftShield.bottom : mainRect.bottom
        anchors.topMargin:  -radius
        anchors.left: parent.left
        anchors.leftMargin: -radius
        color: _colorBg
        height: visible ? iconNextImage.height + nextManDistLabel.height + 2*radius : 0
        radius: styler.radius
        visible: nextAfterNextVisible
        width: Math.max(iconNextImage.width, nextManDistLabel.width) +
               styler.themeHorizontalPageMargin +
               2*radius
        MouseArea {
            id: nextAfterNextShieldMouse
            anchors.fill: parent
            onClicked: block.openNavigation()
        }
    }

    Image {
        // Icon for the next maneuver
        id: iconImage
        anchors.left: parent.left
        anchors.leftMargin: {
            if (!app.portrait)
                return styler.themeHorizontalPageMargin + (leftShield.contentWidth-width)/2;
            return styler.themeHorizontalPageMargin;
        }
        anchors.rightMargin: styler.themePaddingLarge
        anchors.top: parent.top
        anchors.topMargin: styler.themePaddingLarge
        fillMode: Image.Pad
        height: block.notify ? sourceSize.height : 0
        opacity: 0.9
        smooth: true
        source: block.notify ? "icons/navigation/%1-%2.svg".arg(block.icon || "flag").arg(styler.navigationIconsVariant) : ""
        sourceSize.height: (app.screenLarge ? 1.7 : 1) * styler.themeIconSizeLarge
        sourceSize.width: (app.screenLarge ? 1.7 : 1) * styler.themeIconSizeLarge
        width: block.notify ? sourceSize.width : 0

        LabelPL {
            // roundabout exit if available
            anchors.centerIn: parent
            color: styler.themePrimaryColor
            font.family: styler.themeFontFamily
            font.pixelSize: parent.height / 4
            text: roundaboutExit
            visible: block.notify && roundaboutExit > 0
        }
    }

    LabelPL {
        // Distance to road label
        id: distToRoadLabel
        anchors.left: parent.left
        anchors.leftMargin: styler.themeHorizontalPageMargin
        anchors.baseline: manLabel.baseline
        color: _pressed ? styler.themeSecondaryHighlightColor : styler.themeSecondaryColor
        font.pixelSize: styler.themeFontSizeSmall
        text: app.tr("To route")
        visible: !block.notify
        width: visible ? implicitWidth : 0
    }

    LabelPL {
        // Distance remaining to the next maneuver
        id: manLabel
        anchors.left: iconImage.right
        anchors.leftMargin: {
            if (distToRoadLabel.visible) return styler.themePaddingSmall;
            if (!app.portrait)
                return styler.themeHorizontalPageMargin + (leftShield.contentWidth-width)/2;
            return styler.themePaddingLarge;
        }
        anchors.top: parent.top
        color: block.notify || _pressed ? styler.themeHighlightColor : styler.themePrimaryColor
        font.family: block.notify ? styler.themeFontFamilyHeading : styler.themeFontFamily
        font.pixelSize: block.notify ? styler.themeFontSizeHuge : styler.themeFontSizeLarge
        height: text ? implicitHeight + styler.themePaddingMedium : 0
        text: block.manDist
        verticalAlignment: Text.AlignBottom
        states: [
            State {
                when: !block.notify
                AnchorChanges {
                    target: manLabel
                    anchors.left: distToRoadLabel.right
                    anchors.top: parent.top
                }
            },
            State {
                when: !app.portrait && block.notify
                AnchorChanges {
                    target: manLabel
                    anchors.left: parent.left
                    anchors.top: iconImage.bottom
                }
            }
        ]
    }

    LabelPL {
        // Street name
        id: streetLabel
        anchors.left: iconImage.right
        anchors.leftMargin: iconImage.width > 0 ? styler.themePaddingLarge : 0
        anchors.right: parent.right
        anchors.rightMargin: app.portrait ? styler.themeHorizontalPageMargin : styler.themePaddingLarge
        anchors.top: manLabel.bottom
        color: _pressed ? styler.themeHighlightColor : styler.themePrimaryColor
        font.pixelSize: styler.themeFontSizeExtraLarge
        height: text ? implicitHeight + styler.themePaddingMedium : 0
        maximumLineCount: 1
        states: [
            State {
                when: !app.portrait
                AnchorChanges {
                    target: streetLabel
                    anchors.left: iconImage.width > manLabel.width ? iconImage.right : manLabel.right
                    anchors.right: speed.left
                    anchors.top: parent.top
                }
                PropertyChanges {
                    target: streetLabel
                    verticalAlignment: Text.AlignBottom
                }
            }
        ]
        text: block.notify ? streetName : ""
        truncMode: truncModes.fade
        verticalAlignment: Text.AlignTop

        property string streetName: block.street ? block.street : ""
    }

    LabelPL {
        // Instruction text for the next maneuver
        id: narrativeLabel
        anchors.left: iconImage.right
        anchors.leftMargin: iconImage.width > 0 ? styler.themePaddingLarge : 0
        anchors.right: parent.right
        anchors.rightMargin: app.portrait ? styler.themeHorizontalPageMargin : styler.themePaddingLarge
        anchors.top: manLabel.bottom
        anchors.topMargin: styler.themePaddingSmall
        color: _pressed ? styler.themeHighlightColor : styler.themePrimaryColor
        font.pixelSize: styler.themeFontSizeMedium
        height: text ? implicitHeight + styler.themePaddingMedium : 0
        states: [
            State {
                when: !app.portrait
                AnchorChanges {
                    target: narrativeLabel
                    anchors.left: iconImage.width > manLabel.width ? iconImage.right : manLabel.right
                    anchors.right: speed.left
                    anchors.top: parent.top
                }
            }
        ]
        text: !streetLabel.text && block.notify ? block.narrative : ""
        verticalAlignment: Text.AlignTop
        wrapMode: Text.WordWrap
    }


    LabelPL {
        // speed
        id: speed
        anchors.right: speedUnit.left
        anchors.rightMargin: styler.themePaddingSmall
        anchors.top: parent.top
        color: _pressed ? styler.themeHighlightColor : styler.themePrimaryColor
        font.pixelSize: styler.themeFontSizeHuge
        height: implicitHeight + styler.themePaddingMedium
        text: {
            if (!gps.speedValid)
                return "";

            if (app.conf.units === "american")
                return "%1".arg(Math.round(gps.speed * 2.23694));
            else if (app.conf.units === "british")
                return "%1".arg(Math.round(gps.speed * 2.23694));
            return "%1".arg(Math.round(gps.speed * 3.6)); // km/h
        }
        verticalAlignment: Text.AlignBottom
    }

    LabelPL {
        // speed unit
        id: speedUnit
        anchors.baseline: speed.baseline
        anchors.right: parent.right
        anchors.rightMargin: styler.themeHorizontalPageMargin
        color: _pressed ? styler.themeSecondaryHighlightColor : styler.themeSecondaryColor
        font.pixelSize: styler.themeFontSizeMedium
        text: {
            if (app.conf.units === "american") return app.tr("mph");
            else if (app.conf.units === "british") return app.tr("mph");
            return app.tr("km/h")
        }
        visible: speed.text ? true : false
    }

    Image {
        // Icon for the maneuver next after next
        id: iconNextImage
        x: (nextAfterNextShield.width + nextAfterNextShield.anchors.leftMargin)/2 - width/2
        anchors.top: nextAfterNextShield.top
        anchors.topMargin: -nextAfterNextShield.anchors.topMargin
        fillMode: Image.Pad
        height: visible ? sourceSize.height : 0
        opacity: 0.9
        smooth: true
        source: visible ? "icons/navigation/%1-%2.svg".arg(block.nextIcon).arg(styler.navigationIconsVariant) : ""
        sourceSize.height: (app.screenLarge ? 1.7 : 1) * styler.themeIconSizeLarge * 0.5
        sourceSize.width: (app.screenLarge ? 1.7 : 1) * styler.themeIconSizeLarge * 0.5
        visible: nextAfterNextVisible
        width: visible ? sourceSize.width : 0
    }

    LabelPL {
        // Distance for the maneuver next after next
        id: nextManDistLabel
        anchors.horizontalCenter: iconNextImage.horizontalCenter
        anchors.top: iconNextImage.bottom
        color: block.notify || _pressed ? styler.themeHighlightColor : styler.themePrimaryColor
        font.family: block.notify ? styler.themeFontFamilyHeading : styler.themeFontFamily
        font.pixelSize: styler.themeFontSizeLarge
        height: text ? implicitHeight + styler.themePaddingMedium : 0
        text: block.nextManDist
        verticalAlignment: Text.AlignBottom
        visible: nextAfterNextVisible && text
    }

    function openNavigation() {
        if (visible) app.showNavigationPages()
    }
}
