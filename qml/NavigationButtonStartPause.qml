/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2019 Rinigus, 2019 Purism SPC
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

MapButton {
    id: button
    anchors.left: parent.left
    anchors.right: undefined
    iconHeight: styler.themeIconSizeSmall
    iconSource: {
        if (app.mode === modes.followMe)
            return app.getIcon("icons/navigation-stop");
        if (app.mode === modes.navigate)
            return app.getIcon("icons/navigation-pause");
        return app.getIcon("icons/navigation-start");
    }
    states: [
        State {
            when: hidden
            AnchorChanges {
                target: button
                anchors.left: undefined
                anchors.right: parent.left
            }
        }
    ]
    transitions: Transition {
        AnchorAnimation { duration: app.conf.animationDuration; }
    }
    visible: app.mode === modes.exploreRoute || app.mode === modes.navigate || app.mode === modes.followMe
    y: {
        var p = parent.height/2 - (navigationButtonClear.visible ? height : height/2);
        if (scaleBar.opacity > 1e-5 && p < scaleBar.y + scaleBar.height && scaleBar.x < anchors.leftMargin + width)
            return scaleBar.y + scaleBar.height;
        if (p < attributionButton.y + attributionButton.height &&
                attributionButton.x < anchors.leftMargin + width)
            return attributionButton.y + attributionButton.height;
        if (p < referenceBlockTopLeft.y + referenceBlockTopLeft.height)
            return referenceBlockTopLeft.y + referenceBlockTopLeft.height;
        return p;
    }
    z: 900

    onClicked: {
        var notifyId = "navigationStartPause";
        if (app.mode === modes.followMe) {
            notification.flash(app.tr("Stopped to follow the movement"),
                               notifyId);
            app.setModeExplore();
            app.resetMenu();
        } else if (app.mode === modes.navigate) {
            notification.flash(app.tr("Navigation paused"),
                               notifyId);
            app.setModeExploreRoute();
        } else {
            notification.flash(app.tr("Navigation started"),
                               notifyId);
            app.setModeNavigate();
        }
    }

    property bool hidden: ((app.infoPanelOpen ||
                            (map.cleanMode && !app.conf.mapModeCleanShowNavigationClear))
                           && !map.showNavButtons) || app.modalDialog
}
