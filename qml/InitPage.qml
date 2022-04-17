/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2014 Osmo Salomaa, 2018 Rinigus
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

PageEmptyPL {
    id: page
    title: "Pure Maps"

    property bool ready: false
    property var  licensesMissing
    property int  licenseIndex: -1

    BusyModal {
        id: busy
        running: true
        text: app.tr("Initializing")
    }

    Connections {
        target: py
        onReadyChanged: {
            if (!py.ready) return;
            page.ready = true
            // initialize conf before anything else
            app.conf.initialize();
            // check licenses
            licensesMissing = py.call_sync("poor.key.get_licenses_missing", []);
            // iterate through messages
            showStartMessages();
        }
    }

    function showStartMessages() {
        if (licenseIndex < 0) {
            // first check is for the fonts provider. Bump index to check
            // the license check with the next call
            licenseIndex = 0;

            // check font provider
            app.conf.set("font_provider", defaultFontProvider);
            var hasMapboxKey = py.evaluate("poor.key.has_mapbox")
            var hasMaptilerKey = py.evaluate("poor.key.has_maptiler")
            if ( (defaultFontProvider === "mapbox" && !hasMapboxKey) ||
                 (defaultFontProvider === "maptiler" && !hasMaptilerKey) ) {
                var provider = (defaultFontProvider === "mapbox") ? "Mapbox" : "MapTiler"
                var d = app.push(Qt.resolvedUrl("MessagePage.qml"), {
                             "acceptText": app.tr("Dismiss"),
                             "title": app.tr("Missing %1 key", provider),
                             "message": app.tr("Your installation is missing %1 API key. " +
                                               "Please register at %1 and fill in your personal API key " +
                                               "in Preferences. This key is not needed if you plan to use " +
                                               "Pure Maps with the offline map provider.", provider)
                         });
                d.Component.destruction.connect(showStartMessages)
                app.fontKeyMissing = true;
            } else showStartMessages();
        } else if (licenseIndex < licensesMissing.length) {
            app.pages.completeAnimation();
            var d = app.push(Qt.resolvedUrl("LicensePage.qml"), {
                         "title": licensesMissing[licenseIndex].title,
                         "key": licensesMissing[licenseIndex].id,
                         "text": licensesMissing[licenseIndex].text
                     });
            d.Component.destruction.connect(showStartMessages)
            licenseIndex += 1;
        } else if (programVariantJollaStore &&
                   app.conf.get("message_jolla_store_last_version") !== programVersion) {
                var d = app.push(Qt.resolvedUrl("MessagePage.qml"), {
                             "acceptText": app.tr("Dismiss"),
                             "title": app.tr("Pure Maps at Jolla Store"),
                             "message": app.tr("You are using Pure Maps distributed through Jolla Store. " +
                                               "Due to Jolla Store restrictions, Pure Maps distributed via that store has several limitations. " +
                                               "With the introduction of Sailjail, limitations include inability to provide voice prompts, " +
                                               "display current street and speed limits through " +
                                               "matching position to street network.\n\n" +
                                               "To get fully functional Pure Maps, it is recommended to use Sailfish Chum and install Pure Maps from there.")
                         });
                d.Component.destruction.connect(showStartMessages)
                app.conf.set("message_jolla_store_last_version", programVersion);
        } else // all messages shown
            start();
    }

    function start() {
        py.call("poor.app.initialize", [], function () {
            busy.running = false
            app.rootPage = app.pages.replace(Qt.resolvedUrl("RootPage.qml"));
        });
    }
}
