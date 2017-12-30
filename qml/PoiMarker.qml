/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2014 Osmo Salomaa
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
import Sailfish.Silica 1.0
import "."

Item {
    id: marker

    z: 400

    property var coordinate
    property string trackerId: ""
    property string link: ""
    property string text: ""
    property string title: ""

    Item {
        id: dot
        width: 1
        height: 1
    }

    Bubble {
        id: bubble

        anchorItem: dot
        controlHeight: routeButton.height
        controlWidth: routeButton.width + nearbyButton.width + shareButton.width +
                      (marker.link.length > 0 ? webButton.width : 0) +
                      (marker.link.length > 0 ? 3 : 2) * Theme.paddingMedium

        text: marker.text

        BubbleButton {
            id: routeButton
            anchors.bottom: parent.bottom
            anchors.bottomMargin: bubble.padding
            anchors.left: parent.left
            anchors.leftMargin: bubble.padding
            text: app.tr("Navigate")
            onClicked: {
                var x = marker.coordinate.longitude;
                var y = marker.coordinate.latitude;
                app.showMenu("RoutePage.qml", {
                                 "to": [x, y],
                                 "toText": marker.title
                             });
            }
        }

        BubbleButton {
            id: nearbyButton
            anchors.bottom: parent.bottom
            anchors.bottomMargin: bubble.padding
            anchors.left: routeButton.right
            anchors.leftMargin: Theme.paddingMedium
            text: app.tr("Nearby")
            onClicked: {
                var x = marker.coordinate.longitude;
                var y = marker.coordinate.latitude;
                app.showMenu("NearbyPage.qml", {
                                 "near": [x, y],
                                 "nearText": marker.title
                             });
            }
        }

        BubbleButton {
            id: shareButton
            anchors.bottom: parent.bottom
            anchors.bottomMargin: bubble.padding
            anchors.left: nearbyButton.right
            anchors.leftMargin: Theme.paddingMedium
            text: app.tr("Share")
            onClicked: {
                var x = marker.coordinate.longitude;
                var y = marker.coordinate.latitude;
                app.showMenu("SharePage.qml", {
                                 "coordinate": QtPositioning.coordinate(y, x),
                                 "title": app.tr("Share Location")
                             });
            }
        }

        BubbleButton {
            id: webButton
            anchors.bottom: parent.bottom
            anchors.bottomMargin: bubble.padding
            anchors.right: parent.right
            anchors.rightMargin: bubble.padding
            text: app.tr("Web")
            useHighlight: true
            visible: marker.link.length > 0
            onClicked: Qt.openUrlExternally(marker.link);
        }
    }

    function process_text() {
        marker.text = marker.text.replace("Theme.highlightColor", Theme.highlightColor);
    }

    onTextChanged: process_text()
    Component.onCompleted: process_text()

    Connections {
        target: map

        onLocationChanged: {
            if (id !== trackerId) return;

            dot.x = pixel.x; // + marker.width/2;
            dot.y = pixel.y; // + marker.height;
            marker.visible = visible;
        }

//        onLocationTrackingRemoved: {
//            if (id !== trackerId) return;
//            // marker.destroy(); // destruction done in the map
//        }
    }
}
