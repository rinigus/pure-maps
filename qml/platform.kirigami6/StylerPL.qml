/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2026 Rinigus
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

import QtQuick
import QtQuick.Window
import org.kde.kirigami as Kirigami

QtObject {
    property string themeFontFamily: Kirigami.Theme.defaultFont.family
    property string themeFontFamilyHeading: Kirigami.Theme.defaultFont.family
    property int    themeFontSizeExtraLarge: Math.round(themeFontSizeMedium * 2.0)
    property int    themeFontSizeExtraSmall: Math.round(themeFontSizeMedium * 0.7)
    property int    themeFontSizeHuge: Math.round(themeFontSizeMedium * 3.0)
    property int    themeFontSizeLarge: Math.round(themeFontSizeMedium * 1.5)
    property int    themeFontSizeMedium: Math.round(Qt.application.font.pixelSize * 1.0)
    property real   themeFontSizeOnMap: themeFontSizeSmall
    property int    themeFontSizeSmall: Math.round(themeFontSizeMedium * 0.9)

    property color  blockBg: Kirigami.Theme.backgroundColor
    property string navigationIconsVariant: darkTheme ? "white" : "black"
    property color  themeHighlightColor: Kirigami.Theme.textColor
    property color  themePrimaryColor: Kirigami.Theme.linkColor
    property color  themeSecondaryColor: Kirigami.Theme.visitedLinkColor
    property color  themeSecondaryHighlightColor: Kirigami.Theme.disabledTextColor

    property real   themeButtonWidthLarge: 256
    property real   themeButtonWidthMedium: 180

    property real   themeIconSizeLarge: 2.5 * themeFontSizeLarge
    property real   themeIconSizeMedium: 2 * themeFontSizeLarge
    property real   themeIconSizeSmall: 1.5 * themeFontSizeLarge

    property string iconAbout: "help-about-symbolic"
    property string iconBack: "go-previous-symbolic"
    property string iconClear: "edit-delete-symbolic"
    property string iconClose: "window-close-symbolic"
    property string iconDelete: "edit-delete-symbolic"
    property string iconDot: "find-location-symbolic"
    property string iconDown: "go-down-symbolic"
    property string iconEdit: "document-edit-symbolic"
    property string iconEditClear: "edit-clear-symbolic"
    property string iconEmail: "mail-unread-symbolic"
    property string iconFavorite: "bookmark-new-symbolic"
    property string iconFavoriteSelected: "user-bookmarks-symbolic"
    property string iconForward: "go-next-symbolic"
    property string iconManeuvers: "maneuvers-symbolic"
    property string iconMaps: "map-layers-symbolic"
    property string iconMenu: "open-menu-symbolic"
    property string iconNavigate: "route-symbolic"
    property string iconNavigateFrom: "route-from-symbolic"
    property string iconNavigateTo: "route-to-symbolic"
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

    property real   themeItemSizeExtraSmall: themeItemSizeSmall * 0.75
    property real   themeItemSizeLarge: themeItemSizeSmall * 2
    property real   themeItemSizeSmall: Kirigami.Units.gridUnit * 2.5

    property real   themeHorizontalPageMargin: Kirigami.Units.largeSpacing * 2
    property real   themePaddingLarge: Kirigami.Units.largeSpacing * 2
    property real   themePaddingMedium: Kirigami.Units.largeSpacing
    property real   themePaddingSmall: Kirigami.Units.smallSpacing

    property real   themePixelRatio: Screen.devicePixelRatio

    property bool   darkTheme: (Kirigami.Theme.backgroundColor.r + Kirigami.Theme.backgroundColor.g + Kirigami.Theme.backgroundColor.b)
                                < (Kirigami.Theme.textColor.r + Kirigami.Theme.textColor.g + Kirigami.Theme.textColor.b)
}
