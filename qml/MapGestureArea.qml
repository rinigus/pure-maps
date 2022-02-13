/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2018 Osmo Salomaa
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
import MapboxMap 1.0

MapboxMapGestureArea {
    id: area
    activeClickedGeo: true
    activeDoubleClickedGeo: true
    activePressAndHoldGeo: true

    property real degLatPerPixel: 0
    property real degLonPerPixel: 0

    onClickedGeo: {
        // Check clicked coordinates against any markers and
        // activate the associated action.
        area.degLonPerPixel = degLonPerPixel;
        area.degLatPerPixel = degLatPerPixel;

        // Toggle auto-center if position marker clicked.
        if (app.mode !== modes.navigate &&
                app.mode !== modes.followMe &&
                app.mode !== modes.navigatePost &&
                gps.ready &&
                area.coordinatesMatch(geocoordinate, gps.coordinate)) {
            map.autoCenter = !map.autoCenter;
            notification.flash(map.autoCenter ?
                                   app.tr("Auto-center on") :
                                   app.tr("Auto-center off"),
                               "centerButton"); // same ID as in CenterButton
            return;
        }

        // Show information bubble if POI marker clicked.
        var selectedPoi = null;
        pois.pois.forEach(function (poi){
            var dlon = (geocoordinate.longitude - poi.coordinate.longitude) / area.degLonPerPixel;
            var dlat = (geocoordinate.latitude - poi.coordinate.latitude) / area.degLatPerPixel;
            var dist2 = dlon*dlon + dlat*dlat;
            // select only if poi is closer than 30 pixels (dist2 is square of that)
            var ref = 30 * styler.themePixelRatio / map.devicePixelRatio
            ref = ref * ref;
            if (dist2 < ref && (selectedPoi == null || selectedPoi.dist2 > dist2)) {
                selectedPoi = { 'poi': poi, 'dist2': dist2 };
            }
        });
        if (selectedPoi && (app.mode === modes.navigate || app.mode === modes.followMe || app.mode === modes.navigatePost))
            return app.notification.flash(app.tr("Stop navigation to select POI"), "mapgesture poi")
        if (selectedPoi)
            return pois.show(selectedPoi.poi);

        // Hide any POI bubbles if background map clicked.
        if (app.poiActive)
            return pois.hide();
        // Change map mode
        map.cleanMode = !map.cleanMode;
        map.showNavButtons = !map.showNavButtons;
    }

    onDoubleClicked: {
        map.setZoomLevel(map.zoomLevel + 1, Qt.point(mouse.x, mouse.y));
    }

    onPressAndHoldGeo: {
        if (app.mode === modes.navigate || app.mode === modes.followMe || app.mode === modes.navigatePost)
            return app.notification.flash(app.tr("Stop navigation to select POI"), "mapgesture press and hold")

        var p = pois.add({ "x": geocoordinate.longitude,
                           "y": geocoordinate.latitude });
        if (!p) return;
        pois.show(p);
        var radius = Math.max(0.1*0.5*(map.height + map.width), 30)*map.metersPerPixel;
        py.call("poor.app.geocoder.reverse",
                [geocoordinate.longitude, geocoordinate.latitude, radius, 1],
                function(result) {
                    if (!result || !result.length) return;
                    var r = result[0];
                    var rpoi = pois.convertFromPython(r);
                    rpoi.poiId = p.poiId;
                    rpoi.coordinate = QtPositioning.coordinate(rpoi.y, rpoi.x);
                    pois.update(rpoi);
                });
    }

    function coordinatesMatch(a, b) {
        // Return true if coordinates match given a sufficient tap buffer.
        var epsLon = 30 * area.degLonPerPixel * styler.themePixelRatio / map.devicePixelRatio;
        var epsLat = 30 * area.degLatPerPixel * styler.themePixelRatio / map.devicePixelRatio;
        return (Math.abs(a.longitude - b.longitude) < epsLon &&
                Math.abs(a.latitude  - b.latitude ) < epsLat);

    }

}
