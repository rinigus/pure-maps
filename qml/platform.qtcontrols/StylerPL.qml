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

QtObject {
    // font sizes and family
    property string themeFontFamily: Math.round(Qt.application.font.family)
    property string themeFontFamilyHeading: Math.round(Qt.application.font.family)
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

    // used icons
    property string iconAbout: "image://theme/icon-m-about"
    property string iconClear: "image://theme/icon-m-clear"
    property string iconDelete: "image://theme/icon-m-delete"
    property string iconDot: "find-location-symbolic"
    property string iconFavorite: "image://theme/icon-m-favorite"
    property string iconFavoriteSelected: "image://theme/icon-m-favorite-selected"
    property string iconMaps: "image://theme/icon-m-levels"
    property string iconMenu: "image://theme/icon-m-menu"
    property string iconNavigate: "image://theme/icon-m-car"
    property string iconNearby: "image://theme/icon-m-whereami"
    property string iconPause: "image://theme/icon-m-pause"
    property string iconPhone: "image://theme/icon-m-phone"
    property string iconRefresh: "image://theme/icon-m-refresh"
    property string iconSearch: "image://theme/icon-m-search"
    property string iconShare: "image://theme/icon-m-share"
    property string iconStart: "image://theme/icon-m-play"
    property string iconStop: "image://theme/icon-m-clear"
    property string iconWebLink: "image://theme/icon-m-link"

    // item sizes
    property real themeItemSizeLarge: themeFontSizeLarge * 3
    property real themeItemSizeSmall: themeFontSizeMedium * 3
    property real themeItemSizeExtraSmall: themeFontSizeSmall * 3

    // paddings and page margins
    property real themeHorizontalPageMargin: 1.25*themeFontSizeExtraLarge
    property real themePaddingLarge: 0.75*themeFontSizeExtraLarge
    property real themePaddingMedium: 0.5*themeFontSizeLarge
    property real themePaddingSmall: 0.25*themeFontSizeSmall

    property real themePixelRatio: 1

    function getIcon(name) {
        return py.call_sync("poor.app.icon.get_icon", [name]);
    }

    function initStyle() {
        iconAbout = getIcon("help-about-symbolic");
        iconClear = getIcon("edit-clear-all-symbolic");
        iconDelete = getIcon("edit-delete-symbolic");
        iconDot = getIcon("find-location-symbolic");
        iconFavorite = getIcon("bookmark-new-symbolic");
        iconFavoriteSelected = getIcon("user-bookmarks-symbolic");
        iconMaps = getIcon("view-paged-symbolic");
        iconMenu = getIcon("open-menu-symbolic");
        iconNavigate = getIcon("send-to-symbolic");
        iconNearby = getIcon("zoom-fit-best-symbolic");
        iconPause = getIcon("media-playback-pause-symbolic");
        iconPhone = getIcon("call-start-symbolic");
        iconRefresh = getIcon("view-refresh-symbolic");
        iconSearch = getIcon("edit-find-symbolic");
        iconShare = getIcon("emblem-shared-symbolic");
        iconStart = getIcon("media-playback-start-symbolic");
        iconStop = getIcon("media-playback-stop-symbolic");
        iconWebLink = getIcon("web-browser-symbolic");
    }
}
