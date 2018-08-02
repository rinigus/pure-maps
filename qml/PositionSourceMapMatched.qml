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
import QtPositioning 5.3
import Nemo.DBus 2.0

Item {
    id: master

    // Properties
    property alias active: gps.active
    property real  direction: 0
    property bool  directionValid: false
    property alias mapMatchingAvailable: scoutbus.available
    property alias mapMatchingMode: scoutbus.mode
    property alias name: gps.name
    property var   position: gps.position
    property alias preferredPositioningMethods: gps.preferredPositioningMethods
    property alias sourceError: gps.sourceError
    property string streetName: ""
    property real  streetSpeedAssumed: -1  // in m/s
    property real  streetSpeedLimit: -1    // in m/s
    property alias supportedPositioningMethods: gps.supportedPositioningMethods
    property alias updateInterval: gps.updateInterval
    property alias valid: gps.valid

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

    // signal is not provided by Sailfish version of PositionSource
    // signal updateTimeout()

    // Methods
    function start() {
        gps.start()
    }

    function stop() {
        gps.stop()
    }

    function update() {
        gps.update()
    }

    //////////////////////////////////////////////////////////////
    /// Implementation
    //////////////////////////////////////////////////////////////

    // provider for actual position
    PositionSource {
        id: gps

        function positionUpdate(position) {
            if (scoutbus.available &&
                    scoutbus.mode &&
                    position.latitudeValid && position.longitudeValid &&
                    position.horizontalAccuracyValid) {
                if (master.timingStatsEnable && !master._timingShot) {
                    master._timingOverallCounter += 1;
                    master._timingShot = true;
                    master._timingLastCallStart = Date.now();
                }
                scoutbus.mapMatch(position);
            } else {
                master.position = position;
                if (scoutbus.mode && scoutbus.running)
                    scoutbus.stop();
            }
        }

        onPositionChanged: positionUpdate(position)

        onActiveChanged: {
            if (!gps.active) scoutbus.stop();
        }

        //onUpdateTimeout: master.updateTimeout()
    }

    // interaction with OSM Scout Server via D-Bus
    DBusInterface {
        id: scoutbus
        service: "org.osm.scout.server1"
        path: "/org/osm/scout/server1/mapmatching1"
        iface: "org.osm.scout.server1.mapmatching1"

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

        function mapMatch(position) {
            if (!mode || !available) return;

            typedCall("Update",
                      [ {'type': 'i', 'value': mode},
                       {'type': 'd', 'value': position.coordinate.latitude},
                       {'type': 'd', 'value': position.coordinate.longitude},
                       {'type': 'd', 'value': position.horizontalAccuracy} ],
                      function(result) {
                          // successful call
                          var r = JSON.parse(result);
                          var position = {}
                          for (var i in gps.position) {
                              if (!(gps.position[i] instanceof Function) && i!=="coordinate")
                                  position[i] = gps.position[i]
                          }

                          var latitude = master.position.coordinate.latitude
                          var longitude = master.position.coordinate.longitude
                          if (r.latitude !== undefined) latitude = r.latitude;
                          if (r.longitude !== undefined) longitude = r.longitude;
                          position.coordinate = QtPositioning.coordinate(latitude, longitude);

                          if (r.direction!==undefined) master.direction = r.direction;
                          if (r.direction_valid!==undefined) master.directionValid = r.direction_valid;
                          if (r.street_name!==undefined) master.streetName = r.street_name;
                          if (r.street_speed_assumed!==undefined) master.streetSpeedAssumed = r.street_speed_assumed;
                          if (r.street_speed_limit!==undefined) master.streetSpeedLimit = r.street_speed_limit;

                          // always update position
                          master.position = position;

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
                          master.position = gps.position;
                      }
                      );

            running = true;
        }

        function resetValues() {
            master.directionValid = false;
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
        running: scoutbus.mode > 0 && !scoutbus.available
        onTriggered: {
            console.log('Activating OSM Scout Server');

            var xmlhttp = new XMLHttpRequest();
            xmlhttp.open("GET",
                         "http://localhost:8553/v1/activate",
                         true);
            xmlhttp.send();
        }
    }

    // support for testing
    Timer {
        id: testingTimer
        interval: gps.updateInterval
        running: false
        repeat: true
        onTriggered: {
            var p= {};
            p.coordinate = master.testingCoordinate;
            p.horizontalAccuracy = 10;
            p.latitudeValid = true;
            p.longitudeValid = true;
            p.horizontalAccuracyValid = true;
            gps.positionUpdate(p);
        }
    }

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

    onTestingCoordinateChanged: {
        if (testingCoordinate==null) {
            testingTimer.running = false;
        } else {
            testingTimer.running = true;
        }
    }
}
