/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2021 Rinigus
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
import "."
import "platform"

DialogPL {
    id: dialog
    acceptText: acceptSwitch.checked ? app.tr("Accept") : app.tr("Decline")

    property alias  acceptLicense: acceptSwitch.checked
    property string key
    property alias  text: text.text

    Column {
        id: column
        spacing: styler.themePaddingLarge
        width: parent.width

        ListItemLabel {
            id: text
            color: styler.themeHighlightColor
            font.pixelSize: styler.themeFontSizeMedium
            height: implicitHeight
            truncMode: truncModes.none
            wrapMode: Text.WordWrap
        }

        TextSwitchPL {
            id: acceptSwitch
            checked: true
            text: app.tr("Accept license")
        }

        Spacer {
            height: styler.themePaddingLarge
        }
    }

    onAccepted: {
        if (acceptLicense)
            py.call_sync("poor.key.license_accept", [key])
        else
            py.call_sync("poor.key.license_decline", [key])
    }
}
