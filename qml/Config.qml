/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2014 Osmo Salomaa, 2018-2020 Rinigus
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

Item {
    id: conf

    // cache certain frequently used properties locally
    property bool   autoCompleteGeo
    property bool   autoRotateWhenNavigating
    property string basemapAutoLight
    property bool   basemapAutoMode
    property string basemapLang
    property string basemapLight
    property string basemapType
    property string basemapVehicle
    property bool   compassUse: true
    property bool   developmentCoordinateCenter: false
    property bool   developmentShowZ: false
    property string followMeTransportMode
    property string keepAlive
    property string keepAliveBackground
    property string mapMatchingWhenIdle: "none"
    property bool   mapMatchingWhenNavigating
    property int    mapModeAutoSwitchTime: -1
    property bool   mapModeCleanOnStart
    property bool   mapModeCleanShowBasemap
    property bool   mapModeCleanShowCenter
    property bool   mapModeCleanShowCompass
    property bool   mapModeCleanShowGeocode
    property bool   mapModeCleanShowMenuButton
    property bool   mapModeCleanShowMeters
    property bool   mapModeCleanShowNavigate
    property bool   mapModeCleanShowNavigationStartPause
    property bool   mapModeCleanShowNavigationClear
    property bool   mapModeCleanShowScale
    property real   mapScale: 1
    property real   mapScaleNavigation: {
        if (!app || !app.transportMode)
            return app.conf.mapScaleNavigationCar;
        if (app.transportMode === "bicycle")
            return app.conf.mapScaleNavigationBicycle;
        if (app.transportMode === "foot")
            return app.conf.mapScaleNavigationFoot;
        if (app.transportMode === "transit")
            return app.conf.mapScaleNavigationTransit;
        return app.conf.mapScaleNavigationCar;
    }
    property real   mapScaleNavigationBicycle: 1
    property real   mapScaleNavigationCar: 1
    property real   mapScaleNavigationFoot: 1
    property real   mapScaleNavigationTransit: 1
    property real   mapZoomAutoTime
    property bool   mapZoomAutoWhenNavigating: false
    property real   mapZoomAutoZeroSpeedZ
    property real   navigationHorizontalAccuracy: 15.0
    property string profile
    property bool   reroute
    property bool   routePageShowDestinationsHelp: true
    property bool   routePageShowDestinationsHelpShown: false // not persistent, only this session
    property bool   showNarrative: false
    property bool   showNavigationSign: false
    property string showSpeedLimit
    property bool   smoothPositionAnimationWhenNavigating: false
    property bool   tiltWhenNavigating
    property int    trafficRerouteTime: -1
    property string units
    property string voiceGender
    property bool   voiceNavigation

    readonly property int animationDuration: 150

    readonly property var _mapQml2Py: {
        "autoCompleteGeo": "auto_complete_geo",
        "autoRotateWhenNavigating": "auto_rotate_when_navigating",
        "basemapAutoLight": "basemap_auto_light",
        "basemapAutoMode": "basemap_auto_mode",
        "basemapLight": "basemap_light",
        "basemapLang": "basemap_lang",
        "basemapLight": "basemap_light",
        "basemapType": "basemap_type",
        "basemapVehicle": "basemap_vehicle",
        "compassUse": "compass_use",
        "developmentCoordinateCenter": "devel_coordinate_center",
        "developmentShowZ": "devel_show_z",
        "followMeTransportMode": "follow_me_transport_mode",
        "keepAlive": "keep_alive",
        "keepAliveBackground": "keep_alive_background",
        "mapMatchingWhenIdle": "map_matching_when_idle",
        "mapMatchingWhenNavigating": "map_matching_when_navigating",
        "mapModeAutoSwitchTime": "map_mode_auto_switch_time",
        "mapModeCleanOnStart": "map_mode_clean_on_start",
        "mapModeCleanShowBasemap": "map_mode_clean_show_basemap",
        "mapModeCleanShowCenter": "map_mode_clean_show_center",
        "mapModeCleanShowCompass": "map_mode_clean_show_compass",
        "mapModeCleanShowGeocode": "map_mode_clean_show_geocode",
        "mapModeCleanShowMeters": "map_mode_clean_show_meters",
        "mapModeCleanShowMenuButton": "map_mode_clean_show_menu_button",
        "mapModeCleanShowNavigate": "map_mode_clean_show_navigate",
        "mapModeCleanShowNavigationStartPause": "map_mode_clean_show_navigation_start_pause",
        "mapModeCleanShowNavigationClear": "map_mode_clean_show_navigation_clear",
        "mapModeCleanShowScale": "map_mode_clean_show_scale",
        "mapScale": "map_scale",
        "mapScaleNavigationBicycle": "map_scale_navigation_bicycle",
        "mapScaleNavigationCar": "map_scale_navigation_car",
        "mapScaleNavigationFoot": "map_scale_navigation_foot",
        "mapScaleNavigationTransit": "map_scale_navigation_transit",
        "mapZoomAutoTime": "map_zoom_auto_time",
        "mapZoomAutoWhenNavigating": "map_zoom_auto_when_navigating",
        "mapZoomAutoZeroSpeedZ": "map_zoom_auto_zero_speed_z",
        "navigationHorizontalAccuracy": "navigation_horizontal_accuracy",
        "reroute": "reroute",
        "routePageShowDestinationsHelp": "route_page_show_destinations_help",
        "profile": "profile",
        "showNarrative": "show_narrative",
        "showNavigationSign": "show_navigation_sign",
        "showSpeedLimit": "show_speed_limit",
        "smoothPositionAnimationWhenNavigating": "smooth_position_animation_when_navigating",
        "tiltWhenNavigating": "tilt_when_navigating",
        "trafficRerouteTime": "traffic_reroute_time",
        "units": "units",
        "voiceGender": "voice_gender",
        "voiceNavigation": "voice_navigation"
    }

    Component.onCompleted: _update()

    onRoutePageShowDestinationsHelpChanged: set(_mapQml2Py["routePageShowDestinationsHelp"],
                                                routePageShowDestinationsHelp)

    Connections {
        target: py
        onConfigurationChanged: conf._update()
        onReadyChanged: conf._update()
    }

    function add(option, item) {
        // Add item to the value of option.
        return py.call_sync("poor.conf.add", [option, item]);
    }

    function contains(option, item) {
        // Return true if the value of option contains item.
        return py.call_sync("poor.conf.contains", [option, item]);
    }

    function get(option) {
        // Return the value of option.
        return py.call_sync("poor.conf.get", [option]);
    }

    function getDefault(option) {
        // Return default value of configuration option.
        return py.call_sync("poor.conf.get_default", [option]);
    }

    function initialize() {
        conf._update();
    }

    function remove(option, item) {
        // Remove item from the value of option.
        return py.call_sync("poor.conf.remove", [option, item]);
    }

    function set(option, value) {
        // Set the value of option.
        return py.call_sync("poor.conf.set", [option, value]);
    }

    function setProfile(value) {
        // Set current profile
        return py.call_sync("poor.app.set_profile", [value]);
    }

    function _update() {
        if (!py.ready) return;
        var c = py.call_sync("poor.conf.get_all", []);
        for (var k in _mapQml2Py) {
            var n = c[ _mapQml2Py[k] ];
            if (conf[k] !== n)
                conf[k] = n;
        }
    }

}
