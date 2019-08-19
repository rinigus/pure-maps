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
import Ubuntu.Components 1.3
import Ubuntu.Components.Themes 1.3

QtObject {
    // font sizes and family
    property string themeFontFamily: Qt.application.font.family
    property string themeFontFamilyHeading: Qt.application.font.family
    property int  themeFontSizeHuge: Math.round(themeFontSizeMedium*3.0)
    property int  themeFontSizeExtraLarge: Math.round(themeFontSizeMedium*2.0)
    property int  themeFontSizeLarge: Math.round(themeFontSizeMedium*1.5)
    property int  themeFontSizeMedium: units.gridUnit*2
    property int  themeFontSizeSmall: Math.round(themeFontSizeMedium*0.9)
    property int  themeFontSizeExtraSmall: Math.round(themeFontSizeMedium*0.7)
    property real themeFontSizeOnMap: themeFontSizeSmall

    // colors
    // block background (navigation, poi panel, bubble)
    property color blockBg: theme.palette.normal.background
    // variant of navigation icons
    property string navigationIconsVariant: darkTheme ? "white" : "black"
    // descriptive items
    property color themeHighlightColor: theme.palette.normal.backgroundText
    // navigation items (to be clicked)
    property color themePrimaryColor: theme.palette.normal.baseText
    // navigation items, secondary
    property color themeSecondaryColor: theme.palette.normal.baseText
    // descriptive items, secondary
    property color themeSecondaryHighlightColor: theme.palette.normal.backgroundSecondaryText

    // button sizes
    property real themeButtonWidthLarge: units.gridUnit*32
    property real themeButtonWidthMedium: units.gridUnit*22

    // icon sizes
    property real themeIconSizeLarge: units.gridUnit*7
    property real themeIconSizeMedium: units.gridUnit*5
    property real themeIconSizeSmall: units.gridUnit*4
    // used icons
    // used icons
    property string iconAbout: Qt.resolvedUrl("../../icons/help-about-symbolic.svg")
    property string iconBack: Qt.resolvedUrl("../../icons/go-previous-symbolic.svg")
    property string iconClear: Qt.resolvedUrl("../../icons/edit-clear-all-symbolic.svg")
    property string iconClose: Qt.resolvedUrl("../../icons/window-close-symbolic.svg")
    property string iconDelete: Qt.resolvedUrl("../../icons/edit-delete-symbolic.svg")
    property string iconDot: Qt.resolvedUrl("../../icons/find-location-symbolic.svg")
    property string iconDown: Qt.resolvedUrl("../../icons/go-down-symbolic.svg")
    property string iconEdit: Qt.resolvedUrl("../../icons/document-edit-symbolic.svg")
    property string iconEditClear: Qt.resolvedUrl("../../icons/edit-clear-symbolic.svg")
    property string iconFavorite: Qt.resolvedUrl("../../icons/bookmark-new-symbolic.svg")
    property string iconFavoriteSelected: Qt.resolvedUrl("../../icons/user-bookmarks-symbolic.svg")
    property string iconForward: Qt.resolvedUrl("../../icons/go-next-symbolic.svg")
    property string iconManeuvers: Qt.resolvedUrl("../../icons/maneuvers-symbolic.svg")
    property string iconMaps: Qt.resolvedUrl("../../icons/map-layers-symbolic.svg")
    property string iconMenu: Qt.resolvedUrl("../../icons/open-menu-symbolic.svg")
    property string iconNavigate: Qt.resolvedUrl("../../icons/route-symbolic.svg")
    property string iconNavigateTo: Qt.resolvedUrl("../../icons/route-to-symbolic.svg")
    property string iconNavigateFrom: Qt.resolvedUrl("../../icons/route-from-symbolic.svg")
    property string iconNearby: Qt.resolvedUrl("../../icons/nearby-search-symbolic.svg")
    property string iconPause: Qt.resolvedUrl("../../icons/media-playback-pause-symbolic.svg")
    property string iconPhone: Qt.resolvedUrl("../../icons/call-start-symbolic.svg")
    property string iconPreferences: Qt.resolvedUrl("../../icons/preferences-system-symbolic.svg")
    property string iconProfileMixed: Qt.resolvedUrl("../../icons/profile-mixed-symbolic.svg")
    property string iconProfileOffline: Qt.resolvedUrl("../../icons/profile-offline-symbolic.svg")
    property string iconProfileOnline: Qt.resolvedUrl("../../icons/profile-online-symbolic.svg")
    property string iconRefresh: Qt.resolvedUrl("../../icons/view-refresh-symbolic.svg")
    property string iconSave: Qt.resolvedUrl("../../icons/document-save-symbolic.svg")
    property string iconSearch: Qt.resolvedUrl("../../icons/edit-find-symbolic.svg")
    property string iconShare: Qt.resolvedUrl("../../icons/emblem-shared-symbolic.svg")
    property string iconShortlisted: Qt.resolvedUrl("../../icons/shortlist-add-symbolic.svg")
    property string iconShortlistedSelected: Qt.resolvedUrl("../../icons/shortlist-selected-symbolic.svg")
    property string iconStart: Qt.resolvedUrl("../../icons/media-playback-start-symbolic.svg")
    property string iconStop: Qt.resolvedUrl("../../icons/media-playback-stop-symbolic.svg")
    property string iconWebLink: Qt.resolvedUrl("../../icons/web-browser-symbolic.svg")

    // item sizes
    property real themeItemSizeLarge: themeFontSizeLarge * 3
    property real themeItemSizeSmall: themeFontSizeMedium * 3
    property real themeItemSizeExtraSmall: themeFontSizeSmall * 3

    // paddings and page margins
    property real themeHorizontalPageMargin: 1.25*themeFontSizeExtraLarge
    property real themePaddingLarge: 0.75*themeFontSizeExtraLarge
    property real themePaddingMedium: 0.5*themeFontSizeLarge
    property real themePaddingSmall: 0.25*themeFontSizeSmall

    property real themePixelRatio: units.gridUnit / 8.0

    property bool darkTheme: (blockBg.r + blockBg.g + blockBg.b) <
                             (themePrimaryColor.r + themePrimaryColor.g +
                              themePrimaryColor.b)
}
