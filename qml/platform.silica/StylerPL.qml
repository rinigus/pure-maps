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
import Sailfish.Silica 1.0

QtObject {
    readonly property bool isSilica: true
    
    // font sizes and family
    property string themeFontFamily: Theme.fontFamily
    property string themeFontFamilyHeading: Theme.fontFamilyHeading
    property int  themeFontSizeHuge: Theme.fontSizeHuge
    property int  themeFontSizeExtraLarge: Theme.fontSizeExtraLarge
    property int  themeFontSizeLarge: Theme.fontSizeLarge
    property int  themeFontSizeMedium: Theme.fontSizeMedium
    property int  themeFontSizeSmall: Theme.fontSizeSmall
    property int  themeFontSizeExtraSmall: Theme.fontSizeExtraSmall
    property real themeFontSizeOnMap: themeFontSizeExtraSmall * 0.75

    // colors
    // block background (navigation, poi panel, bubble)
    property color blockBg: Theme.overlayBackgroundColor || "#e6000000"
    // variant of navigation icons
    property string navigationIconsVariant: Theme.colorScheme ? "black" : "white"
    // descriptive items
    property color themeHighlightColor: Theme.highlightColor
    // navigation items (to be clicked)
    property color themePrimaryColor: Theme.primaryColor
    // navigation items, secondary
    property color themeSecondaryColor: Theme.secondaryColor
    // descriptive items, secondary
    property color themeSecondaryHighlightColor: Theme.secondaryHighlightColor

    // button sizes
    property real themeButtonWidthLarge: Theme.buttonWidthLarge
    property real themeButtonWidthMedium: Theme.buttonWidthMedium

    // icon sizes
    property real themeIconSizeLarge: Theme.iconSizeLarge
    property real themeIconSizeMedium: Theme.iconSizeMedium
    property real themeIconSizeSmall: Theme.iconSizeSmallPlus

    // used icons
    property string iconAbout: "image://theme/icon-m-about"
    property string iconBack: "image://theme/icon-m-back"
    property string iconClear: "image://theme/icon-m-clear"
    property string iconClose: "image://theme/icon-m-dismiss"
    property string iconDelete: "image://theme/icon-m-delete"
    property string iconDot: Theme.colorScheme ? Qt.resolvedUrl("../icons/sailfishos/center-black.svg") : Qt.resolvedUrl("../icons/sailfishos/center-white.svg")
    property string iconDown: "image://theme/icon-m-down"
    property string iconEdit: "image://theme/icon-m-edit"
    property string iconEditClear: "image://theme/icon-m-clear"
    property string iconFavorite: "image://theme/icon-m-favorite"
    property string iconFavoriteSelected: "image://theme/icon-m-favorite-selected"
    property string iconManeuvers: "image://theme/icon-m-shuffle"
    property string iconMaps: "image://theme/icon-m-levels"
    property string iconMenu: "image://theme/icon-m-menu"
    property string iconNavigate: Theme.colorScheme ? Qt.resolvedUrl("../icons/sailfishos/route-to-black.svg") : Qt.resolvedUrl("../icons/sailfishos/route-to-white.svg")
    property string iconNavigateTo: iconNavigate
    property string iconNavigateFrom: Theme.colorScheme ? Qt.resolvedUrl("../icons/sailfishos/route-from-black.svg") : Qt.resolvedUrl("../icons/sailfishos/route-from-white.svg")
    property string iconNearby: Theme.colorScheme ? Qt.resolvedUrl("../icons/sailfishos/nearby-search-black.svg") : Qt.resolvedUrl("../icons/sailfishos/nearby-search-white.svg")
    property string iconPause: "image://theme/icon-m-pause"
    property string iconPhone: "image://theme/icon-m-phone"
    property string iconPreferences: "image://theme/icon-m-developer-mode"
    property string iconProfileMixed: Theme.colorScheme ? Qt.resolvedUrl("../icons/sailfishos/profile-mixed-black.svg") : Qt.resolvedUrl("../icons/sailfishos/profile-mixed-white.svg")
    property string iconProfileOffline: Theme.colorScheme ? Qt.resolvedUrl("../icons/sailfishos/profile-offline-black.svg") : Qt.resolvedUrl("../icons/sailfishos/profile-offline-white.svg")
    property string iconProfileOnline: Theme.colorScheme ? Qt.resolvedUrl("../icons/sailfishos/profile-online-black.svg") : Qt.resolvedUrl("../icons/sailfishos/profile-online-white.svg")
    property string iconRefresh: "image://theme/icon-m-refresh"
    property string iconSave: "image://theme/icon-m-acknowledge"
    property string iconSearch: "image://theme/icon-m-search"
    property string iconShare: "image://theme/icon-m-share"
    property string iconShortlisted: "image://theme/icon-m-annotation"
    property string iconShortlistedSelected: "image://theme/icon-m-annotation-selected"
    property string iconStart: "image://theme/icon-m-play"
    property string iconStop: "image://theme/icon-m-clear"
    property string iconUp: "image://theme/icon-m-up"
    property string iconWebLink: "image://theme/icon-m-link"

    // item sizes
    property real themeItemSizeLarge: Theme.itemSizeLarge
    property real themeItemSizeSmall: Theme.itemSizeSmall
    property real themeItemSizeExtraSmall: Theme.itemSizeExtraSmall

    // paddings and page margins
    property real themeHorizontalPageMargin: Theme.horizontalPageMargin
    property real themePaddingLarge: Theme.paddingLarge
    property real themePaddingMedium: Theme.paddingMedium
    property real themePaddingSmall: Theme.paddingSmall

    property real themePixelRatio: Theme.pixelRatio
}
