/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2019 Rinigus, 2019 Purism SPC
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
import "."

DialogPL {
    id: dialog

    canAccept: gH.acceptableInput && gM.acceptableInput

    property int hour
    property int minute
    property var time

    Item {
        height: childrenRect.height
        width: parent.width

        Row {
            id: row
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: styler.themePaddingMedium

            TextField {
                id: gH
                horizontalAlignment: Text.AlignRight
                inputMethodHints: Qt.ImhDigitsOnly
                maximumLength: 2
                validator: IntValidator { bottom: 0;  top: 23 }
                Keys.onReturnPressed: gM.focus = true
                onTextChanged: hours = parseInt(text)
            }

            LabelPL {
                anchors.baseline: gH.baseline
                //anchors.verticalCenter: gH.verticalCenter
                text: ":"
            }

            TextField {
                id: gM
                horizontalAlignment: Text.AlignLeft
                inputMethodHints: Qt.ImhDigitsOnly
                maximumLength: 2
                validator: IntValidator { bottom: 0;  top: 59 }
                Keys.onReturnPressed: dialog.accept()
            }
        }
    }

    Component.onCompleted: {
        if (time != null) {
            hour = time.getHours();
            minute = time.getMinutes();
        }
        gH.text = ("00" + hour).substr(-2);
        gM.text = ("00" + minute).substr(-2);
        gH.forceActiveFocus();
    }

    onAccepted: {
        hour = parseInt(gH.text);
        minute = parseInt(gM.text);
        if (time == null) time = new Date();
        time.setHours(hour);
        time.setMinutes(minute);
        time.setSeconds(0);
    }
}
