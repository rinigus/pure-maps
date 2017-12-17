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
import QtLocation 5.0
import QtPositioning 5.3
import Sailfish.Silica 1.0
import "."

import "js/util.js" as Util

Map {
    id: map
    anchors.centerIn: parent
    center: QtPositioning.coordinate(49, 13)
    clip: true
    gesture.enabled: true
    height: parent.height
    minimumZoomLevel: 3
    plugin: MapPlugin {}
    rotation: 0
    width: parent.width

    property bool autoCenter: false
    property bool autoRotate: false
    property bool centerFound: true
    property bool changed: true
    property var  direction: app.navigationDirection || gps.direction
    property var  directionPrev: 0
    property bool halfZoom: false
    property bool hasRoute: false
    property real heightCoords: 0
    property var  maneuvers: []
    property var  pois: []
    property var  position: gps.position
    property var  positionMarker: PositionMarker {}
    property bool ready: false
    property var  route: route
    property real scaleX: 0
    property real scaleY: 0
    property var  tiles: []
    property real widthCoords: 0
    property real zoomLevelPrev: 8

    property var constants: QtObject {

        // Define metrics of the canvas used. Must match what plugin uses.
        // Scale factor is relative to the traditional tile size 256.
        property real canvasTileSize: 512
        property real canvasScaleFactor: 0.5

        // Distance of position center point from screen bottom when
        // navigating and auto-rotate is on, i.e. heading up on screen.
        // This is relative to the total visible map height.
        property real navigationCenterY: 0.22

        // This is the zoom level offset at which @3x, @6x, etc. tiles
        // can be shown pixel for pixel. The exact value is log2(1.5),
        // but QML's JavaScript doesn't have Math.log2.
        property real halfZoom: 0.5849625
    }

    Behavior on center {
        CoordinateAnimation {
            duration: map.ready ? 500 : 0
            easing.type: Easing.InOutQuad
        }
    }

    Behavior on rotation {
        RotationAnimation {
            direction: RotationAnimation.Shortest
            duration: map.ready ? 500 : 0
            easing.type: Easing.Linear
        }
    }

    MapMouseArea {}
    MapTimer {}
    NarrationTimer {}
    Route { id: route }

    Component.onCompleted: {
        // Load default values and start periodic updates.
        map.initProperties();
    }

    gesture.onPinchFinished: {
        // Round piched zoom level to avoid fuzziness.
        var offset = map.zoomLevel < map.zoomLevelPrev ? -1 : 1;
        Math.abs(map.zoomLevel - map.zoomLevelPrev) > 0.25 ?
            map.setZoomLevel(map.zoomLevelPrev + offset) :
            map.setZoomLevel(map.zoomLevelPrev);
    }

    onAutoRotateChanged: {
        // Update map size and rotation.
        map.updateSize();
        if (map.autoRotate && map.direction) {
            map.rotation = -map.direction;
        } else {
            map.rotation = 0;
        }
    }

    onCenterChanged: {
        // Ensure that tiles are updated after panning.
        // This gets fired ridiculously often, so keep simple.
        map.changed = true;
    }

    onDirectionChanged: {
        // Update map rotation to match direction.
        var direction = map.direction || 0;
        if (map.autoRotate && !map.gesture.isPanActive && !map.gesture.isPinchActive &&
            Math.abs(direction - directionPrev) > 10) {
            map.rotation = -direction;
            map.directionPrev = direction;
        }
    }

    onHasRouteChanged: {
        // Update keep-alive in case set to 'navigating'.
        app.updateKeepAlive();
    }

    onPositionChanged: {
        if (!map.centerFound) {
            // Center on user's position on first start.
            map.centerFound = true;
            map.setZoomLevel(14);
            map.centerOnPosition();
        } else if (map.autoCenter && !map.gesture.isPanActive && !map.gesture.isPinchActive) {
            // Center map on position if outside center of screen.
            // map.toScreenPosition returns NaN when outside component and
            // otherwise actually relative positions inside the map component,
            // which can differ from the screen when using auto-rotation.
            var pos = map.toScreenPosition(map.position.coordinate);
            if (!pos.x || !pos.y)
                return map.centerOnPosition();
            var height = app.screenHeight - app.navigationBlock.height;
            // If the navigation block covers the top part of the screen,
            // center the position to the part of the map remaining visible.
            var dy = app.navigationBlock.height / 2;
            if (map.autoRotate) {
                // If auto-rotate is on, the user is always heading up
                // on the screen and should see more ahead than behind.
                dy += (0.5 - map.constants.navigationCenterY) * height;
                // Avoid overlap with the menu button. Note that the position marker
                // height includes the arrow, which points up when navigating,
                // leaving padding the size of the arrow at the bottom.
                dy = Math.min(dy, (app.screenHeight/2 -
                                   app.menuButton.height -
                                   app.menuButton.anchors.bottomMargin -
                                   map.positionMarker.height/2));

            }
            // https://en.wikipedia.org/wiki/Azimuth#Cartographical_azimuth
            var cx = map.width  / 2 + dy * Math.sin(Util.deg2rad(map.rotation));
            var cy = map.height / 2 + dy * Math.cos(Util.deg2rad(map.rotation));
            var threshold = map.autoRotate ? 0.12 * height :
                0.18 * Math.min(app.screenWidth, height);
            if (Util.eucd(pos.x, pos.y, cx, cy) > threshold)
                map.centerOnPosition();
        }
    }

    function addManeuvers(maneuvers) {
        /*
         * Add new maneuver markers to map.
         *
         * Expected fields for each item in in maneuvers:
         *  - x: Longitude coordinate of maneuver point
         *  - y: Latitude coordinate of maneuver point
         *  - icon: Name of maneuver icon (optional, defaults to "flag")
         *  - narrative: Plain text instruction of maneuver
         *  - passive: true if point doesn't require any actual action
         *    (optional, defaults to false)
         *  - duration: Duration (s) of leg following maneuver point
         */
        var component, maneuver;
        for (var i = 0; i < maneuvers.length; i++) {
            component = Qt.createComponent("ManeuverMarker.qml");
            maneuver = component.createObject(map);
            maneuver.coordinate = QtPositioning.coordinate(maneuvers[i].y, maneuvers[i].x);
            maneuver.duration = maneuvers[i].duration || 0;
            maneuver.icon = maneuvers[i].icon || "flag";
            maneuver.narrative = maneuvers[i].narrative || "";
            maneuver.passive = maneuvers[i].passive || false;
            maneuver.verbalAlert = maneuvers[i].verbal_alert || "";
            maneuver.verbalPost = maneuvers[i].verbal_post || "";
            maneuver.verbalPre = maneuvers[i].verbal_pre || "";
            map.maneuvers.push(maneuver);
            map.addMapItem(maneuver);
        }
        py.call("poor.app.narrative.set_maneuvers", [maneuvers], null);
        map.saveManeuvers();
    }

    function addPois(pois) {
        /*
         * Add new POI markers to map.
         *
         * Expected fields for each item in pois:
         *  - x: Longitude coordinate of point
         *  - y: Latitude coordinate of point
         *  - title: Plain text name by which to refer to point
         *  - text: Text.RichText to show in POI bubble
         *  - link: Hyperlink accessible from POI bubble (optional)
         */
        var component, poi;
        for (var i = 0; i < pois.length; i++) {
            component = Qt.createComponent("PoiMarker.qml");
            poi = component.createObject(map);
            poi.coordinate = QtPositioning.coordinate(pois[i].y, pois[i].x);
            poi.title = pois[i].title || "";
            poi.text = pois[i].text || "";
            poi.link = pois[i].link || ""
            map.pois.push(poi);
            map.addMapItem(poi);
        }
        map.savePois();
    }

    function addRoute(route, amend) {
        /*
         * Add a polyline to represent a route.
         *
         * Expected fields in route:
         *  - x: Array of route polyline longitude coordinates
         *  - y: Array of route polyline latitude coordinates
         *  - attribution: Plain text router attribution
         *  - mode: Transport mode: "car" or "transit"
         *
         * amend should be true to update the current polyline with minimum side-effects,
         * e.g. when rerouting, not given or false otherwise.
         */
        amend || map.endNavigating();
        map.clearRoute();
        map.route.setPath(route.x, route.y);
        map.route.attribution = route.attribution || "";
        map.route.language = route.language || "en";
        map.route.mode = route.mode || "car";
        map.route.redraw();
        py.call_sync("poor.app.narrative.set_mode", [route.mode || "car"]);
        py.call("poor.app.narrative.set_route", [route.x, route.y], function() {
            map.hasRoute = true;
        });
        map.saveRoute();
        map.saveManeuvers();
        app.navigationStarted = !!amend;
    }

    function beginNavigating() {
        // Set UI to navigation mode.
        map.zoomLevel < 16 && map.setZoomLevel(16);
        map.centerOnPosition();
        // Wait for the centering animation to complete before turning
        // on auto-rotate to avoid getting the trigonometry wrong.
        py.call("poor.util.sleep", [0.5], function() {
            map.autoCenter = true;
            map.autoRotate = true;
        });
        if (app.conf.get("voice_navigation")) {
            var args = [route.language, app.conf.get("voice_gender")];
            py.call_sync("poor.app.narrative.set_voice", args);
            app.notification.flash(app.tr("Voice navigation on"));
        } else {
            py.call_sync("poor.app.narrative.set_voice", [null, null]);
        }
        app.navigationActive = true;
        app.navigationPageSeen = true;
        app.navigationStarted = true;
        app.rerouteConsecutiveErrors = 0;
        app.reroutePreviousTime = -1;
        app.rerouteTotalCalls = 0;
    }

    function centerOnPosition() {
        // Center map on the current position.
        if (app.navigationBlock.height > 0 || map.autoRotate) {
            // If the navigation block covers the top part of the screen,
            // center the position to the part of the map remaining visible.
            var dy = app.navigationBlock.height / 2;
            if (map.autoRotate) {
                // If auto-rotate is on, the user is always heading up
                // on the screen and should see more ahead than behind.
                var height = app.screenHeight - app.navigationBlock.height;
                dy += (0.5 - map.constants.navigationCenterY) * height;
                // Avoid overlap with the menu button. Note that the position marker
                // height includes the arrow, which points up when navigating,
                // leaving padding the size of the arrow at the bottom.
                dy = Math.min(dy, (app.screenHeight/2 -
                                   app.menuButton.height -
                                   app.menuButton.anchors.bottomMargin -
                                   map.positionMarker.height/2));

            }
            var p0 = map.toCoordinate(Qt.point(map.width/2, map.height/2));
            var p1 = map.toCoordinate(Qt.point(map.width/2, map.height/2 + dy));
            var coord = map.position.coordinate.atDistanceAndAzimuth(
                p0.distanceTo(p1), -map.rotation);
            map.setCenter(coord.longitude, coord.latitude);
        } else {
            map.setCenter(map.position.coordinate.longitude,
                          map.position.coordinate.latitude);

        }
    }

    function clear() {
        // Remove all point and route markers from the map.
        map.clearPois();
        map.clearRoute();
    }

    function clearPois() {
        // Remove all point of interest from the map.
        Util.removeMapItems(map, map.pois);
        map.pois = [];
        map.savePois();
    }

    function clearRoute() {
        // Remove all route markers from the map.
        Util.removeMapItems(map, map.maneuvers);
        map.maneuvers = [];
        map.route.clear();
        py.call_sync("poor.app.narrative.unset", []);
        app.navigationStatus.clear();
        map.saveRoute();
        map.saveManeuvers();
        map.hasRoute = false;
    }

    function clearTiles() {
        // Remove all tiles from the map.
        Util.removeMapItems(map, map.tiles);
        map.tiles = [];
        py.call_sync("poor.app.tilecollection.clear", []);
        map.changed = true;
    }

    function demoteTiles() {
        // Drop basemap tiles to a lower z-level and remove overlays.
        for (var i = 0; i < map.tiles.length; i++) {
            if (map.tiles[i].type === "basemap") {
                map.tiles[i].z = Math.max(1, map.tiles[i].z - 1);
            } else {
                map.tiles[i].z = -1;
            }
        }
    }

    function endNavigating() {
        // Restore UI from navigation mode.
        map.autoCenter = false;
        map.autoRotate = false;
        map.zoomLevel > 15 && map.setZoomLevel(15);
        app.navigationActive = false;
    }

    function fitViewtoCoordinates(coords) {
        // Set center and zoom so that all points are visible.
        if (coords.length === 0) return;
        var xmin = 360, xmax = -360;
        var ymin = 360, ymax = -360;
        for (var i = 0; i < coords.length; i++) {
            var x = coords[i].longitude;
            var y = coords[i].latitude;
            if (x < xmin) xmin = x;
            if (x > xmax) xmax = x;
            if (y < ymin) ymin = y;
            if (y > ymax) ymax = y;
        }
        var xc = (xmin + xmax) / 2;
        var yc = (ymin + ymax) / 2;
        map.autoCenter = false;
        map.autoRotate = false;
        map.setZoomLevel(map.minimumZoomLevel);
        map.setCenter(xc, yc);
        // Calculate the greatest offset of a single point from the center
        // of the screen and based on that the maximum zoom that will still
        // keep all points visible.
        var offset = 0;
        var xr = map.widthCoords  / 2;
        var yr = map.heightCoords / 2;
        for (var i = 0; i < coords.length; i++) {
            var xp = Math.abs(coords[i].longitude - xc) / xr;
            var yp = Math.abs(coords[i].latitude  - yc) / yr;
            if (xp > offset) offset = xp;
            if (yp > offset) offset = yp;
        }
        for (var i = map.zoomLevel; offset < 0.5 && i < 16; i++)
            offset *= 2;
        map.setZoomLevel(i);
    }

    function fitViewToPois(pois) {
        // Set center and zoom so that given POIs are visible.
        var coords = [];
        for (var i = 0; i < pois.length; i++)
            coords.push(QtPositioning.coordinate(pois[i].y, pois[i].x));
        map.fitViewtoCoordinates(coords);
    }

    function fitViewToRoute() {
        // Set center and zoom so that the whole route is visible.
        // For performance reasons, include only a subset of points.
        if (map.route.path.x.length === 0) return;
        var coords = [];
        for (var i = 0; i < map.route.path.x.length; i = i + 10) {
            coords.push(QtPositioning.coordinate(
                map.route.path.y[i], map.route.path.x[i]));
        }
        var x = map.route.path.x[map.route.path.x.length-1];
        var y = map.route.path.y[map.route.path.x.length-1];
        coords.push(QtPositioning.coordinate(y, x));
        map.fitViewtoCoordinates(coords);
    }

    function getBoundingBox() {
        // Return currently visible [xmin, xmax, ymin, ymax].
        var nw = map.toCoordinate(Qt.point(0, 0));
        var se = map.toCoordinate(Qt.point(map.width, map.height));
        return [nw.longitude, se.longitude, se.latitude, nw.latitude];
    }

    function getPosition() {
        // Return the current position as [x,y].
        return [map.position.coordinate.longitude,
                map.position.coordinate.latitude];

    }

    function hidePoiBubbles() {
        // Hide label bubbles of all POI markers.
        for (var i = 0; i < map.pois.length; i++)
            map.pois[i].bubbleVisible = false;
    }

    function initProperties() {
        // Load default values and start periodic updates.
        if (!py.ready)
            return py.onReadyChanged.connect(map.initProperties);
        map.setZoomLevel(app.conf.get("zoom"));
        map.autoCenter = app.conf.get("auto_center");
        map.autoRotate = app.conf.get("auto_rotate");
        var center = app.conf.get("center");
        if (center[0] === 0.0 && center[1] === 0.0) {
            // Center on user's position on first start.
            map.centerFound = false;
            map.setCenter(13, 49);
        } else {
            map.centerFound = true;
            map.setCenter(center[0], center[1]);
        }
        map.updateTiles();
        app.updateKeepAlive();
        map.loadPois();
        map.loadRoute();
        map.loadManeuvers();
        map.ready = true;
    }

    function loadManeuvers() {
        // Load maneuvers from JSON file.
        if (!py.ready) return;
        py.call("poor.storage.read_maneuvers", [], function(data) {
            if (data && data.length > 0)
                map.addManeuvers(data);
        });
    }

    function loadPois() {
        // Load POIs from JSON file.
        if (!py.ready) return;
        py.call("poor.storage.read_pois", [], function(data) {
            if (data && data.length > 0)
                map.addPois(data);
        });
    }

    function loadRoute() {
        // Load route from JSON file.
        if (!py.ready) return;
        py.call("poor.storage.read_route", [], function(data) {
            if (data.x && data.x.length > 0 &&
                data.y && data.y.length > 0)
                map.addRoute(data);
        });
    }

    function queueUpdate() {
        // Mark map as changed to trigger an update.
        map.changed = true;
    }

    function renderTile(props) {
        // Render tile from local image file.
        if (props.half_zoom !== map.halfZoom) {
            map.halfZoom = props.half_zoom;
            map.setZoomLevel(map.zoomLevel);
        }
        for (var i = 0; i < map.tiles.length; i++) {
            if (map.tiles[i].uid !== props.uid) continue;
            map.tiles[i].coordinate.latitude = props.nwy;
            map.tiles[i].coordinate.longitude = props.nwx;
            map.tiles[i].smooth = props.smooth;
            map.tiles[i].type = props.type;
            map.tiles[i].zOffset = props.z;
            map.tiles[i].zoomLevel = props.display_zoom +
                (props.half_zoom ? constants.halfZoom : 0);
            map.tiles[i].uri = props.uri;
            map.tiles[i].setWidth(props);
            map.tiles[i].setHeight(props);
            map.tiles[i].setZ(map.zoomLevel);
            return;
        }
        // Add missing tile to collection.
        var component = Qt.createComponent("Tile.qml");
        var tile = component.createObject(map);
        tile.uid = props.uid;
        map.tiles.push(tile);
        map.addMapItem(tile);
        map.renderTile(props);
    }

    function saveManeuvers() {
        // Save maneuvers to JSON file.
        if (!py.ready) return;
        var data = [];
        for (var i = 0; i < map.maneuvers.length; i++) {
            var maneuver = {};
            maneuver.x = map.maneuvers[i].coordinate.longitude;
            maneuver.y = map.maneuvers[i].coordinate.latitude;
            maneuver.duration = map.maneuvers[i].duration;
            maneuver.icon = map.maneuvers[i].icon;
            maneuver.narrative = map.maneuvers[i].narrative;
            maneuver.passive = map.maneuvers[i].passive;
            maneuver.verbal_alert = map.maneuvers[i].verbalAlert;
            maneuver.verbal_post = map.maneuvers[i].verbalPost;
            maneuver.verbal_pre = map.maneuvers[i].verbalPre;
            data.push(maneuver);
        }
        py.call_sync("poor.storage.write_maneuvers", [data]);
    }

    function savePois() {
        // Save POIs to JSON file.
        if (!py.ready) return;
        var data = [];
        for (var i = 0; i < map.pois.length; i++) {
            var poi = {};
            poi.x = map.pois[i].coordinate.longitude;
            poi.y = map.pois[i].coordinate.latitude;
            poi.title = map.pois[i].title;
            poi.text = map.pois[i].text;
            poi.link = map.pois[i].link;
            data.push(poi);
        }
        py.call_sync("poor.storage.write_pois", [data]);
    }

    function saveRoute() {
        // Save route to JSON file.
        if (!py.ready) return;
        if (map.route.path.x && map.route.path.x.length > 0 &&
            map.route.path.y && map.route.path.y.length > 0) {
            var data = {};
            data.x = map.route.path.x;
            data.y = map.route.path.y;
            data.attribution = map.route.attribution;
            data.language = map.route.language;
            data.mode = map.route.mode;
        } else {
            var data = {};
        }
        py.call_sync("poor.storage.write_route", [data]);
    }

    function setCenter(x, y) {
        // Set the current center position.
        // Create a new object to trigger animation.
        if (!x || !y) return;
        map.center = QtPositioning.coordinate(y, x);
        map.changed = true;
    }

    function setZoomLevel(zoom) {
        // Set the current zoom level.
        // Round zoom level so that tiles are displayed pixel for pixel.
         zoom = map.halfZoom ?
            Math.ceil(zoom - constants.halfZoom - 0.01) + constants.halfZoom :
            Math.floor(zoom + 0.01);
        map.demoteTiles();
        map.zoomLevel = zoom;
        map.zoomLevelPrev = zoom;
        var bbox = map.getBoundingBox();
        map.widthCoords = bbox[1] - bbox[0];
        map.heightCoords = bbox[3] - bbox[2];
        map.scaleX = map.width / map.widthCoords;
        map.scaleY = map.height / map.heightCoords;
        map.hasRoute && map.route.redraw();
        map.changed = true;
    }

    function showTile(uid) {
        // Show tile with given uid.
        for (var i = 0; i < map.tiles.length; i++) {
            if (map.tiles[i].uid !== uid) continue;
            map.tiles[i].setZ(map.zoomLevel);
            break;
        }
    }

    function updateSize() {
        // Update map width and height to match environment.
        if (map.autoRotate) {
            var dim = Math.floor(Math.sqrt(
                parent.width * parent.width +
                    parent.height * parent.height));
            map.width = dim;
            map.height = dim;
        } else {
            map.width = parent.width;
            map.height = parent.height;
        }
        map.hasRoute && map.route.redraw();
        map.changed = true;
    }

    function updateTiles() {
        // Ask the Python backend to download missing tiles.
        if (!py.ready) return;
        if (map.width <= 0 || map.height <= 0) return;
        if (map.gesture.isPinchActive) return;
        var bbox = map.getBoundingBox();
        py.call("poor.app.update_tiles",
                [bbox[0], bbox[1], bbox[2], bbox[3],
                 Math.floor(map.zoomLevel),
                 map.constants.canvasScaleFactor],
                null);

        map.widthCoords = bbox[1] - bbox[0];
        map.heightCoords = bbox[3] - bbox[2];
        map.scaleX = map.width / map.widthCoords;
        map.scaleY = map.height / map.heightCoords;
        app.scaleBar.update();
        map.changed = false;
    }

}
