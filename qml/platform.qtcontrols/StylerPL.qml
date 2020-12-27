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
    property real themeFontSizeOnMap: themeFontSizeSmall

    // colors
    // block background (navigation, poi panel, bubble)
    property color blockBg: palette.window
    // variant of navigation icons
    property string navigationIconsVariant: darkTheme ? "white" : "black"
    // descriptive items
    property color themeHighlightColor: palette.windowText
    // navigation items (to be clicked)
    property color themePrimaryColor: palette.text
    // navigation items, secondary
    property color themeSecondaryColor: inactivePalette.text
    // descriptive items, secondary
    property color themeSecondaryHighlightColor: inactivePalette.text

    // button sizes
    property real themeButtonWidthLarge: 256
    property real themeButtonWidthMedium: 180

    // icon sizes
    property real themeIconSizeLarge: 2.5*themeFontSizeLarge
    property real themeIconSizeMedium: 2*themeFontSizeLarge
    property real themeIconSizeSmall: 1.5*themeFontSizeLarge
    // used icons
    property string iconAbout: "help-about-symbolic"
    property string iconBack: "go-previous-symbolic"
    property string iconClear: "edit-delete-symbolic"
    property string iconClose: "window-close-symbolic"
    property string iconDelete: "edit-delete-symbolic"
    property string iconDot: "find-location-symbolic"
    property string iconDown: "go-down-symbolic"
    property string iconEdit: "document-edit-symbolic"
    property string iconEditClear: "edit-clear-symbolic"
    property string iconFavorite: "bookmark-new-symbolic"
    property string iconFavoriteSelected: "user-bookmarks-symbolic"
    property string iconForward: "go-next-symbolic"
    property string iconManeuvers: "maneuvers-symbolic"
    property string iconMaps: "map-layers-symbolic"
    property string iconMenu: "open-menu-symbolic"
    property string iconNavigate: "route-symbolic"
    property string iconNavigateTo: "route-to-symbolic"
    property string iconNavigateFrom: "route-from-symbolic"
    property string iconNearby: "nearby-search-symbolic"
    property string iconPause: "media-playback-pause-symbolic"
    property string iconPhone: "call-start-symbolic"
    property string iconPreferences: "preferences-system-symbolic"
    property string iconProfileMixed: "profile-mixed-symbolic"
    property string iconProfileOffline: "profile-offline-symbolic"
    property string iconProfileOnline: "profile-online-symbolic"
    property string iconRefresh: "view-refresh-symbolic"
    property string iconSave: "document-save-symbolic"
    property string iconSearch: "edit-find-symbolic"
    property string iconShare: "emblem-shared-symbolic"
    property string iconShortlisted: "shortlist-add-symbolic"
    property string iconShortlistedSelected: "shortlist-selected-symbolic"
    property string iconStart: "media-playback-start-symbolic"
    property string iconStop: "media-playback-stop-symbolic"
    property string iconUp: "go-up-symbolic"
    property string iconWebLink: "web-browser-symbolic"

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

    property bool darkTheme: (blockBg.r + blockBg.g + blockBg.b) <
                             (themePrimaryColor.r + themePrimaryColor.g +
                              themePrimaryColor.b)

    property list<QtObject> children: [
        SystemPalette {
            id: palette
            colorGroup: SystemPalette.Active
        },

        SystemPalette {
            id: disabledPalette
            colorGroup: SystemPalette.Disabled
        },

        SystemPalette {
            id: inactivePalette
            colorGroup: SystemPalette.Inactive
        }
    ]
}
