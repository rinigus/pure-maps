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
import MapboxMap 1.0
import "."

import "js/util.js" as Util

MapboxMap {
    id: map
    anchors.centerIn: parent
    /* clip: true */
    height: parent.height
    width: parent.width

    center: QtPositioning.coordinate(49,13)
    zoomLevel: 4.0
    minimumZoomLevel: 0
    maximumZoomLevel: 20

    // Theme.pixelRatio is relative to the Jolla 1,
    // which is maybe around 1.5 in terms of map scales.
    pixelRatio: Theme.pixelRatio * 1.5

    // Access token has to be defined from the start of the application
    accessToken: "pk.eyJ1IjoicmluaWd1cyIsImEiOiJjamIwbmUyYWM4ajZoMnhyMXVoZGtybXJqIn0.CfG6j_Kyg_Ho_ksH_8_iyw"
    styleUrl: "mapbox://styles/mapbox/streets-v10"

    cacheDatabaseStoreSettings: true
    cacheDatabaseDefaultPath: true

    property bool autoCenter: false
    property bool autoRotate: false
    property bool centerFound: true
    property var  direction: app.navigationDirection || gps.direction
    property var  directionPrev: 0
    property bool halfZoom: false
    property bool hasRoute: false
    property real heightCoords: 0
    property var  maneuvers: []
    property var  pois: []
    property var  position: gps.position
    property bool ready: false
    property var  route: {}
    property real scaleX: 0
    property real scaleY: 0

    // layer that is existing in the current style and
    // which can be used to position route and other layers
    // under to avoid covering important map features, such
    // as labels.
    property string styleReferenceLayer: "waterway-label"

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

        // Mapbox sources, layers, and images
        property string sourcePois: "pm-source-pois"
        property string imagePoi: "pm-image-poi"
        property string layerPois: "pm-layer-pois"

        property string sourceManeuvers: "pm-source-maneuvers"
        property string layerManeuvers: "pm-layer-maneuvers"

        property string sourceRoute: "pm-source-route"
        property string layerRouteCase: "pm-layer-route-case"
        property string layerRoute: "pm-layer-route"
    }

    Behavior on center {
        CoordinateAnimation {
            duration: map.ready ? 500 : 0
            easing.type: Easing.InOutQuad
        }
    }

    Behavior on bearing {
        RotationAnimation {
            direction: RotationAnimation.Shortest
            duration: map.ready ? 500 : 0
            easing.type: Easing.Linear
        }
    }

    Behavior on margins {
        PropertyAnimation {
            duration: map.ready ? 500 : 0
            easing.type: Easing.InOutQuad
        }
    }

    Behavior on pitch {
        NumberAnimation { duration: 1000 }
    }

    NarrationTimer {}
    PositionMarker { id: positionMarker }

    Component.onCompleted: {
        map.initSources();
        map.initLayers();
        map.initProperties();
        map.updateMargins();
    }

    onAutoRotateChanged: {
        if (map.autoRotate && map.direction) {
            map.bearing = map.direction;
        } else {
            map.bearing = 0;
        }
        updateMargins();
    }

    onDirectionChanged: {
        // Update map rotation to match direction.
        var direction = map.direction || 0;
        if (map.autoRotate && Math.abs(direction - directionPrev) > 10) {
            map.bearing = direction;
            map.directionPrev = direction;
        }
    }

    onHasRouteChanged: {
        // Update keep-alive in case set to 'navigating'.
        app.updateKeepAlive();
    }

    onHeightChanged: map.updateMargins()

    onPositionChanged: {
        if (!map.centerFound) {
            // Center on user's position on first start.
            map.centerFound = true;
            map.setZoomLevel(14);
            map.centerOnPosition();
        } else if (map.autoCenter) {
            map.centerOnPosition();
        }
    }

    MapboxMapGestureArea {
        map: map

        activeClickedGeo: true
        activePressAndHoldGeo: true

        onDoubleClicked: map.centerOnPosition()

        onClickedGeo: {
            // Process mouse clicks by comparing them with the current position,
            // and POIs

            // 15 pixels at 96dpi would correspond to 4 mm
            var nearby_lat = map.pixelRatio * 15 * degLatPerPixel;
            var nearby_lon = map.pixelRatio * 15 * degLonPerPixel;

            // check if its current position
            if ( Math.abs(geocoordinate.longitude - map.position.coordinate.longitude) < nearby_lon &&
                 Math.abs(geocoordinate.latitude - map.position.coordinate.latitude) < nearby_lat ) {
                positionMarker.mouseClick();
                return;
            }

            for (var i = 0; i < map.pois.length; i++) {
                if ( Math.abs(geocoordinate.longitude - map.pois[i].coordinate.longitude) < nearby_lon &&
                     Math.abs(geocoordinate.latitude - map.pois[i].coordinate.latitude) < nearby_lat ) {
                    if (!map.pois[i].bubble) {
                        var component = Qt.createComponent("PoiMarker.qml");
                        var poi = map.pois[i];
                        var trackid = "POI bubble: " + String(poi.coordinate);
                        var bubble = component.createObject(map, {
                            "coordinate": poi.coordinate,
                            "trackerId": trackid,
                            "title": poi.title,
                            "text": poi.text,
                            "link": poi.link
                        } );

                        map.trackLocation(trackid, poi.coordinate);
                        map.pois[i].bubble = bubble;
                    }
                    return;
                }
            }

            // Unknown click - let's close all POI dialogs and info bubble for attribution
            map.hidePoiBubbles();
            attribution.clearInfo();
        }

        onPressAndHoldGeo: map.addPois([{
            "x": geocoordinate.longitude,
            "y": geocoordinate.latitude,
            "title": app.tr("Unnamed point"),
            "text": app.tr("Unnamed point")
        }])

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
        for (var i = 0; i < maneuvers.length; i++) {
            var maneuver = {
                "coordinate": QtPositioning.coordinate(maneuvers[i].y, maneuvers[i].x),
                "duration": maneuvers[i].duration || 0,
                "icon": maneuvers[i].icon || "flag",
                "narrative": maneuvers[i].narrative || "",
                "passive": maneuvers[i].passive || false,
                "duration": maneuvers[i].duration || 0,
                "verbalAlert": maneuvers[i].verbal_alert || "",
                "verbalPost": maneuvers[i].verbal_post || "",
                "verbalPre": maneuvers[i].verbal_pre || ""
            };
            map.maneuvers.push(maneuver);
        }
        py.call("poor.app.narrative.set_maneuvers", [maneuvers], null);
        map.updateMapManeuvers();
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
        var poi;
        for (var i = 0; i < pois.length; i++) {
            poi = {
                "coordinate": QtPositioning.coordinate(pois[i].y, pois[i].x),
                "title": pois[i].title || "",
                "text": pois[i].text || "",
                "link": pois[i].link || ""
            }
            map.pois.push(poi);
        }

        map.updateMapPois();
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
        map.route.x = route.x;
        map.route.y = route.y;
        map.route.attribution = route.attribution || "";
        map.route.language = route.language || "en";
        map.route.mode = route.mode || "car";
        py.call_sync("poor.app.narrative.set_mode", [route.mode || "car"]);
        py.call("poor.app.narrative.set_route", [route.x, route.y], function() {
            map.hasRoute = true;
        });
        map.updateMapRoute();
        map.saveRoute();
        map.saveManeuvers();
        app.navigationStarted = !!amend;
    }

    function beginNavigating() {
        // Set UI to navigation mode.
        map.zoomLevel < 16 && map.setZoomLevel(16);
        map.centerOnPosition();
        map.autoCenter = true;
        map.autoRotate = true;
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

    function getRouteDestination() {
        // Return coordinates [x,y] of the route destination.
        return [map.route.x[map.route.x.length - 1],
                map.route.y[map.route.y.length - 1]];

    }

    function centerOnPosition() {
        // Center map on the current position.
        map.setCenter(map.position.coordinate.longitude,
                      map.position.coordinate.latitude);
    }

    function clear() {
        // Remove all point and route markers from the map.
        map.clearPois();
        map.clearRoute();
    }

    function clearPois() {
        // Remove all point of interest from the map.
        hidePoiBubbles();
        map.pois = [];
        map.updateMapPois();
        map.savePois();
    }

    function clearRoute() {
        // Remove all route markers from the map.
        map.maneuvers = [];
        map.route = {};
        py.call_sync("poor.app.narrative.unset", []);
        app.navigationStatus.clear();
        map.saveRoute();
        map.saveManeuvers();
        map.hasRoute = false;
        map.updateMapManeuvers();
        map.updateMapRoute();
    }

    function endNavigating() {
        // Restore UI from navigation mode.
        map.autoCenter = false;
        map.autoRotate = false;
        map.zoomLevel > 15 && map.setZoomLevel(15);
        app.navigationActive = false;
    }

    function fitViewtoCoordinates(coords) {
        map.autoCenter = false;
        map.autoRotate = false;
        map.fitView(coords);
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
        if (map.route.x.length === 0) return;
        var coords = [];
        for (var i = 0; i < map.route.x.length; i = i + 10) {
            coords.push(QtPositioning.coordinate(
                map.route.y[i], map.route.x[i]));
        }
        var x = map.route.x[map.route.x.length-1];
        var y = map.route.y[map.route.x.length-1];
        coords.push(QtPositioning.coordinate(y, x));
        map.fitViewtoCoordinates(coords);
    }

    function getPosition() {
        // Return the current position as [x,y].
        return [map.position.coordinate.longitude,
                map.position.coordinate.latitude];

    }

    function hidePoiBubbles() {
        // Hide label bubbles of all POI markers.
        for (var i = 0; i < map.pois.length; i++) {
            if (map.pois[i].bubble) {
                map.removeLocationTracking(map.pois[i].bubble.trackerId);
                map.pois[i].bubble.destroy();
                map.pois[i].bubble = false;
            }
        }
    }

    function initLayers() {
        /// Init layers on the map. This should be called after initSources

        //////////////////////////////////////////////
        // POIs

        // since we have text labels, put the symbols on top
        map.addLayer(constants.layerPois, {"type": "symbol", "source": constants.sourcePois}); //, map.styleReferenceLayer);
        map.setLayoutProperty(constants.layerPois, "icon-image", constants.imagePoi);
        map.setLayoutProperty(constants.layerPois, "icon-size", 1.0 / map.pixelRatio);
        map.setLayoutProperty(constants.layerPois, "icon-allow-overlap", true);

        map.setLayoutProperty(constants.layerPois, "text-optional", true);
        map.setLayoutProperty(constants.layerPois, "text-field", "{name}");
        map.setLayoutProperty(constants.layerPois, "text-size", 12);
        map.setLayoutProperty(constants.layerPois, "text-anchor", "top");
        map.setLayoutPropertyList(constants.layerPois, "text-offset", [0.0, 1.0]);
        map.setPaintProperty(constants.layerPois, "text-halo-color", "white");
        map.setPaintProperty(constants.layerPois, "text-halo-width", 2);

        //////////////////////////////////////////////
        // Route

        map.removeLayer(constants.layerRouteCase);
        map.addLayer(constants.layerRouteCase,
                     {"type": "line", "source": constants.sourceRoute}, map.styleReferenceLayer);
        map.setLayoutProperty(constants.layerRouteCase, "line-join", "round");
        map.setLayoutProperty(constants.layerRouteCase, "line-cap", "round");
        map.setPaintProperty(constants.layerRouteCase, "line-color", "#819FFF");
        map.setPaintProperty(constants.layerRouteCase, "line-width", 8);

        map.addLayer(constants.layerRoute,
                     {"type": "line", "source": constants.sourceRoute}, map.styleReferenceLayer);
        map.setLayoutProperty(constants.layerRoute, "line-join", "round");
        map.setLayoutProperty(constants.layerRoute, "line-cap", "round");
        map.setPaintProperty(constants.layerRoute, "line-color", "white");
        map.setPaintProperty(constants.layerRoute, "line-width", 1);

        //////////////////////////////////////////////
        // Maneuvers - drawn on top of the route

        map.addLayer(constants.layerManeuvers,
                     {"type": "circle", "source": constants.sourceManeuvers}, map.styleReferenceLayer);
        map.setPaintProperty(constants.layerManeuvers, "circle-radius", 3);
        map.setPaintProperty(constants.layerManeuvers, "circle-color", "white");
        map.setPaintProperty(constants.layerManeuvers, "circle-stroke-width", 2);
        map.setPaintProperty(constants.layerManeuvers, "circle-stroke-color", "#819FFF");
    }

    function initProperties() {
        // Load default values and start periodic updates.
        if (!py.ready)
            return py.onReadyChanged.connect(map.initProperties);
        map.setBasemap();
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
        app.updateKeepAlive();
        map.loadPois();
        map.loadRoute();
        map.loadManeuvers();
        map.ready = true;
    }

    function initSources() {
        /// Init sources that can be later referenced in the layers
        /// This has to be run only once - running later would reset
        /// roads and other sources

        map.addSourcePoints(constants.sourcePois, []);
        map.addImagePath(constants.imagePoi, Qt.resolvedUrl(app.getIcon("icons/poi")))
        map.addSourceLine(constants.sourceRoute, []);
        map.addSourcePoints(constants.sourceManeuvers, []);
    }

    function updateMapPois() {
        // update POIs drawn on the map
        var p = [];
        var n = [];
        for (var i = 0; i < map.pois.length; i++) {
            p.push(map.pois[i].coordinate);
            n.push(map.pois[i].title);
        }
        map.updateSourcePoints(constants.sourcePois, p, n);
    }

    function updateMapManeuvers() {
        // update maneuvers drawn on the map
        var p = [];
        for (var i = 0; i < map.maneuvers.length; i++) {
            p.push(map.maneuvers[i].coordinate);
        }
        map.updateSourcePoints(constants.sourceManeuvers, p);
    }

    function updateMapRoute() {
        // update route drawn on the map
        var p = [];
        if (map.route.x)  {
            for (var i = 0; i < map.route.x.length; i++) {
                p.push(QtPositioning.coordinate(
                    map.route.y[i], map.route.x[i]));
            }
        }
        map.updateSourceLine(constants.sourceRoute, p);
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
        if (map.route.x && map.route.x.length > 0 &&
            map.route.y && map.route.y.length > 0) {
            var data = {};
            data.x = map.route.x;
            data.y = map.route.y;
            data.attribution = map.route.attribution;
            data.language = map.route.language;
            data.mode = map.route.mode;
        } else {
            var data = {};
        }
        py.call_sync("poor.storage.write_route", [data]);
    }

    function setBasemap() {
        // Set basemap and all properties specified in the
        // basemap file
        if (!py.ready) return;

        var basemap = py.call_sync("poor.app.get_basemap", []);

        map.urlDebug = basemap.urlDebug || false;
        map.urlSuffix = basemap.urlSuffix || "";
        if (typeof basemap.styleReferenceLayer !== 'undefined') map.styleReferenceLayer = basemap.styleReferenceLayer;
        else map.styleReferenceLayer = "waterway-label";
        map.pixelRatio = basemap.pixelRatio || Theme.pixelRatio * 1.5

        map.initLayers();
        positionMarker.init();

        // only one of styleUrl or styleJson can be specified
        if (basemap.styleUrl) map.styleUrl = basemap.styleUrl;
        else map.styleJson = basemap.styleJson || "";

        attribution.setInfo(basemap.attributionFull || basemap.attribution);
        attribution.setLogo(basemap.attributionLogo || "");
    }

    function setCenter(x, y) {
        // Set the current center position.
        // Create a new object to trigger animation.
        if (!x || !y) return;
        map.center = QtPositioning.coordinate(y, x);
    }

    function updateMargins() {
        // Finds new margins and sets them for the map

        // navigation block limits the view from the top
        var navheight = app.navigationBlock ? app.navigationBlock.height : 0;

        // Menu bottom limits view on the bottom.
        // During rotation, if menu button position changes
        // before height, it could cause negative menucut
        var menucut = Math.max(0, height - (app.menuButton ? app.menuButton.y : 0));

        // remaining height of the map view
        var freeheight = height - navheight - menucut;

        var margins;

        // If auto-rotate is on, the user is always heading up
        // on the screen and should see more ahead than behind.
        if (map.autoRotate) {
            margins = Qt.rect(
                0.1,               // x
                (menucut + 0.05*freeheight) / height,   // y
                0.8,                // width
                0.2*freeheight / height // height
            );

        } else {
            margins = Qt.rect(
                0.1,               // x
                (menucut + 0.05*freeheight) / height,   // y
                0.8,                // width
                0.9*freeheight / height // height
            );
        }

        map.margins = margins
    }

    Connections {
        target: app.navigationBlock
        onHeightChanged: map.updateMargins()
    }

    Connections {
        target: app.menuButton
        onYChanged: map.updateMargins()
    }
}
