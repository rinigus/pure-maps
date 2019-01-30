/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2018-2019 Rinigus, 2019 Purism SPC
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
import org.kde.kirigami 2.5 as Kirigami

QtObject {
    // font sizes and family
    property string themeFontFamily: Kirigami.Theme.defaultFont
    property string themeFontFamilyHeading: Kirigami.Theme.defaultFont
    property int  themeFontSizeHuge: Math.round(themeFontSizeMedium*3.0)
    property int  themeFontSizeExtraLarge: Math.round(themeFontSizeMedium*2.0)
    property int  themeFontSizeLarge: Math.round(themeFontSizeMedium*1.5)
    property int  themeFontSizeMedium: Math.round(Qt.application.font.pixelSize*1.0)
    property int  themeFontSizeSmall: Math.round(themeFontSizeMedium*0.9)
    property int  themeFontSizeExtraSmall: Math.round(themeFontSizeMedium*0.7)

    // colors
    // block background (navigation, poi panel, bubble)
    property color blockBg: Kirigami.Theme.backgroundColor
    // variant of navigation icons
    property string navigationIconsVariant: "black"
    // descriptive items
    property color themeHighlightColor: Kirigami.Theme.textColor
    // navigation items (to be clicked)
    property color themePrimaryColor: Qt.darker(Kirigami.Theme.linkColor, 2.0)
    // navigation items, secondary
    property color themeSecondaryColor: Qt.darker(Kirigami.Theme.visitedLinkColor, 2.0)
    // descriptive items, secondary
    property color themeSecondaryHighlightColor: Qt.darker(Kirigami.Theme.disabledTextColor, 2.0)

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
    property real themeItemSizeLarge: themeItemSizeSmall * 2
    property real themeItemSizeSmall: Kirigami.Units.gridUnit * 2.5
    property real themeItemSizeExtraSmall: themeItemSizeSmall * 0.75

    // paddings and page margins
    property real themeHorizontalPageMargin: Kirigami.Units.largeSpacing * 2
    property real themePaddingLarge: Kirigami.Units.largeSpacing * 2
    property real themePaddingMedium: Kirigami.Units.largeSpacing * 1
    property real themePaddingSmall: Kirigami.Units.smallSpacing

    property real themePixelRatio: 1 //Screen.devicePixelRatio

    function getIcon(name) {
        return py.call_sync("poor.app.icon.get_icon", [name]);
    }

    function initStyle() {
        iconAbout = getIcon("help-about-symbolic");
        iconBack = getIcon("go-previous-symbolic");
        iconClear = getIcon("edit-clear-all-symbolic");
        iconDelete = getIcon("edit-delete-symbolic");
        iconDot = getIcon("find-location-symbolic");
        iconFavorite = getIcon("bookmark-new-symbolic");
        iconFavoriteSelected = getIcon("user-bookmarks-symbolic");
        iconForward = getIcon("go-next-symbolic");
        iconMaps = getIcon("view-paged-symbolic") || getIcon("map-mercator");
        iconMenu = getIcon("open-menu-symbolic");
        iconNavigate = getIcon("send-to-symbolic");
        iconNearby = getIcon("zoom-fit-best-symbolic");
        iconPause = getIcon("media-playback-pause-symbolic");
        iconPhone = getIcon("call-start-symbolic");
        iconPreferences = getIcon("preferences-system-symbolic") || getIcon("settings-configure");
        iconProfile = getIcon("network-server-symbolic");
        iconRefresh = getIcon("view-refresh-symbolic");
        iconSearch = getIcon("edit-find-symbolic");
        iconShare = getIcon("emblem-shared-symbolic");
        iconShortlisted = getIcon("checkbox-symbolic") || getIcon("rectangle-shape");
        iconShortlistedSelected = getIcon("checkbox-checked-symbolic") || getIcon("checkbox");
        iconStart = getIcon("media-playback-start-symbolic");
        iconStop = getIcon("media-playback-stop-symbolic");
        iconWebLink = getIcon("web-browser-symbolic") || getIcon("plasma-browser-integration");
    }
}
