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

import QtQuick 2.0
import QtPositioning 5.3
import Nemo.DBus 2.0
import "."

Item {
    id: commander

    DBusAdaptor {
        id: dbus
        bus: DBus.SessionBus
        iface: 'io.github.rinigus.PureMaps'
        path: '/io/github/rinigus/PureMaps'
        service: 'io.github.rinigus.PureMaps'

        xml:"
<interface name='io.github.rinigus.PureMaps'>
  <method name='Activate'>
    <arg type='a{sv}' name='platform_data' direction='in'/>
  </method>
  <method name='ActivateAction'>
    <arg type='s' name='action_name' direction='in'/>
    <arg type='av' name='parameter' direction='in'/>
    <arg type='a{sv}' name='platform_data' direction='in'/>
  </method>
  <method name='Command'>
    <arg name='options' direction='in' type='as'/>
    <arg name='result' direction='out' type='s'/>
  </method>
  <method name='Open'>
    <arg type='as' name='uris' direction='in'/>
  </method>
  <method name='ShowPoi'>
    <arg name='title' direction='in' type='s'/>
    <arg name='latitude' direction='in' type='d'/>
    <arg name='longitude' direction='in' type='d'/>
    <arg name='result' direction='out' type='s'/>
  </method>
</interface>
"
        function rcActivate(platform_data) {
            app.activate();
            console.log( "DBUS METHOD CALLED: Open" )
            console.log( JSON.stringify(platform_data) )
            console.log()
        }

        function rcActivateAction(action_name, parameter, platform_data ) {
            app.activate();
            console.log("DBUS METHOD CALLED: ActivateAction")
            console.log( JSON.stringify(action_name) )
            console.log( JSON.stringify(parameter) )
            console.log( JSON.stringify(platform_data) )
            console.log()
        }

        function rcCommand(options) {
            var escaped = options.map(function(s) {
                return s.replace(".COMMA.", ",")
            })
            commander.parser(escaped);
            app.activate();
            return "OK";
        }

        function rcOpen( uris, platform_data ) {
            app.activate();
            console.log( "DBUS METHOD CALLED: Open" )
            console.log( JSON.stringify(uris) )
            console.log( JSON.stringify(platform_data) )
            console.log()
            parser( uris )
        }

        function rcShowPoi(title, latitude, longitude) {
            if (isFinite(latitude) && isFinite(longitude)) {
                commander.showPoi(QtPositioning.coordinate(latitude, longitude), title);
                app.activate();
                return "OK";
            }
            return "Error: Coordinates are not numbers";
        }
    }

    function parseCommandLine() {
        if( Qt.application.arguments.length > 2 ) {
            // Pure Maps options are listed after -- option.
            //
            var idx = Qt.application.arguments.indexOf('--');
            if (idx > 0)
                parser(Qt.application.arguments.slice(idx+1,
                                                      Qt.application.arguments.length));
        }
    }

    function parseGeo(str) {
        var coors = str.split(';', 1)[0] || "";
        var geoUriExpr = /geo:(-?[\d.]+),(-?[\d.]+)*/;
        var match = geoUriExpr.exec(coors);
        if (match != null && match.length >= 3) {
            var latitude = parseFloat(match[1]);
            var longitude = parseFloat(match[2]);
            if (isFinite(latitude) && isFinite(longitude))
                return QtPositioning.coordinate(latitude, longitude);
        }
        return null;
    }

    function parser(options) {
        for (var i=0; i < options.length; i++) {
            console.log("Command line option: " + options[i]);

            var parsed = false;

            // check if its geo coordinate
            var geocoordinate = parseGeo(options[i]);
            if (geocoordinate) showPoi(geocoordinate);
        }
    }

    function showPoi(geocoordinate, title) {
        var radius = 50; // meters default radius
        var p = pois.add({ "x": geocoordinate.longitude, "y": geocoordinate.latitude, "title": title });
        if (!p) return;
        pois.show(p);
        py.call("poor.app.geocoder.reverse",
                [geocoordinate.longitude, geocoordinate.latitude, radius, 1],
                function(result) {
                    if (!result || !result.length) return;
                    var r = result[0];
                    var rpoi = pois.convertFromPython(r);
                    rpoi.poiId = p.poiId;
                    rpoi.coordinate = QtPositioning.coordinate(rpoi.y, rpoi.x);
                    if (title) rpoi.title = title;
                    pois.update(rpoi);
                });
        map.autoCenter = false;
        map.setCenter(geocoordinate.longitude, geocoordinate.latitude);
    }
}
