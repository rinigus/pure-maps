/* -*- coding: utf-8-unix -*-
 *
 * Copyright 2018 Rinigus <rinigus.git@gmail.com>
 * 
 * MIT License
 * 
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 * 
 */


import QtQuick 2.0
import QtPositioning 5.4
import Nemo.DBus 2.0
import org.puremaps 1.0 as PM

Item {
    id: master

    // Properties
    property alias active: gps.active
    property alias ready: gps.ready
    property alias accurate: gps.accurate

    property var   coordinate
    property bool  coordinateValid: false
    property var   direction: directionMapMatchValid ? directionMapMatch : directionDevice
    property alias directionDevice: gps.direction
    property alias directionDeviceValid: gps.directionValid
    property real  directionMapMatch: 0
    property bool  directionMapMatchValid: false
    property bool  directionValid: directionMapMatchValid || directionDeviceValid
    property alias mapMatchingAvailable: scoutbus.available
    property alias mapMatchingMode: scoutbus.mode
    property string streetName: ""
    property real  streetSpeedAssumed: -1  // in m/s
    property real  streetSpeedLimit: -1    // in m/s
    property real  timePerUpdate: 1000 // NOT REAL NUMBER, TODO

    // Timing statistics support
    property bool  timingStatsEnable: false
    property real  timingOverallAvr: 0
    property real  timingOverallMax: 0
    property real  timingOverallMin: -1

    // Timing statistics support - internal vars
    property int   _timingOverallCounter: 0
    property real  _timingOverallSum: 0.0
    property bool  _timingShot: false
    property var   _timingLastCallStart: undefined

    // Properties used for testing
    property var   testingCoordinate: undefined

    // Signals
    signal positionUpdated()

    // signal is not provided by Sailfish version of PositionSource
    // signal updateTimeout()

    //////////////////////////////////////////////////////////////
    /// Implementation
    //////////////////////////////////////////////////////////////

    // provider for actual position
    PM.PositionSource {
        id: gps

//        property var lastPositionDirectionValid: null

        Component.onCompleted: positionUpdate(position)

//        onPositionUpdated: if (testingCoordinate==null) positionUpdate(position)

        onActiveChanged: {
            if (!gps.active) scoutbus.stop();
        }

        onPositionUpdated: {
            // Filter coordinates first to ensure that they
            // are numeric values
//            var pos = {}
//            for (var i in positionRaw) {
//                if (!(positionRaw[i] instanceof Function))
//                    pos[i] = positionRaw[i]
//            }

//            if (pos.coordinate.latitude == null ||
//                    isNaN(pos.coordinate.latitude) ||
//                    pos.coordinate.longitude == null ||
//                    isNaN(pos.coordinate.longitude))
//                pos.coordinate = QtPositioning.coordinate(0, 0);

//            if (pos.directionValid) {
//                master.directionDevice = pos.direction;
//                if (!master.directionDeviceValid)
//                    master.directionDeviceValid = true;
//                lastPositionDirectionValid = pos.coordinate;
//            } else if (lastPositionDirectionValid == null ||
//                       // stick to old direction when we stop moving
//                       pos.coordinate.distanceTo(lastPositionDirectionValid) > 10 /* meters */ )
//            {
//                master.directionDeviceValid = false;
//                master.directionDevice = 0;
//            }

            if (scoutbus.available &&
                    scoutbus.mode &&
                    coordinateValid &&
                    horizontalAccuracyValid) {
                if (master.timingStatsEnable && !master._timingShot) {
                    master._timingOverallCounter += 1;
                    master._timingShot = true;
                    master._timingLastCallStart = Date.now();
                }
                scoutbus.mapMatch(coordinate, horizontalAccuracy);
            } else {
                master.coordinate = coordinate;
                master.coordinateValid = coordinateValid;
                if (scoutbus.mode && scoutbus.running)
                    scoutbus.stop();
            }

            master.positionUpdated();
        }
    }

    // interaction with OSM Scout Server via D-Bus
    DBusInterface {
        id: scoutbus
        service: "io.github.rinigus.OSMScoutServer"
        path: "/io/github/rinigus/OSMScoutServer/mapmatching"
        iface: "io.github.rinigus.OSMScoutServer.mapmatching"

        property bool available: false
        property int  mode: 0
        property bool running: false;

        Component.onCompleted: {
            checkAvailable();
        }

        function checkAvailable() {
            if (getProperty("Active")) {
                if (!available) {
                    available = true;
                    if (mode) call('Reset', mode);
                    resetValues();
                }
            } else {
                available = false
                resetValues();
            }
        }

        function mapMatch(coordinate, horizontalAccuracy) {
            if (!mode || !available) return;

            typedCall("Update",
                      [ {'type': 'i', 'value': mode},
                       {'type': 'd', 'value': coordinate.latitude},
                       {'type': 'd', 'value': coordinate.longitude},
                       {'type': 'd', 'value': horizontalAccuracy} ],
                      function(result) {
                          // successful call
                          var r = JSON.parse(result);
                          var coor;

                          var latitude = coordinate.latitude
                          var longitude = coordinate.longitude
                          if (r.latitude !== undefined) latitude = r.latitude;
                          if (r.longitude !== undefined) longitude = r.longitude;
                          coor = QtPositioning.coordinate(latitude, longitude);

                          if (r.direction!==undefined) master.directionMapMatch = r.direction;
                          if (r.direction_valid!==undefined) master.directionMapMatchValid = r.direction_valid;
                          if (r.street_name!==undefined) master.streetName = r.street_name;
                          if (r.street_speed_assumed!==undefined) master.streetSpeedAssumed = r.street_speed_assumed;
                          if (r.street_speed_limit!==undefined) master.streetSpeedLimit = r.street_speed_limit;

                          // always update position
                          master.coordinate = coor;
                          master.coordinateValid = true;

                          if (master._timingShot) {
                              var dt = 1e-3*(Date.now() - master._timingLastCallStart);
                              master._timingShot = false;
                              master._timingOverallSum += dt;
                              if (master.timingOverallMax < dt) master.timingOverallMax = dt;
                              if (master.timingOverallMin<0 || master.timingOverallMin > dt) master.timingOverallMin = dt;
                              master.timingOverallAvr = master._timingOverallSum/master._timingOverallCounter;
                          }
                      },
                      function(result) {
                          // error
                          scoutbus.resetValues();
                          master.coordinate = gps.coordinate;
                          master.coordinateValid = gps.coordinateValid;
                      }
                      );

            running = true;
        }

        function resetValues() {
            master.streetName = ""
            master.streetSpeedAssumed = -1;
            master.streetSpeedLimit = -1;
        }

        function stop() {
            if (mode) {
                call('Stop', mode);
                if (gps.active) resetValues();
            }
            running = false;
        }

        onModeChanged: {
            if (!available) return;
            if (mode) call('Reset', mode);
            resetValues();
        }
    }

    // monitor availibility of OSM Scout Server on D-Bus
    DBusInterface {
        // monitors availibility of the dbus service
        service: "org.freedesktop.DBus"
        path: "/org/freedesktop/DBus"
        iface: "org.freedesktop.DBus"
        signalsEnabled: true

        function nameOwnerChanged(name, old_owner, new_owner) {
            if (name === scoutbus.service)
                scoutbus.checkAvailable()
        }
    }

    // start OSM Scout Server via systemd socket activation
    // if the server is not available, but needed
    Timer {
        id: activationTimer
        interval: 5000
        repeat: true
        running: scoutbus.mode > 0 && !scoutbus.available && app.hasMapMatching
        onTriggered: {
            console.log('Activating OSM Scout Server');

            var xmlhttp = new XMLHttpRequest();
            xmlhttp.open("GET",
                         "http://localhost:8553/v1/activate",
                         true);
            xmlhttp.send();
        }
    }

    // TODO: TESTING

//    // support for testing
//    Timer {
//        id: testingTimer
//        interval: Math.max(gps.updateInterval, 1000)
//        running: testingCoordinate!=null
//        repeat: true
//        onTriggered: {
//            var p= {};
//            p.coordinate = master.testingCoordinate;
//            p.horizontalAccuracy = 10;
//            p.latitudeValid = true;
//            p.longitudeValid = true;
//            p.horizontalAccuracyValid = true;
//            p.directionValid = false;
//            gps.positionUpdate(p);
//        }
//    }

    // reset direction estimated by map matching until the next position update
    onMapMatchingModeChanged: directionMapMatchValid = false

    onTimingStatsEnableChanged: {
        // reset if timing stats started
        if (timingStatsEnable) {
            timingOverallAvr = 0;
            timingOverallMax = 0;
            timingOverallMin = -1;

            _timingOverallCounter = 0;
            _timingOverallSum = 0.0;
            _timingShot = false;
        }
    }
}
