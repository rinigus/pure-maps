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
                onClicked: {
                    // Ensure that bubble will be above other POIs.
                    for (var i = 0; i < map.pois.length; i++)
                        map.pois[i].z = 400;
                    item.z = 401;
                    item.labelVisible = !item.labelVisible;
                }
            }
        }
        Rectangle {
            id: rectangle
            anchors.bottom: image.top
            anchors.bottomMargin: 18
            anchors.horizontalCenter: image.horizontalCenter
            color: "#BB000000"
            height: label.height + Theme.paddingLarge
            radius: label.font.pixelSize/2
            visible: item.labelVisible
            width: label.width + 1.5*Theme.paddingLarge
            Label {
                id: label
                anchors.centerIn: parent
                color: "white"
                font.pixelSize: Theme.fontSizeSmall
                height: implicitHeight + 2
                text: item.text
                textFormat: Text.RichText
                verticalAlignment: Text.AlignTop
                width: Math.min(0.6*map.width, implicitWidth)
                wrapMode: Text.WordWrap
            }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    highlightTimer.start();
                    Qt.openUrlExternally(item.link);
                }
            }
            Timer {
                id: highlightTimer
                interval: 3000
                repeat: false
                onRunningChanged: {
                    label.color = highlightTimer.running ?
                        Theme.highlightColor : "white";
                }
            }
        }
        Image {
            id: arrow
            anchors.top: rectangle.bottom
            anchors.horizontalCenter: rectangle.horizontalCenter
            source: "icons/bubble-arrow.png"
            visible: item.labelVisible
        }
    }
    z: 400
    property bool   labelVisible: false
    property string link: ""
    property string text: ""
    onTextChanged: {
        item.text = item.text.replace("Theme.highlightColor",
                                      Theme.highlightColor);

    }
}
