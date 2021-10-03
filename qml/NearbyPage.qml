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

PagePL {
    id: page
    title: app.tr("Nearby Venues")

    acceptIconName: styler.iconNearby
    acceptText: app.tr("Search")
    canNavigateForward: page.near &&
                        (page.nearText !== app.tr("Current position") || gps.coordinateValid) &&
                        (page.queryType.length > 0 || page.queryName.length > 0)

    pageMenu: PageMenuPL {
        PageMenuItemPL {
            iconName: styler.iconPreferences
            text: app.tr("Change provider (%1)").arg(name)
            property string name: py.evaluate("poor.app.guide.name")
            onClicked: {
                var dialog = app.push(Qt.resolvedUrl("GuidePage.qml"));
                dialog.accepted.connect(function() {
                    name = py.evaluate("poor.app.guide.name");
                    column.addSetttings();
                });
            }
        }
    }

    property bool   initialized: false
    property alias  near: nearButton.coordinates
    property alias  nearText: nearButton.text
    property string queryType: ""
    property string queryName: ""
    property var    params: {}
    property real   radius: 1000

    // Offer a different selection of radii depending on the user's
    // preferred length units, but keep values as meters.

    property var radiusLabels: app.conf.units === "metric" ?
                                   ["500 m", "1 km", "2 km", "5 km", "10 km", "20 km", "50 km", "100 km"] :
                                   [ "¼ mi", "½ mi", "1 mi", "2 mi",  "5 mi", "10 mi", "20 mi",  "40 mi"]

    property var radiusValues: app.conf.units === "metric" ?
                                   [500, 1000, 2000, 5000, 10000, 20000, 50000, 100000] :
                                   [402,  805, 1609, 3219,  8047, 16093, 32187,  64374]

    Column {
        id: column
        spacing: styler.themePaddingMedium
        width: page.width

        property var settings: null

        RoutePoint {
            id: nearButton
            comment: app.tr("Select a reference location next to which you want to perform the search.")
            label: app.tr("Near")
            title: app.tr("Near location")
        }

        ComboBoxPL {
            id: radiusComboBox
            label: app.tr("Radius")
            model: [
                page.radiusLabels[0],
                page.radiusLabels[1],
                page.radiusLabels[2],
                page.radiusLabels[3],
                page.radiusLabels[4],
                page.radiusLabels[5],
                page.radiusLabels[6],
                page.radiusLabels[7] ]
            Component.onCompleted: {
                for (var i = 0; i < page.radiusValues.length; i++) {
                    if (page.radiusValues[i] === page.radius)
                        radiusComboBox.currentIndex = i;
                }
            }
            onCurrentIndexChanged: {
                page.radius = page.radiusValues[radiusComboBox.currentIndex];
            }
        }

        ValueButtonPL {
            id: typeButton
            label: app.tr("Type")
            height: Math.max(styler.themeItemSizeSmall, implicitHeight)
            value: page.queryType
            // Avoid putting label and value on different lines.
            width: 3 * parent.width
            onClicked: {
                var dialog = app.push(Qt.resolvedUrl("PlaceTypePage.qml"),
                                      {"query": queryType});
                dialog.accepted.connect(function() {
                    page.queryType = dialog.query;
                });
            }
        }

        ValueButtonPL {
            id: nameButton
            label: app.tr("Name")
            height: Math.max(styler.themeItemSizeSmall, implicitHeight)
            value: page.queryName
            // Avoid putting label and value on different lines.
            width: 3 * parent.width
            onClicked: {
                var dialog = app.push(Qt.resolvedUrl("PlaceNamePage.qml"),
                                      {"query": queryName});
                dialog.accepted.connect(function() {
                    page.queryName = dialog.query;
                });
            }
        }

        Component.onCompleted: column.addSetttings();

        function addSetttings() {
            // Add guide-specific settings from guide's own QML file.
            page.params = {};
            if (column.settings) column.settings.destroy();
            var uri = Qt.resolvedUrl(py.evaluate("poor.app.guide.settings_qml_uri"));
            if (!uri) return;
            var component = Qt.createComponent(uri);
            if (component.status === Component.Error) {
                console.log('Error while creating component');
                console.log(component.errorString());
                return null;
            }
            column.settings = component.createObject(column);
            if (!column.settings) return;
            column.settings.anchors.left = column.left;
            column.settings.anchors.right = column.right;
            column.settings.width = column.width;
        }
    }

    Component.onCompleted: {
        if (!page.near) {
            page.near = app.getPosition();
            page.nearText = app.tr("Current position");
        }
    }

    onQueryTypeChanged: py.call_sync("poor.app.history.add_place_type", [page.queryType])
    onQueryNameChanged: py.call_sync("poor.app.history.add_place_name", [page.queryName])

    onPageStatusActive: {
        var resultPage;
        if (!initialized) {
            resultPage = app.pushAttachedMain(Qt.resolvedUrl("NearbyResultsPage.qml"));
            resultPage.populated = false;
            initialized = true;
        }

        if (page.nearText === app.tr("Current position"))
            page.near = app.getPosition();
        resultPage = app.pages.nextPage();
        if (resultPage) resultPage.populated = false;
    }

}
