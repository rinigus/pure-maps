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

    readonly property var images: QtObject {
        readonly property string moving: "whogo-position-moving"
        readonly property string still:  "whogo-position-still"
    }

    readonly property var layers: QtObject {
        readonly property string moving: "whogo-position-moving"
        readonly property string still:  "whogo-position-still"
    }

    readonly property string source: "whogo-position"

    Connections {
        target: map
        onDirectionChanged: marker.updateDirection();
        onPositionChanged: map.updateSourcePoint(marker.source, map.position.coordinate);
    }

    Component.onCompleted: {
        marker.initLayers();
        marker.configureLayers();
        marker.updateDirection();
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
    }

    function initLayers() {
        map.addSourcePoint(marker.source, map.position.coordinate);
        map.addImagePath(marker.images.still, Qt.resolvedUrl(app.getIcon("icons/position")));
        map.addImagePath(marker.images.moving, Qt.resolvedUrl(app.getIcon("icons/position-direction")));
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

}
