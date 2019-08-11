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
import org.kde.kirigami 2.4 as Kirigami

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
    property real themeFontSizeOnMap: themeFontSizeSmall

    // colors
    // block background (navigation, poi panel, bubble)
    property color blockBg: Kirigami.Theme.backgroundColor
    // variant of navigation icons
    property string navigationIconsVariant: darkTheme ? "white" : "black"
    // descriptive items
    property color themeHighlightColor: Kirigami.Theme.textColor
    // due to https://bugreports.qt.io/browse/QTBUG-53189
    // we cannot use Kirigami palette on links
    // navigation items (to be clicked). When getting link colors,
    // those are rather pale and hard to see. Swapping to
    // regular text color
    property color themePrimaryColor: palette.text
    // navigation items, secondary
    property color themeSecondaryColor: inactivePalette.text
    // descriptive items, secondary
    property color themeSecondaryHighlightColor: Kirigami.Theme.disabledTextColor

    // button sizes
    property real themeButtonWidthLarge: 256
    property real themeButtonWidthMedium: 180

    // icon sizes
    property real themeIconSizeLarge: 2.5*themeFontSizeLarge
    property real themeIconSizeMedium: 2*themeFontSizeLarge
    property real themeIconSizeSmall: 1.5*themeFontSizeLarge
    // used icons
    property string iconAbout: Qt.resolvedUrl("../icons/fallback/help-about-symbolic.svg")
    property string iconBack: Qt.resolvedUrl("../icons/fallback/go-previous-symbolic.svg")
    property string iconClear: Qt.resolvedUrl("../icons/fallback/edit-clear-all-symbolic.svg")
    property string iconClose: Qt.resolvedUrl("../icons/fallback/window-close-symbolic.svg")
    property string iconDelete: Qt.resolvedUrl("../icons/fallback/edit-delete-symbolic.svg")
    property string iconDot: Qt.resolvedUrl("../icons/fallback/find-location-symbolic.svg")
    property string iconDown: Qt.resolvedUrl("../icons/fallback/go-down-symbolic.svg")
    property string iconEdit: Qt.resolvedUrl("../icons/fallback/document-edit-symbolic.svg")
    property string iconEditClear: Qt.resolvedUrl("../icons/fallback/edit-clear-symbolic.svg")
    property string iconFavorite: Qt.resolvedUrl("../icons/fallback/bookmark-new-symbolic.svg")
    property string iconFavoriteSelected: Qt.resolvedUrl("../icons/fallback/user-bookmarks-symbolic.svg")
    property string iconForward: Qt.resolvedUrl("../icons/fallback/go-next-symbolic.svg")
    property string iconManeuvers: Qt.resolvedUrl("../icons/fallback/maneuvers-symbolic.svg")
    property string iconMaps: Qt.resolvedUrl("../icons/fallback/map-layers-symbolic.svg")
    property string iconMenu: Qt.resolvedUrl("../icons/fallback/open-menu-symbolic.svg")
    property string iconNavigate: Qt.resolvedUrl("../icons/fallback/route-symbolic.svg")
    property string iconNavigateTo: Qt.resolvedUrl("../icons/fallback/route-to-symbolic.svg")
    property string iconNavigateFrom: Qt.resolvedUrl("../icons/fallback/route-from-symbolic.svg")
    property string iconNearby: Qt.resolvedUrl("../icons/fallback/nearby-search-symbolic.svg")
    property string iconPause: Qt.resolvedUrl("../icons/fallback/media-playback-pause-symbolic.svg")
    property string iconPhone: Qt.resolvedUrl("../icons/fallback/call-start-symbolic.svg")
    property string iconPreferences: Qt.resolvedUrl("../icons/fallback/preferences-system-symbolic.svg")
    property string iconProfileMixed: Qt.resolvedUrl("../icons/fallback/profile-mixed-symbolic.svg")
    property string iconProfileOffline: Qt.resolvedUrl("../icons/fallback/profile-offline-symbolic.svg")
    property string iconProfileOnline: Qt.resolvedUrl("../icons/fallback/profile-online-symbolic.svg")
    property string iconRefresh: Qt.resolvedUrl("../icons/fallback/view-refresh-symbolic.svg")
    property string iconSave: Qt.resolvedUrl("../icons/fallback/document-save-symbolic.svg")
    property string iconSearch: Qt.resolvedUrl("../icons/fallback/edit-find-symbolic.svg")
    property string iconShare: Qt.resolvedUrl("../icons/fallback/emblem-shared-symbolic.svg")
    property string iconShortlisted: Qt.resolvedUrl("../icons/fallback/shortlist-add-symbolic.svg")
    property string iconShortlistedSelected: Qt.resolvedUrl("../icons/fallback/shortlist-selected-symbolic.svg")
    property string iconStart: Qt.resolvedUrl("../icons/fallback/media-playback-start-symbolic.svg")
    property string iconStop: Qt.resolvedUrl("../icons/fallback/media-playback-stop-symbolic.svg")
    property string iconWebLink: Qt.resolvedUrl("../icons/fallback/web-browser-symbolic.svg")

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

    property bool darkTheme: (Kirigami.Theme.backgroundColor.r + Kirigami.Theme.backgroundColor.g +
                              Kirigami.Theme.backgroundColor.b) <
                             (Kirigami.Theme.textColor.r + Kirigami.Theme.textColor.g +
                              Kirigami.Theme.textColor.b)

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
