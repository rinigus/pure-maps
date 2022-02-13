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
        property bool initialized: false
    }

    Connections {
        target: map
        onDirectionChanged: marker.updateDirection()
        onMetersPerPixelChanged: marker.updateUncertainty()
    }

    Connections {
        target: gps
        onReadyChanged: marker.updateVisibility()
        onPositionUpdated: {
            if (!gps.coordinateValid) return;
            if (!positionShown || !marker._animatePosition) {
                positionShown = QtPositioning.coordinate(gps.coordinate.latitude, gps.coordinate.longitude);
                marker.position = QtPositioning.coordinate(gps.coordinate.latitude, gps.coordinate.longitude);
            } else {
                animate.complete();
                if (!animate.initialized) {
                    animate.from = QtPositioning.coordinate(gps.coordinate.latitude, gps.coordinate.longitude);
                    animate.to = QtPositioning.coordinate(gps.coordinate.latitude, gps.coordinate.longitude);
                    animate.initialized = true;
                }
                marker.position = animate.to;
                animate.from = QtPositioning.coordinate(marker.position.latitude, marker.position.longitude);
                animate.to = QtPositioning.coordinate(gps.coordinate.latitude, gps.coordinate.longitude);
                animate.start();
                marker.position = QtPositioning.coordinate(gps.coordinate.latitude, gps.coordinate.longitude);
            }
        }
    }

    Component.onCompleted: {
        marker.initIcons();
        marker.initLayers();
        marker.configureLayers();
    }

    on_AnimatePositionChanged: {
        if (!_animatePosition) {
            animate.initialized = false;
        }
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
        map.setLayoutProperty(marker.layers.still, "icon-size", 1 * map.mapToQtPixelRatio / map.devicePixelRatio );
        map.setLayoutProperty(marker.layers.moving, "icon-allow-overlap", true);
        map.setLayoutProperty(marker.layers.moving, "icon-image", marker.images.moving);
        map.setLayoutProperty(marker.layers.moving, "icon-rotation-alignment", "map");
        map.setLayoutProperty(marker.layers.moving, "icon-size", 1 * map.mapToQtPixelRatio / map.devicePixelRatio );
        // set the layer immediately in accordence with the direction availibility.
        // there seems to be a corner case in interaction with mapbox-gl qml when the layer
        // visibility is changed in two consecutive calls before the changes are applied by
        // the widget
        if (map.direction!==undefined) {
            map.setLayoutProperty(marker.layers.still, "visibility", "none");
            map.setLayoutProperty(marker.layers.moving, "visibility", "visible");
            marker.directionVisible = true;
        } else {
            map.setLayoutProperty(marker.layers.still, "visibility", "visible");
            map.setLayoutProperty(marker.layers.moving, "visibility", "none");
            marker.directionVisible = false;
        }
        map.setPaintProperty(marker.layers.layerUncertainty, "circle-radius", 0);
        map.setPaintProperty(marker.layers.layerUncertainty, "circle-color", styler.positionUncertainty);
        map.setPaintProperty(marker.layers.layerUncertainty, "circle-opacity", 0.15);
        map.setPaintProperty(marker.layers.layerUncertainty, "circle-pitch-alignment", "map");

        updateDirection();
        updateUncertainty();
        updateVisibility();
    }

    function initIcons() {
        var suffix = "";
        if (styler.position) suffix = "-" + styler.position;
        var iconSize = 70 * styler.themePixelRatio;
        map.addImagePath(marker.images.still,
                         Qt.resolvedUrl(app.getIcon("icons/position/position" + suffix, true)),
                         iconSize );
        map.addImagePath(marker.images.moving,
                         Qt.resolvedUrl(app.getIcon("icons/position/position-direction" + suffix, true)),
                         iconSize );
    }

    function initLayers() {
        map.addSourcePoint(marker.source, gps.coordinate);
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
        if (gps.horizontalAccuracyValid)
            map.setPaintProperty(marker.layers.layerUncertainty, "circle-radius",
                                 gps.horizontalAccuracy / map.metersPerMapPixel);
        else
            map.setPaintProperty(marker.layers.layerUncertainty, "circle-radius", 0);
    }

    function updateVisibility() {
        map.setLayoutProperty(marker.layers.still, "icon-opacity", gps.ready ? 1.0 : 0.6);
        map.setLayoutProperty(marker.layers.moving, "icon-opacity", gps.ready ? 1.0 : 0.6);
    }
}
