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
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

Kirigami.GlobalDrawer {
    id: menu

    handleVisible: false
    maximumSize: Math.max(0, Math.min((QQC2.ApplicationWindow.window?.width ?? width) - 2 * Kirigami.Units.largeSpacing,
                                      Kirigami.Units.gridUnit * 30))
    minimumSize: Math.min(maximumSize, Kirigami.Units.gridUnit * 18)
    preferredSize: Math.min(maximumSize, Math.max(minimumSize, _preferredMenuWidth))

    property string         banner // compatibility; latest Kirigami has no bannerImageSource
    default property alias  content: menu.items
    property list<QtObject> items
    property var            pageMenu

    readonly property real _preferredMenuWidth: textMetrics.width
                                                + styler.themeHorizontalPageMargin * 2
                                                + styler.themeItemSizeSmall * 0.8
                                                + styler.themePaddingLarge
    readonly property string _widestText: "Share current position (not ready)" // example text

    TextMetrics {
        id: textMetrics

        font.family: styler.themeFontFamily
        font.pixelSize: styler.themeFontSizeMedium
        text: menu._widestText
    }

    Component.onCompleted: {
        for (const item of items) {
            if (item.isAction) actions.push(item);
        }

        if (!pageMenu) return;
        for (const item of pageMenu.items) actions.push(item);
    }
}
