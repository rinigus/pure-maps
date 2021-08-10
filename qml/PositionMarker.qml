/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2018 Osmo Salomaa, 2018 Rinigus
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
import "."

Item {
    id: marker

    property bool directionVisible: false
    property var  position: QtPositioning.coordinate(49, 13)
    property var  positionShown

    property bool _animatePosition: app.conf.smoothPositionAnimationWhenNavigating &&
                                    (app.mode === modes.navigate || app.mode === modes.followMe || app.mode === modes.navigatePost) &&
                                    map.animationTime > 0

    readonly property var images: QtObject {
        readonly property string moving: "pure-position-moving"
        readonly property string still:  "pure-position-still"
    }

    readonly property var layers: QtObject {
        readonly property string moving: "pure-position-moving"
        readonly property string uncertainty:  "pure-position-uncertainty"
        readonly property string still:  "pure-position-still"
    }

    readonly property string source: "pure-position"

    CoordinateAnimation {
        id: animate
        duration: map.animationTime
        easing.type: Easing.Linear
        target: marker
        property: "positionShown"
    }

    Connections {
        target: map
        onDirectionChanged: marker.updateDirection()
        onMetersPerPixelChanged: marker.updateUncertainty()
    }

    Connections {
        target: gps
        onPositionChanged: {
            if (!positionShown || !marker._animatePosition) {
                positionShown = QtPositioning.coordinate(gps.position.coordinate.latitude, gps.position.coordinate.longitude);
                marker.position = QtPositioning.coordinate(gps.position.coordinate.latitude, gps.position.coordinate.longitude);
                animate.from = marker.position;
                animate.to = marker.position;
            } else {
                animate.complete();
                marker.position = animate.to;
                animate.from = QtPositioning.coordinate(marker.position.latitude, marker.position.longitude);
                animate.to = QtPositioning.coordinate(gps.position.coordinate.latitude, gps.position.coordinate.longitude);
                animate.start();
                marker.position = QtPositioning.coordinate(gps.position.coordinate.latitude, gps.position.coordinate.longitude);
            }
        }
    }

    Component.onCompleted: {
        marker.initIcons();
        marker.initLayers();
        marker.configureLayers();
        marker.updateDirection();
        marker.updateUncertainty();
    }

    onPositionShownChanged: {
        if (!positionShown) return;
        map.updateSourcePoint(marker.source, marker.positionShown);
        marker.updateUncertainty();
    }

    function configureLayers() {
        map.setLayoutProperty(marker.layers.still, "icon-allow-overlap", true);
        map.setLayoutProperty(marker.layers.still, "icon-image", marker.images.still);
        map.setLayoutProperty(marker.layers.still, "icon-rotation-alignment", "map");
        map.setLayoutProperty(marker.layers.still, "icon-size", 1 / map.pixelRatio);
        map.setLayoutProperty(marker.layers.moving, "icon-allow-overlap", true);
        map.setLayoutProperty(marker.layers.moving, "icon-image", marker.images.moving);
        map.setLayoutProperty(marker.layers.moving, "icon-rotation-alignment", "map");
        map.setLayoutProperty(marker.layers.moving, "icon-size", 1 / map.pixelRatio);
        // set the layer immediately in accordence with the direction availibility.
        // there seems to be a corner case in interaction with mapbox-gl qml when the layer
        // visibility is changed in two consecutive calls before the changes are applied by
        // the widget
        if (map.direction!==undefined) {
            map.setLayoutProperty(marker.layers.still, "visibility", "none");
            map.setLayoutProperty(marker.layers.moving, "visibility", "visible");
            marker.directionVisible = true;
        } else if (map.direction===undefined) {
            map.setLayoutProperty(marker.layers.still, "visibility", "visible");
            map.setLayoutProperty(marker.layers.moving, "visibility", "none");
            marker.directionVisible = false;
        }
        map.setPaintProperty(marker.layers.layerUncertainty, "circle-radius", 0);
        map.setPaintProperty(marker.layers.layerUncertainty, "circle-color", styler.positionUncertainty);
        map.setPaintProperty(marker.layers.layerUncertainty, "circle-opacity", 0.15);
        map.setPaintProperty(marker.layers.layerUncertainty, "circle-pitch-alignment", "map");
    }

    function initIcons() {
        var suffix = "";
        if (styler.position) suffix = "-" + styler.position;
        map.addImagePath(marker.images.still, Qt.resolvedUrl(app.getIconScaled("icons/position/position" + suffix, true)));
        map.addImagePath(marker.images.moving, Qt.resolvedUrl(app.getIconScaled("icons/position/position-direction" + suffix, true)));
    }

    function initLayers() {
        map.addSourcePoint(marker.source, gps.position.coordinate);
        map.addLayer(marker.layers.layerUncertainty,
                     {"type": "circle", "source": marker.source},
                     map.firstLabelLayer);
        map.addLayer(marker.layers.still, {"type": "symbol", "source": marker.source});
        map.addLayer(marker.layers.moving, {"type": "symbol", "source": marker.source});
    }

    function updateDirection() {
        if (map.direction!==undefined && !marker.directionVisible) {
            map.setLayoutProperty(marker.layers.still, "visibility", "none");
            map.setLayoutProperty(marker.layers.moving, "visibility", "visible");
            marker.directionVisible = true;
        } else if (map.direction===undefined && marker.directionVisible) {
            map.setLayoutProperty(marker.layers.still, "visibility", "visible");
            map.setLayoutProperty(marker.layers.moving, "visibility", "none");
            marker.directionVisible = false;
        }
        if (marker.directionVisible)
            map.setLayoutProperty(marker.layers.moving, "icon-rotate", map.direction);
    }

    function updateUncertainty() {
        if (gps.position.horizontalAccuracyValid)
            map.setPaintProperty(marker.layers.layerUncertainty, "circle-radius",
                                 gps.position.horizontalAccuracy / map.metersPerPixel / map.pixelRatio);
        else
            map.setPaintProperty(marker.layers.layerUncertainty, "circle-radius", 0);
    }
}
