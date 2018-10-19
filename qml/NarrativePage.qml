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

import "js/util.js" as Util

PageListPL {
    id: page
    title: app.tr("Maneuvers")

    property bool partOfNavigationStack: true

    // Prevent list items from stealing focus.
    currentIndex: -1

    delegate: ListItemPL {
        id: listItem
        contentHeight: narrativeLabel.height + departLabel.height + arriveLabel.height + lengthLabel.height + 2.0*app.styler.themePaddingLarge

        Image {
            id: icon
            anchors.left: parent.left
            anchors.leftMargin: app.styler.themeHorizontalPageMargin
            anchors.top: spacer.bottom
            fillMode: Image.Pad
            height: narrativeLabel.height + departLabel.height + arriveLabel.height + lengthLabel.height
            horizontalAlignment: Image.AlignRight
            opacity: 0.9
            smooth: true
            source: "icons/navigation/%1-%2.svg".arg(model.icon).arg(app.styler.navigationIconsVariant)
            sourceSize.height: app.styler.themeIconSizeMedium
            sourceSize.width: app.styler.themeIconSizeMedium
            verticalAlignment: Image.AlignTop
        }

        Item {
            id: spacer
            height: app.styler.themePaddingLarge
        }

        LabelPL {
            id: narrativeLabel
            anchors.left: icon.right
            anchors.leftMargin: app.styler.themePaddingMedium
            anchors.right: parent.right
            anchors.rightMargin: app.styler.themeHorizontalPageMargin
            anchors.top: spacer.bottom
            color: (model.active || listItem.highlighted) ?
                       app.styler.themeHighlightColor : app.styler.themePrimaryColor
            font.pixelSize: app.styler.themeFontSizeSmall
            height: implicitHeight + app.styler.themePaddingSmall
            text: model.narrative
            verticalAlignment: Text.AlignTop
            wrapMode: Text.WordWrap
        }

        LabelPL {
            id: departLabel
            anchors.left: icon.right
            anchors.leftMargin: app.styler.themePaddingMedium
            anchors.right: parent.right
            anchors.rightMargin: app.styler.themeHorizontalPageMargin
            anchors.top: narrativeLabel.bottom
            color: app.styler.themeSecondaryColor
            font.pixelSize: app.styler.themeFontSizeSmall
            height: text ? implicitHeight + app.styler.themePaddingSmall : 0
            text: model.depart_instruction ? model.depart_instruction : ""
            verticalAlignment: Text.AlignTop
            wrapMode: Text.WordWrap
        }

        LabelPL {
            id: arriveLabel
            anchors.left: icon.right
            anchors.leftMargin: app.styler.themePaddingMedium
            anchors.right: parent.right
            anchors.rightMargin: app.styler.themeHorizontalPageMargin
            anchors.top: departLabel.bottom
            color: app.styler.themeSecondaryColor
            font.pixelSize: app.styler.themeFontSizeSmall
            height: text ? implicitHeight + app.styler.themePaddingSmall : 0
            text: model.arrive_instruction ? model.arrive_instruction : ""
            verticalAlignment: Text.AlignTop
            wrapMode: Text.WordWrap
        }

        LabelPL {
            id: lengthLabel
            anchors.left: icon.right
            anchors.leftMargin: app.styler.themePaddingMedium
            anchors.right: parent.right
            anchors.rightMargin: app.styler.themeHorizontalPageMargin
            anchors.top: arriveLabel.bottom
            anchors.topMargin: app.styler.themePaddingSmall
            color: app.styler.themeSecondaryColor
            font.pixelSize: app.styler.themeFontSizeSmall
            height: implicitHeight + app.styler.themePaddingSmall
            lineHeight: 1.15
            text: model.index < page.model.count - 1 ?
                      app.tr("Continue for %1.", model.length) : ""
            truncMode: truncModes.fade
            verticalAlignment: Text.AlignTop
        }

        onClicked: {
            app.setModeExplore();
            map.setCenter(model.x, model.y);
            map.zoomLevel < 15 && map.setZoomLevel(15);
            app.hideNavigationPages();
        }

    }

    model: ListModel {}

    onPageStatusActivating: page.populate();

    function populate() {
        // Load narrative from the Python backend.
        page.model.clear();
        var args = [map.center.longitude, map.center.latitude];
        py.call("poor.app.narrative.get_maneuvers", args, function(maneuvers) {
            Util.appendAll(page.model, maneuvers);
            app.narrativePageSeen && page.scrollToActive();
            app.narrativePageSeen = true;
        });
    }

    function scrollToActive() {
        // Scroll view to the active maneuver.
        for (var i = 0; i < page.model.count; i++) {
            page.model.get(i).active &&
                    page.positionViewAtIndex(i);
        }
    }

}
