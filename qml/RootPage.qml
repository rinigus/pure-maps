/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2018 Rinigus
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

PageEmptyPL {
    id: page
    title: app.tr("Map")

    AttributionButton { id: attributionButton }
    BasemapButton { id: basemapButton }
    CenterButton { id: centerButton }
    Commander { id: commander }
    GeocodeButton { id: geocodeButton }
    Map {
        id: map
        accessToken: py.call_sync("poor.key.get_mapbox_key", [])
    }
    MenuButton { id: menuButton }
    Meters { id: meters }
    NavigateButton { id: navigateButton }
    NavigationBlock { id: navigationBlock }
    NavigationBlockLandscapeLeftShield { id: navigationBlockLandscapeLeftShield }
    NavigationInfoBlock { id: navigationInfoBlock }
    NavigationInfoBlockLandscapeLeftShield { id: navigationInfoBlockLandscapeLeftShield }
    NavigationInfoBlockLandscapeRightShield { id: navigationInfoBlockLandscapeRightShield }
    NavigationSign { id: navigationSign }
    NorthArrow { id: northArrow }
    Notification { id: notification }
    InfoPanel { id: infoPanel }
    Poi { id: pois }
    RemorsePopupPL { id: remorse; z: 1000 }
    ScaleBar { id: scaleBar }
    SpeedLimit { id: speedLimit }
    StreetName { id: streetName }
    ZoomLevel { id: zoomLevel }

    Component.onCompleted: {
        app.infoPanel = infoPanel;
        app.map = map;
        app.notification = notification;
        app.pois = pois;
        app.remorse = remorse;
        // connect modal dialog properties
        app.modalDialogBasemap = Qt.binding(function () { return basemapButton.openMenu; });
        // after all objects are initialized
        commander.parseCommandLine();
    }

    onPageStatusActive: {
        if (!app.infoActive) app.stateId = "";
    }
}
