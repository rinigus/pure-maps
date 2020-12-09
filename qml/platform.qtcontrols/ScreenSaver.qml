/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2020 Rinigus
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
import Nemo.DBus 2.0

Item {
    id: saver

    property string name
    property bool   preventBlanking
    property string reason

    DBusInterface {
        id: bus
        service: "org.freedesktop.ScreenSaver"
        path: "/org/freedesktop/ScreenSaver"
        iface: "org.freedesktop.ScreenSaver"

        property int  cookie: 0
        property bool error: false
        property bool inhibited: false

        onErrorChanged: {
            if (error) console.log('DBus connection with Screen Saver has switched to Error state');
        }

        function inhibit() {
            if (inhibited || error) return;
            call("Inhibit", [name, reason],
                 function(result) {
                     cookie = result;
                     inhibited = true;
                 },
                 function(error, message) {
                     console.log("Error while calling Screensaver Inhibit");
                     console.log("Call failed", error, "message:", message);
                     cookie = 0;
                     inhibited = false;
                     bus.error = true;
                 });
        }

        function uninhibit() {
            if (!inhibited || error) return;
            typedCall("UnInhibit", [{'type': 'u', 'value': cookie}],
                      function(result) {
                          inhibited = false;
                      },
                      function(error, message) {
                          console.log("Error while calling ScreenSaver UnInhibit");
                          console.log("Call failed", error, "message:", message);
                          bus.error = true;
                      });
        }
    }

    onPreventBlankingChanged: {
        if (preventBlanking) bus.inhibit();
        else bus.uninhibit();
    }
}
