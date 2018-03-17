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
    // As the icon we are attaching to is in Mapbox GL instead of QML,
    // we need an invisible tappable size QML anchor that is attached
    // to the location of the corresponding actual POI icon.
    id: anchor
    height: Theme.iconSizeMedium
    width: Theme.iconSizeMedium
    z: 600

    property var    coordinate: null
    property string link: ""
    property string text: ""
    property string title: ""
    property string trackerId: ""

    Bubble {
        id: bubble
        anchorItem: anchor
        controlHeight: routeButton.height
        controlWidth: routeButton.width + nearbyButton.width + shareButton.width +
            (anchor.link.length > 0 ? webButton.width : 0) +
            (anchor.link.length > 0 ? 3 : 2) * Theme.paddingMedium
        text: anchor.text.replace(/Theme.highlightColor/g, Theme.highlightColor)
        onClicked: {
            for (var i = 0; i < map.pois.length; i++)
                if (map.pois[i].bubble &&
                    map.pois[i].bubble.trackerId === anchor.trackerId)
                    map.hidePoiBubble(map.pois[i]);
        }

        BubbleButton {
            id: routeButton
            anchors.bottom: parent.bottom
            anchors.bottomMargin: bubble.padding
            anchors.left: parent.left
            anchors.leftMargin: bubble.padding
            text: app.tr("Navigate")
            onClicked: {
                var x = anchor.coordinate.longitude;
                var y = anchor.coordinate.latitude;
                app.showMenu("RoutePage.qml", {
                    "to": [x, y],
                    "toText": anchor.title,
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
                var x = anchor.coordinate.longitude;
                var y = anchor.coordinate.latitude;
                app.showMenu("NearbyPage.qml", {
                    "near": [x, y],
                    "nearText": anchor.title,
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
                var x = anchor.coordinate.longitude;
                var y = anchor.coordinate.latitude;
                app.showMenu("SharePage.qml", {
                    "coordinate": QtPositioning.coordinate(y, x),
                    "title": app.tr("Share Location"),
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
            visible: anchor.link.length > 0
            onClicked: Qt.openUrlExternally(anchor.link);
        }

    }

    Connections {
        target: map
        onLocationChanged: {
            if (id !== anchor.trackerId) return;
            anchor.x = pixel.x - anchor.width  / 2;
            anchor.y = pixel.y - anchor.height / 2;
            anchor.visible = visible;
        }
    }

}
