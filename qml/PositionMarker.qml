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
import Sailfish.Silica 1.0
import "."

Item {
    id: marker

    property bool directionVisible: false

    readonly property string imageMoving: "whogo-image-position-moving"
    readonly property string imageStill:  "whogo-image-position-still"
    readonly property string layerMoving: "whogo-layer-position-moving"
    readonly property string layerStill:  "whogo-layer-position-still"
    readonly property string sourceName:  "whogo-position-marker"

    Connections {
        target: map
        onPositionChanged: map.updateSourcePoint(marker.sourceName, map.position.coordinate);
        onDirectionChanged: marker.updateDirection();
    }

    Component.onCompleted: {
        map.addSourcePoint(marker.sourceName, map.position.coordinate);
        map.addImagePath(marker.imageStill, Qt.resolvedUrl(app.getIcon("icons/position")))
        map.addImagePath(marker.imageMoving, Qt.resolvedUrl(app.getIcon("icons/position-direction")));
        map.addLayer(marker.layerStill, {"type": "symbol", "source": marker.sourceName});
        map.addLayer(marker.layerMoving, {"type": "symbol", "source": marker.sourceName});
        marker.configureLayers();
        marker.updateDirection();
    }

    function configureLayers() {
        map.setLayoutProperty(marker.layerStill, "icon-image", marker.imageStill);
        map.setLayoutProperty(marker.layerStill, "icon-allow-overlap", true);
        map.setLayoutProperty(marker.layerStill, "icon-rotation-alignment", "map");
        map.setLayoutProperty(marker.layerStill, "icon-size", 1 / map.pixelRatio);
        map.setLayoutProperty(marker.layerStill, "visibility", "visible");
        map.setLayoutProperty(marker.layerMoving, "icon-image", marker.imageMoving);
        map.setLayoutProperty(marker.layerMoving, "icon-allow-overlap", true);
        map.setLayoutProperty(marker.layerMoving, "icon-size", 1 / map.pixelRatio);
        map.setLayoutProperty(marker.layerMoving, "icon-rotation-alignment", "map");
        map.setLayoutProperty(marker.layerMoving, "visibility", "none");
    }

    function updateDirection() {
        if (map.direction && !marker.directionVisible) {
            map.setLayoutProperty(marker.layerStill, "visibility", "none");
            map.setLayoutProperty(marker.layerMoving, "visibility", "visible");
            marker.directionVisible = true;
        } else if (!map.direction && marker.directionVisible) {
            map.setLayoutProperty(marker.layerStill, "visibility", "visible");
            map.setLayoutProperty(marker.layerMoving, "visibility", "none");
            marker.directionVisible = false;
        }
        marker.directionVisible &&
            map.setLayoutProperty(marker.layerMoving, "icon-rotate", map.direction);
    }

}
