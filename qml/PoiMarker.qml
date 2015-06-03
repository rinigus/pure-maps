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
import QtLocation 5.0
import QtPositioning 5.3
import Sailfish.Silica 1.0
import "."

MapQuickItem {
    id: marker
    anchorPoint.x: sourceItem.width/2
    anchorPoint.y: sourceItem.height/2
    height: sourceItem.height
    width: sourceItem.width
    sourceItem: Item {
        id: container
        height: image.height
        width: image.width
        Image {
            id: image
            source: "icons/poi.png"
            MouseArea {
                anchors.fill: parent
                onClicked: marker.bubbleVisible = !marker.bubbleVisible
            }
        }
        Bubble {
            id: bubble
            anchorItem: image
            buttonBlockHeight: routeButton.height
            buttonBlockWidth: (routeButton.width +
                               nearbyButton.width +
                               shareButton.width +
                               2*Theme.paddingMedium +
                               (marker.link.length > 0) * (webButton.width +
                                                           Theme.paddingMedium))

            message: marker.text
            visible: marker.bubbleVisible
            onClicked: marker.bubbleVisible = !marker.bubbleVisible;
            BubbleButton {
                id: routeButton
                anchors.bottom: parent.content.bottom
                anchors.bottomMargin: parent.paddingX
                anchors.left: parent.content.left
                anchors.leftMargin: parent.paddingX
                text: "Route"
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
                anchors.bottom: parent.content.bottom
                anchors.bottomMargin: parent.paddingX
                anchors.left: routeButton.right
                anchors.leftMargin: Theme.paddingMedium
                text: "Nearby"
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
                anchors.bottom: parent.content.bottom
                anchors.bottomMargin: parent.paddingX
                anchors.left: nearbyButton.right
                anchors.leftMargin: Theme.paddingMedium
                text: "Share"
                onClicked: {
                    app.showMenu("SharePage.qml", {
                        "coordinate": QtPositioning.coordinate(
                            marker.coordinate.latitude,
                            marker.coordinate.longitude),
                        "title": "Share Location"
                    });
                }
            }
            BubbleButton {
                id: webButton
                anchors.bottom: parent.content.bottom
                anchors.bottomMargin: parent.paddingX
                anchors.right: parent.content.right
                anchors.rightMargin: parent.paddingX
                text: "Web"
                useHighlight: true
                z: marker.link ? 1 : -1
                onClicked: Qt.openUrlExternally(marker.link);
            }
        }
    }
    transform: Rotation {
        angle: -map.rotation
        origin.x: sourceItem.width/2
        origin.y: sourceItem.height/2
    }
    z: 400
    property bool   bubbleVisible: false
    property string link: ""
    property string text: ""
    property string title: ""
    onBubbleVisibleChanged: {
        // Ensure that bubble will be above other POIs.
        for (var i = 0; i < map.pois.length; i++)
            map.pois[i].z = map.pois[i].bubbleVisible ? 402 : 400;
        marker.z = marker.bubbleVisible ? 403 : 401;
    }
    onTextChanged: {
        marker.text = marker.text.replace("Theme.highlightColor", Theme.highlightColor);
    }
}
