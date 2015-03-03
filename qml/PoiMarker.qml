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

MapQuickItem {
    id: item
    anchorPoint.x: container.width/2
    anchorPoint.y: container.height/2
    sourceItem: Item {
        id: container
        height: image.height
        width: image.width
        Image {
            id: image
            source: "icons/poi.png"
            MouseArea {
                anchors.fill: parent
                onClicked: item.labelVisible = !item.labelVisible
            }
        }
        Rectangle {
            id: bubble
            anchors.bottom: image.top
            anchors.bottomMargin: 18
            anchors.horizontalCenter: image.horizontalCenter
            color: "#bb000000"
            height: content.height + 1.5*Theme.paddingLarge
            radius: textLabel.font.pixelSize/2
            visible: item.labelVisible
            width: content.width + 1.5*Theme.paddingLarge
            Item {
                id: content
                anchors.centerIn: parent
                height: textLabel.height + routeButton.height
                width: Math.max(textLabel.width,
                                routeButton.width +
                                linkButton.width +
                                shareButton.width +
                                3*Theme.paddingMedium)

                Label {
                    id: textLabel
                    color: "white"
                    font.pixelSize: Theme.fontSizeSmall
                    height: implicitHeight + 1.5*Theme.paddingMedium
                    text: item.text
                    textFormat: Text.RichText
                    verticalAlignment: Text.AlignTop
                    width: Math.min(0.6*map.width, implicitWidth)
                    wrapMode: Text.WordWrap
                }
                MouseArea {
                    // Hide bubble by tapping label area.
                    anchors.bottom: textLabel.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: textLabel.top
                    onClicked: item.labelVisible = !item.labelVisible
                }
                Rectangle {
                    id: routeButton
                    anchors.left: parent.left
                    anchors.top: textLabel.bottom
                    color: "#bbffffff"
                    height: routeLabel.height + Theme.paddingMedium
                    radius: bubble.radius/2
                    width: routeLabel.width + 1.5*Theme.paddingMedium
                    Label {
                        id: routeLabel
                        anchors.centerIn: parent
                        color: "black"
                        font.pixelSize: Theme.fontSizeExtraSmall
                        text: "Route"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            var x = item.coordinate.longitude;
                            var y = item.coordinate.latitude;
                            app.showMenu("RoutePage.qml", {
                                "to": [x, y],
                                "toText": item.title
                            });
                        }
                    }
                }
                Rectangle {
                    id: linkButton
                    anchors.right: shareButton.left
                    anchors.rightMargin: 1.5*Theme.paddingMedium
                    anchors.top: textLabel.bottom
                    color: "#bbffffff"
                    height: linkLabel.height + Theme.paddingMedium
                    radius: bubble.radius/2
                    visible: item.link && item.link.length > 0
                    width: visible ? linkLabel.width + 1.5*Theme.paddingMedium : 0
                    Label {
                        id: linkLabel
                        anchors.centerIn: parent
                        color: "black"
                        font.pixelSize: Theme.fontSizeExtraSmall
                        text: "Web"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            linkButton.color = Theme.highlightColor;
                            linkTimer.restart();
                            Qt.openUrlExternally(item.link);
                        }
                    }
                    Timer {
                        id: linkTimer
                        interval: 3000
                        repeat: false
                        onTriggered: linkButton.color = "#bbffffff";
                    }
                }
                Rectangle {
                    id: shareButton
                    anchors.right: parent.right
                    anchors.top: textLabel.bottom
                    color: "#bbffffff"
                    height: shareLabel.height + Theme.paddingMedium
                    radius: bubble.radius/2
                    width: shareLabel.width + 1.5*Theme.paddingMedium
                    Label {
                        id: shareLabel
                        anchors.centerIn: parent
                        color: "black"
                        font.pixelSize: Theme.fontSizeExtraSmall
                        text: "Share"
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            app.showMenu("SharePage.qml", {
                                "coordinate": QtPositioning.coordinate(
                                    item.coordinate.latitude,
                                    item.coordinate.longitude),
                                "title": "Share Location"
                            });
                        }
                    }
                }
            }
        }
        Image {
            id: arrow
            anchors.top: bubble.bottom
            // Try to avoid a stripe between bubble and arrow.
            anchors.topMargin: -0.5
            anchors.horizontalCenter: bubble.horizontalCenter
            source: "icons/bubble-arrow.png"
            visible: item.labelVisible
        }
    }
    z: 400
    property bool labelVisible: false
    property string link: ""
    property string text: ""
    property string title: ""
    onLabelVisibleChanged: {
        // Ensure that bubble will be above other POIs.
        for (var i = 0; i < map.pois.length; i++)
            map.pois[i].z = map.pois[i].labelVisible ? 402 : 400;
        item.z = item.labelVisible ? 403 : 401;
    }
    onTextChanged: {
        item.text = item.text.replace("Theme.highlightColor", Theme.highlightColor);
    }
}
