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
    property int  themeFontSizeHuge: themeFontSizeExtraLarge*1.2
    property int  themeFontSizeExtraLarge: FontUtils.sizeToPixels("x-large")
    property int  themeFontSizeLarge: FontUtils.sizeToPixels("large")
    property int  themeFontSizeMedium: FontUtils.sizeToPixels("medium")
    property int  themeFontSizeSmall: FontUtils.sizeToPixels("small")
    property int  themeFontSizeExtraSmall: FontUtils.sizeToPixels("x-small")
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
    property string iconAbout: "image://theme/info" //Qt.resolvedUrl("../../icons/help-about-symbolic.svg")
    property string iconBack: "image://theme/back" //Qt.resolvedUrl("../../icons/go-previous-symbolic.svg")
    property string iconClear: "image://theme/edit-delete" //Qt.resolvedUrl("../../icons/edit-delete-symbolic.svg")
    property string iconClose: "image://theme/close" //Qt.resolvedUrl("../../icons/window-close-symbolic.svg")
    property string iconDelete: "image://theme/delete" //Qt.resolvedUrl("../../icons/edit-delete-symbolic.svg")
    property string iconDot: "image://theme/gps" //Qt.resolvedUrl("../../icons/find-location-symbolic.svg")
    property string iconDown: "image://theme/down" //Qt.resolvedUrl("../../icons/go-down-symbolic.svg")
    property string iconEdit: "image://theme/edit" //Qt.resolvedUrl("../../icons/document-edit-symbolic.svg")
    property string iconEditClear: "image://theme/edit-clear" //Qt.resolvedUrl("../../icons/edit-clear-symbolic.svg")
    property string iconFavorite: Qt.resolvedUrl("../icons/uuitk/bookmark-new-symbolic.svg")
    property string iconFavoriteSelected: Qt.resolvedUrl("../icons/uuitk/user-bookmarks-symbolic.svg")
    property string iconForward: "image://theme/next" //Qt.resolvedUrl("../../icons/go-next-symbolic.svg")
    property string iconManeuvers: "image://theme/media-playlist-shuffle" //Qt.resolvedUrl("../../icons/maneuvers-symbolic.svg")
    property string iconMaps: Qt.resolvedUrl("../icons/uuitk/map-layers-symbolic.svg")
    property string iconMenu: "image://theme/navigation-menu" //Qt.resolvedUrl("../../icons/open-menu-symbolic.svg")
    property string iconNavigate: Qt.resolvedUrl("../icons/uuitk/route-to.svg")
    property string iconNavigateTo: iconNavigate
    property string iconNavigateFrom: Qt.resolvedUrl("../icons/uuitk/route-from.svg")
    property string iconNearby: Qt.resolvedUrl("../icons/uuitk/nearby-search.svg")
    property string iconPause: "image://theme/media-playback-pause" //Qt.resolvedUrl("../../icons/media-playback-pause-symbolic.svg")
    property string iconPhone: "image://theme/call-start" //Qt.resolvedUrl("../../icons/call-start-symbolic.svg")
    property string iconPreferences: "image://theme/settings" //Qt.resolvedUrl("../../icons/preferences-system-symbolic.svg")
    property string iconProfileMixed: Qt.resolvedUrl("../icons/uuitk/profile-mixed.svg")
    property string iconProfileOffline: Qt.resolvedUrl("../icons/uuitk/profile-offline.svg")
    property string iconProfileOnline: Qt.resolvedUrl("../icons/uuitk/profile-online.svg")
    property string iconRefresh: "image://theme/view-refresh" //Qt.resolvedUrl("../../icons/view-refresh-symbolic.svg")
    property string iconSave: "image://theme/save" //Qt.resolvedUrl("../../icons/document-save-symbolic.svg")
    property string iconSearch: "image://theme/find" //Qt.resolvedUrl("../../icons/edit-find-symbolic.svg")
    property string iconShare: "image://theme/share" //Qt.resolvedUrl("../../icons/emblem-shared-symbolic.svg")
    property string iconShortlisted: "image://theme/select-none" //Qt.resolvedUrl("../../icons/shortlist-add-symbolic.svg")
    property string iconShortlistedSelected: "image://theme/select" //Qt.resolvedUrl("../../icons/shortlist-selected-symbolic.svg")
    property string iconStart: "image://theme/media-playback-start" //Qt.resolvedUrl("../../icons/media-playback-start-symbolic.svg")
    property string iconStop: "image://theme/media-playback-stop" //Qt.resolvedUrl("../../icons/media-playback-stop-symbolic.svg")
    property string iconUp: "image://theme/up"
    property string iconWebLink: "image://theme/stock_website" //Qt.resolvedUrl("../../icons/web-browser-symbolic.svg")

    // item sizes
    property real themeItemSizeLarge: themeFontSizeLarge * 3
    property real themeItemSizeSmall: themeFontSizeMedium * 3
    property real themeItemSizeExtraSmall: themeFontSizeSmall * 3

    // paddings and page margins
    property real themeHorizontalPageMargin: units.gridUnit*2
    property real themePaddingLarge: units.gridUnit*2
    property real themePaddingMedium: units.gridUnit*1
    property real themePaddingSmall: units.gridUnit*0.8

    property real themePixelRatio: units.gridUnit / 8.0

    property bool darkTheme: (blockBg.r + blockBg.g + blockBg.b) <
                             (themePrimaryColor.r + themePrimaryColor.g +
                              themePrimaryColor.b)
}
