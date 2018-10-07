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
    // font sizes and family
    property string themeFontFamily: Theme.fontFamily
    property int  themeFontSizeHuge: Theme.fontSizeHuge
    property int  themeFontSizeExtraLarge: Theme.fontSizeExtraLarge
    property int  themeFontSizeLarge: Theme.fontSizeLarge
    property int  themeFontSizeMedium: Theme.fontSizeMedium
    property int  themeFontSizeSmall: Theme.fontSizeSmall
    property int  themeFontSizeExtraSmall: Theme.fontSizeExtraSmall

    // colors
    property color themeHighlightColor: Theme.highlightColor
    property color themePrimaryColor: Theme.primaryColor
    property color themeSecondaryColor: Theme.secondaryColor
    property color themeSecondaryHighlightColor: Theme.secondaryHighlightColor

    // button sizes
    property real themeButtonWidthLarge: Theme.buttonWidthLarge
    property real themeButtonWidthMedium: Theme.buttonWidthMedium

    // icon sizes
    property real themeIconSizeLarge: Theme.iconSizeLarge
    property real themeIconSizeMedium: Theme.iconSizeMedium

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
