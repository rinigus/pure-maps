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

import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Dialogs 1.2
import "."

PageEmptyPL {
    property alias  nameFilters: dialog.nameFilters
    property string selectedFilepath

    Label {
        id: viewPlaceholder
        anchors.fill: parent
        anchors.margins: app.styler.themeHorizontalPageMargin
        horizontalAlignment: Text.AlignHCenter
        text: app.tr("Please select a file")
        verticalAlignment: Text.AlignVCenter
        wrapMode: Text.WordWrap
    }

    FileDialog {
        id: dialog

        onAccepted: {
            var path = fileUrl.toString();
            // remove prefixed "file://"
            path = path.replace(/^(file:\/{2})/,"");
            // unescape html codes like '%23' for '#'
            selectedFilepath = decodeURIComponent(path);
            app.pages.pop();
        }

        onRejected: app.pages.pop()
    }

    onPageStatusActive: dialog.open()
}
