/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2018 Rinigus
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
import QtQuick.Window 2.2

QtObject {
    // font sizes and family
    property string themeFontFamily: Qt.application.font.family
    property string themeFontFamilyHeading: Qt.application.font.family
    property int  themeFontSizeHuge: Math.round(themeFontSizeMedium*3.0)
    property int  themeFontSizeExtraLarge: Math.round(themeFontSizeMedium*2.0)
    property int  themeFontSizeLarge: Math.round(themeFontSizeMedium*1.5)
    property int  themeFontSizeMedium: Math.round(Qt.application.font.pixelSize*1.0)
    property int  themeFontSizeSmall: Math.round(themeFontSizeMedium*0.9)
    property int  themeFontSizeExtraSmall: Math.round(themeFontSizeMedium*0.7)

    // colors
    // block background (navigation, poi panel, bubble)
    property color blockBg: "#F2F2F2"
    // variant of navigation icons
    property string navigationIconsVariant: "black"
    // descriptive items
    property color themeHighlightColor: "black"
    // navigation items (to be clicked)
    property color themePrimaryColor: "#020280"
    // navigation items, secondary
    property color themeSecondaryColor: "#4E4EFF"
    // descriptive items, secondary
    property color themeSecondaryHighlightColor: "#3E3E3E"

    // button sizes
    property real themeButtonWidthLarge: 256
    property real themeButtonWidthMedium: 180

    // icon sizes
    property real themeIconSizeLarge: 2.5*themeFontSizeLarge
    property real themeIconSizeMedium: 2*themeFontSizeLarge
    property real themeIconSizeSmall: 1.5*themeFontSizeLarge
    // used icons
    property string iconAbout
    property string iconBack
    property string iconClear
    property string iconDelete
    property string iconDot
    property string iconFavorite
    property string iconFavoriteSelected
    property string iconForward
    property string iconMaps
    property string iconMenu
    property string iconNavigate
    property string iconNearby
    property string iconPause
    property string iconPhone
    property string iconPreferences
    property string iconProfile
    property string iconRefresh
    property string iconSearch
    property string iconShare
    property string iconShortlisted
    property string iconShortlistedSelected
    property string iconStart
    property string iconStop
    property string iconWebLink

    // item sizes
    property real themeItemSizeLarge: themeFontSizeLarge * 3
    property real themeItemSizeSmall: themeFontSizeMedium * 3
    property real themeItemSizeExtraSmall: themeFontSizeSmall * 3

    // paddings and page margins
    property real themeHorizontalPageMargin: 1.25*themeFontSizeExtraLarge
    property real themePaddingLarge: 0.75*themeFontSizeExtraLarge
    property real themePaddingMedium: 0.5*themeFontSizeLarge
    property real themePaddingSmall: 0.25*themeFontSizeSmall

    property real themePixelRatio: Screen.devicePixelRatio

    function getIcon(name) {
        return py.call_sync("poor.app.icon.get_icon", [name]);
    }

    function initStyle() {
        iconAbout = getIcon("help-about-symbolic.symbolic");
        iconBack = getIcon("go-previous-symbolic.symbolic");
        iconClear = getIcon("edit-clear-all-symbolic.symbolic");
        iconDelete = getIcon("edit-delete-symbolic.symbolic");
        iconDot = getIcon("find-location-symbolic.symbolic");
        iconFavorite = getIcon("bookmark-new-symbolic.symbolic");
        iconFavoriteSelected = getIcon("user-bookmarks-symbolic.symbolic");
        iconForward = getIcon("go-next-symbolic.symbolic");
        iconMaps = getIcon("view-paged-symbolic.symbolic");
        iconMenu = getIcon("open-menu-symbolic.symbolic");
        iconNavigate = getIcon("send-to-symbolic.symbolic");
        iconNearby = getIcon("zoom-fit-best-symbolic.symbolic");
        iconPause = getIcon("media-playback-pause-symbolic.symbolic");
        iconPhone = getIcon("call-start-symbolic.symbolic");
        iconPreferences = getIcon("preferences-system-symbolic.symbolic");
        iconProfile = getIcon("network-server-symbolic.symbolic");
        iconRefresh = getIcon("view-refresh-symbolic.symbolic");
        iconSearch = getIcon("edit-find-symbolic.symbolic");
        iconShare = getIcon("emblem-shared-symbolic.symbolic");
        iconShortlisted = getIcon("checkbox-symbolic.symbolic");
        iconShortlistedSelected = getIcon("checkbox-checked-symbolic.symbolic");
        iconStart = getIcon("media-playback-start-symbolic.symbolic");
        iconStop = getIcon("media-playback-stop-symbolic.symbolic");
        iconWebLink = getIcon("web-browser-symbolic.symbolic");
    }
}
