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
        if (app.mode === modes.navigate || app.mode === modes.navigatePost)
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
    visible: app.mode === modes.exploreRoute || app.mode === modes.navigate ||
             app.mode === modes.navigatePost || app.mode === modes.followMe
    y: {
        var needed = (navigationButtonClear.visible ? 2*height : height);
        var p = parent.height/2 - needed/2;
        var proposed = p;
        if (scaleBar.opacity > 1e-5 && p < scaleBar.y + scaleBar.height && scaleBar.x < anchors.leftMargin + width)
            proposed = scaleBar.y + scaleBar.height;
        else if (p < attributionButton.y + attributionButton.height &&
                attributionButton.x < anchors.leftMargin + width)
            proposed = attributionButton.y + attributionButton.height;
        else if (p < referenceBlockTopLeft.y + referenceBlockTopLeft.height)
            proposed = referenceBlockTopLeft.y + referenceBlockTopLeft.height;
        if (proposed + needed < parent.height)
            return proposed; // buttons fit
        return p; // have to draw buttons over other elements
    }
    z: 900

    onClicked: {
        var notifyId = "navigationStartPause";
        if (app.mode === modes.followMe) {
            notification.flash(app.tr("Stopped to follow the movement"),
                               notifyId);
            app.navigator.followMe = false;
            app.resetMenu();
        } else if (app.mode === modes.navigate || app.mode === modes.navigatePost) {
            notification.flash(app.tr("Navigation paused"),
                               notifyId);
            app.navigator.running = false;
        } else {
            notification.flash(app.tr("Navigation started"),
                               notifyId);
            app.navigator.running = true;
        }
    }

    property bool hidden: ((app.infoPanelOpen ||
                            (map.cleanMode && !app.conf.mapModeCleanShowNavigationClear))
                           && !map.showNavButtons) || app.modalDialog
}
