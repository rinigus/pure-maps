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
import QtPositioning 5.4
import QtGraphicalEffects 1.0

import "js/util.js" as Util

MouseArea {
    id: master
    anchors.left: parent.left
    anchors.top: referenceBlockTopLeft.bottom
    enabled: !hidden
    height: 2*(styler.themePaddingLarge + styler.themePaddingSmall) +
            (_rotate ? scaleBar.scaleBarMaxLength : scaleBar.height)
    states: [
        State {
            when: (app.mode === modes.navigate || app.mode === modes.followMe || app.mode === modes.navigatePost) &&
                  streetName.visible && streetName.x+streetName.width > x
            AnchorChanges {
                target: master
                anchors.bottom: streetName.top
                anchors.left: undefined
                anchors.right: parent.right
                anchors.top: undefined
            }
        },
        State {
            when: (app.mode === modes.navigate || app.mode === modes.followMe || app.mode === modes.navigatePost)
            AnchorChanges {
                target: master
                anchors.bottom: referenceBlockBottomRight.top
                anchors.left: undefined
                anchors.right: parent.right
                anchors.top: undefined
            }
        }
    ]
    opacity: hidden ? 0 : 1
    visible: !app.modalDialog
    width: 2*(styler.themePaddingLarge + styler.themePaddingSmall) +
           (_rotate ? scaleBar.height : scaleBar.scaleBarMaxLength)
    z: 300

    property bool hidden: app.modalDialog || app.infoPanelOpen ||
                          (!_recentlyUpdated && map.cleanMode && !app.conf.mapModeCleanShowScale)

    property bool _recentlyUpdated: false
    property bool _rotate: !((app.mode === modes.navigate || app.mode === modes.followMe || app.mode === modes.navigatePost) && !app.portrait)

    Behavior on opacity { NumberAnimation { property: "opacity"; duration: app.conf.animationDuration; } }

    Timer {
        id: updateTimer
        interval: 3000
        repeat: true
        running: _recentlyUpdated
        onTriggered: {
            if (_recentlyUpdated)
                _recentlyUpdated = false;
        }
    }

    Item {
        id: scaleBar
        anchors.centerIn: parent
        height: base.height + text.anchors.bottomMargin + text.height
        width: scaleBar.scaleWidth
        opacity: 0.9
        visible: scaleWidth > 0

        transform: Rotation {
            angle: _rotate ? 90 : 0
            origin.x: scaleBar.width/2
            origin.y: scaleBar.height/2
        }

        property real   _prevDist: 0
        property real   _thickness: styler.themeFontSizeOnMap / 8.0
        property int    scaleBarMaxLength: Math.min(map.height,map.width) / 4
        property real   scaleWidth: 0
        property string text: ""

        Rectangle {
            id: base
            anchors.bottom: scaleBar.bottom
            color: styler.fg
            height: scaleBar._thickness
            width: scaleBar.scaleWidth
        }

        Rectangle {
            id: left
            anchors.bottom: base.top
            anchors.left: base.left
            color: styler.fg
            height: scaleBar._thickness * 3
            width: scaleBar._thickness
        }

        Rectangle {
            id: right
            anchors.bottom: base.top
            anchors.right: base.right
            color: styler.fg
            height: scaleBar._thickness * 3
            width: scaleBar._thickness
        }

        Text {
            id: text
            anchors.bottom: base.top
            anchors.bottomMargin: scaleBar._thickness
            anchors.horizontalCenter: base.horizontalCenter
            color: styler.fg
            font.bold: true
            font.family: "sans-serif"
            font.pixelSize: styler.themeFontSizeOnMap
            horizontalAlignment: Text.AlignHCenter
            text: scaleBar.text
        }

        Image {
            anchors.bottom: right.top
            anchors.bottomMargin: styler.themePaddingMedium
            anchors.horizontalCenter: _rotate ? left.horizontalCenter : right.horizontalCenter
            height: sourceSize.height
            layer.enabled: true
            layer.effect: DropShadow {
                color: styler.shadowColor
                opacity: styler.shadowOpacity
                radius: styler.shadowRadius
                samples: 1 + radius*2
            }
            smooth: true
            source: app.getIcon("icons/indicator", true)
            sourceSize.height: styler.indicatorSize
            sourceSize.width: styler.indicatorSize
            visible: map.autoZoom
            width: sourceSize.width
        }


        Component.onCompleted: scaleBar.update()

        function roundedDistace(dist) {
            // Return dist rounded to an even amount of user-visible units,
            // but keeping the value as meters.
            if (app.conf.units === "american")
                // Round to an even amount of miles or feet.
                return dist >= 1609.34 ?
                            Util.sigfloor(dist / 1609.34, 1) * 1609.34 :
                            Util.sigfloor(dist * 3.28084, 1) / 3.28084;
            if (app.conf.units === "british")
                // Round to an even amount of miles or yards.
                return dist >= 1609.34 ?
                            Util.sigfloor(dist / 1609.34, 1) * 1609.34 :
                            Util.sigfloor(dist * 1.09361, 1) / 1.09361;
            // Round to an even amount of kilometers or meters.
            return Util.sigfloor(dist, 1);
        }

        function update() {
            var dist = map.metersPerPixel * scaleBarMaxLength;
            dist = scaleBar.roundedDistace(dist);
            scaleBar.scaleWidth = dist / map.metersPerPixel;
            if (Math.abs(dist - _prevDist) < 1e-1) return;
            scaleBar.text = py.call_sync("poor.util.format_distance", [dist, 1]);
            _prevDist = dist;
            _recentlyUpdated = true;
            updateTimer.restart(); // restart as needed
        }

    }

    Connections {
        target: app.conf
        onUnitsChanged: scaleBar.update()
    }

    Connections {
        target: map
        onAutoCenterChanged: if (!map.autoCenter) setAutoZoom(false)
        onMetersPerPixelChanged: scaleBar.update();
        onHeightChanged: scaleBar.update();
        onWidthChanged: scaleBar.update();
    }

    onClicked: {
        if (hidden) return;
        if (!map.autoCenter) {
            notification.flash(app.tr("Auto-zoom requires auto-centering to be enabled"),
                               'scale');
            return;
        }
        setAutoZoom(!map.autoZoom)
    }

    function setAutoZoom(az) {
        if (map.autoZoom === az) return;
        map.autoZoom = az;
        notification.flash(map.autoZoom ?
                               app.tr("Auto-zoom on") :
                               app.tr("Auto-zoom off"),
                           'scale');
    }
}
