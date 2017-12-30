/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2014 Osmo Salomaa
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
import Sailfish.Silica 1.0
import "."

Item {

    property bool directionVisible: false

    property var constants: QtObject {
        property string sourceName: "pm-position-marker"

        property string imageStill: "pm-image-still"
        property string imageMoving: "pm-image-moving"

        property string layerUncertainty: "pm-layer-position-uncertain"
        //        property string layerDot: "pm-layer-position-dot"
        //        property string layerCircle: "pm-layer-position-circle"
        property string layerStill: "pm-layer-position-still"
        property string layerMoving: "pm-layer-position-moving"
    }

    function init() {
        // add the source that will be updated with the current position
        map.addSourcePoint(constants.sourceName, map.position.coordinate);

        // load icons
        map.addImagePath(constants.imageStill, Qt.resolvedUrl(app.getIcon("icons/position")))
        map.addImagePath(constants.imageMoving, Qt.resolvedUrl(app.getIcon("icons/position-direction")));

        // add layers

        map.addLayer(constants.layerUncertainty, {"type": "circle", "source": constants.sourceName}, map.styleReferenceLayer);
        map.setPaintProperty(constants.layerUncertainty, "circle-radius", 0);
        map.setPaintProperty(constants.layerUncertainty, "circle-color", "#87cefa");
        map.setPaintProperty(constants.layerUncertainty, "circle-opacity", 0.15);

        //        map.addLayer(constants.layerDot, {"type": "circle", "source": constants.sourceName}, map.styleReferenceLayer);
        //        map.setPaintProperty(constants.layerDot, "circle-radius", 6);
        //        map.setPaintProperty(constants.layerDot, "circle-color", "#819FFF");

        //        map.addLayer(constants.layerCircle, {"type": "circle", "source": constants.sourceName}, map.styleReferenceLayer);
        //        map.setPaintProperty(constants.layerCircle, "circle-radius", 12);
        //        map.setPaintProperty(constants.layerCircle, "circle-opacity", 0);
        //        map.setPaintProperty(constants.layerCircle, "circle-stroke-width", 6);
        //        map.setPaintProperty(constants.layerCircle, "circle-stroke-color", "#819FFF");

        map.addLayer(constants.layerStill, {"type": "symbol", "source": constants.sourceName}); //, map.styleReferenceLayer);
        map.setLayoutProperty(constants.layerStill, "icon-image", constants.imageStill);
        map.setLayoutProperty(constants.layerStill, "icon-size", 1.0 / map.pixelRatio);
        map.setLayoutProperty(constants.layerStill, "visibility", "visible");

        map.addLayer(constants.layerMoving, {"type": "symbol", "source": constants.sourceName}); //, map.styleReferenceLayer);
        map.setLayoutProperty(constants.layerMoving, "icon-image", constants.imageMoving);
        map.setLayoutProperty(constants.layerMoving, "icon-size", 1.0 / map.pixelRatio);
        map.setLayoutProperty(constants.layerMoving, "icon-rotation-alignment", "map");
        map.setLayoutProperty(constants.layerMoving, "visibility", "none");

        directionVisible = false;

        // set current values
        setUncertainty();
        setLayers();
    }

    function setUncertainty() {
        if (map.position.horizontalAccuracyValid)
            map.setPaintProperty(constants.layerUncertainty, "circle-radius",
                                 map.position.horizontalAccuracy / map.metersPerPixel / map.pixelRatio);
        else
            map.setPaintProperty(constants.layerUncertainty, "circle-radius", 0);
    }

    function setLayers() {
        if (map.direction && !directionVisible) {
            map.setLayoutProperty(constants.layerMoving, "visibility", "visible");
            map.setLayoutProperty(constants.layerStill, "visibility", "none");
            directionVisible = true;
        }
        if (!map.direction && directionVisible) {
            map.setLayoutProperty(constants.layerStill, "visibility", "visible");
            map.setLayoutProperty(constants.layerMoving, "visibility", "none");
            directionVisible = false;
        }

        if (directionVisible) {
            map.setLayoutProperty(constants.layerMoving, "icon-rotate", map.direction)
        }
    }

    function mouseClick() {
        if (map.autoCenter) {
            map.autoCenter = false;
            notification.flash(app.tr("Auto-center off"));
        } else {
            map.autoCenter = true;
            notification.flash(app.tr("Auto-center on"));
            map.centerOnPosition();
        }
    }

    Component.onCompleted: {
        init();
    }

    Connections {
        target: map

        onPositionChanged: {
            map.updateSourcePoint(constants.sourceName, map.position.coordinate);
            setUncertainty();
        }

        onMetersPerPixelChanged: setUncertainty()

        onDirectionChanged: setLayers()
    }
}
