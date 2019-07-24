/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2014 Osmo Salomaa, 2018 Rinigus
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
    property bool   developmentCoordinateCenter: false
    property bool   developmentShowZ: false
    property string keepAlive
    property string mapMatchingWhenFollowing
    property string mapMatchingWhenIdle
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
    property bool   mapModeCleanShowScale
    property real   mapZoomAutoTime
    property bool   mapZoomAutoWhenNavigating: false
    property real   mapZoomAutoZeroSpeedZ
    property string profile
    property bool   reroute
    property bool   showNarrative: false
    property bool   showNavigationSign: false
    property string showSpeedLimit
    property bool   tiltWhenNavigating
    property string units
    property string voiceGender
    property bool   voiceNavigation

    readonly property int animationDuration: 150

    Component.onCompleted: _update()

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
        conf.autoCompleteGeo = c.auto_complete_geo;
        conf.autoRotateWhenNavigating = c.auto_rotate_when_navigating;
        conf.basemapAutoLight = c.basemap_auto_light;
        conf.basemapAutoMode = c.basemap_auto_mode;
        conf.basemapLight = c.basemap_light;
        conf.basemapLang = c.basemap_lang;
        conf.basemapLight = c.basemap_light;
        conf.basemapType = c.basemap_type;
        conf.basemapVehicle = c.basemap_vehicle;
        conf.developmentCoordinateCenter = c.devel_coordinate_center;
        conf.developmentShowZ = c.devel_show_z;
        conf.keepAlive = c.keep_alive;
        conf.mapMatchingWhenFollowing = c.map_matching_when_following;
        conf.mapMatchingWhenIdle = c.map_matching_when_idle;
        conf.mapMatchingWhenNavigating = c.map_matching_when_navigating;
        conf.mapModeAutoSwitchTime = c.map_mode_auto_switch_time;
        conf.mapModeCleanOnStart = c.map_mode_clean_on_start;
        conf.mapModeCleanShowBasemap = c.map_mode_clean_show_basemap;
        conf.mapModeCleanShowCenter = c.map_mode_clean_show_center;
        conf.mapModeCleanShowCompass = c.map_mode_clean_show_compass;
        conf.mapModeCleanShowGeocode = c.map_mode_clean_show_geocode;
        conf.mapModeCleanShowMeters = c.map_mode_clean_show_meters;
        conf.mapModeCleanShowMenuButton = c.map_mode_clean_show_menu_button;
        conf.mapModeCleanShowNavigate = c.map_mode_clean_show_navigate;
        conf.mapModeCleanShowScale = c.map_mode_clean_show_scale;
        conf.mapZoomAutoTime = c.map_zoom_auto_time;
        conf.mapZoomAutoWhenNavigating = c.map_zoom_auto_when_navigating;
        conf.mapZoomAutoZeroSpeedZ = c.map_zoom_auto_zero_speed_z;
        conf.reroute = c.reroute;
        conf.profile = c.profile;
        conf.showNarrative = c.show_narrative;
        conf.showNavigationSign = c.show_navigation_sign;
        conf.showSpeedLimit = c.show_speed_limit;
        conf.tiltWhenNavigating = c.tilt_when_navigating;
        conf.units = c.units;
        conf.voiceGender = c.voice_gender;
        conf.voiceNavigation = c.voice_navigation;
    }

}
