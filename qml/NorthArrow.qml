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
import "."
import "platform"

MapButton {
    id: master
    anchors.right: parent.right
    enabled: !hidden
    iconHeight: styler.themeIconSizeSmall
    iconRotation: -map.bearing
    iconSource: app.getIcon("icons/north")
    indicator: map.autoRotate
    opacity: hidden ? 0 : 1
    y: {
        if (app.mode === modes.navigate || app.mode === modes.followMe || app.mode === modes.navigatePost) {
            if (!app.portrait)
                return navigationSign.y + navigationSign.height;
            return (parent.height - height)/2;
        }
        var p = parent.height/2 - height;
        // to avoid binding loops with basemap button
        var bmy = navigationSign.y + navigationSign.height + meters.anchors.topMargin +
                meters.height + styler.themePaddingLarge + basemapButton.height;
        if (p < bmy)
            return bmy;
        return p;
    }
    z: 500

    property bool hidden: app.modalDialog || app.infoPanelOpen || (Math.abs(master.iconRotation) < 0.01 && map.cleanMode && !app.conf.mapModeCleanShowCompass)

    Behavior on opacity { NumberAnimation { property: "opacity"; duration: app.conf.animationDuration; } }

    Connections {
        target: map
        onAutoCenterChanged: if (!map.autoCenter) setAutoRotate(false)
    }

    onClicked: {
        if (hidden) return;
        if (!map.autoCenter) {
            notification.flash(app.tr("Auto-rotation requires auto-centering to be enabled"),
                               "northArrow");
            return;
        }
        setAutoRotate(!map.autoRotate)
    }

    function setAutoRotate(ar) {
        if (ar === map.autoRotate) return;
        map.autoRotate = ar;
        notification.flash(map.autoRotate ?
                               app.tr("Auto-rotate on") :
                               app.tr("Auto-rotate off"),
                           "northArrow");
    }

}
