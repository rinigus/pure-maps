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
import Sailfish.Silica 1.0
import "."

Page {
    id: page
    allowedOrientations: Orientation.All
    property bool loading: true
    property string title: ""
    SilicaListView {
        anchors.fill: parent
        delegate: ListItem {
            id: listItem
            contentHeight: titleLabel.height + descriptionLabel.height +
                distanceLabel.height
            ListItemLabel {
                id: titleLabel
                color: listItem.highlighted ?
                    Theme.highlightColor : Theme.primaryColor;
                height: implicitHeight + Theme.paddingMedium
                text: model.title
                verticalAlignment: Text.AlignBottom
            }
            ListItemLabel {
                id: descriptionLabel
                anchors.top: titleLabel.bottom
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                height: implicitHeight
                text: model.description
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.WordWrap
            }
            ListItemLabel {
                id: distanceLabel
                anchors.top: descriptionLabel.bottom
                color: Theme.secondaryColor
                font.pixelSize: Theme.fontSizeExtraSmall
                height: implicitHeight + Theme.paddingMedium
                text: model.distance
                verticalAlignment: Text.AlignTop
            }
            onClicked: {
                map.addPois([{"x": model.x, "y": model.y}]);
                map.setCenter(model.x, model.y);
                app.pageStack.pop(mapPage, PageStackAction.Immediate);
            }
        }
        header: PageHeader { title: page.title }
        model: ListModel { id: listModel }
        PullDownMenu {
            visible: listModel.count > 1
            MenuItem {
                text: "Show all"
                onClicked: {
                    var pois = [];
                    for (var i = 0; i < listModel.count; i++) {
                        var item = listModel.get(i);
                        pois.push({"x": item.x, "y": item.y});
                    }
                    map.addPois(pois);
                    map.fitViewToPois();
                    app.pageStack.pop(mapPage, PageStackAction.Immediate);
                }
            }
        }
        VerticalScrollDecorator {}
    }
    Label {
        id: busyLabel
        anchors.bottom: busyIndicator.top
        color: Theme.highlightColor
        font.pixelSize: Theme.fontSizeLarge
        height: Theme.itemSizeLarge
        horizontalAlignment: Text.AlignHCenter
        text: "Searching"
        verticalAlignment: Text.AlignVCenter
        visible: page.loading || text != "Searching"
        width: parent.width
    }
    BusyIndicator {
        id: busyIndicator
        anchors.centerIn: parent
        running: page.loading
        size: BusyIndicatorSize.Large
        visible: page.loading
    }
    onStatusChanged: {
        if (page.status == PageStatus.Activating) {
            page.loading = true;
            busyLabel.text = "Searching"
        } else if (page.status == PageStatus.Active) {
            var geocodePage = app.pageStack.previousPage();
            page.populate(geocodePage.query);
        } else if (page.status == PageStatus.Inactive) {
            listModel.clear();
            page.title = ""
        }
    }
    function populate(query) {
        // Load geocoding results from the Python backend.
        py.call_sync("poor.app.history.add_place", [query]);
        listModel.clear();
        var bbox = map.getBoundingBox();
        var x = map.position.coordinate.longitude || 0;
        var y = map.position.coordinate.latitude || 0;
        py.call("poor.app.geocoder.geocode", [query, x, y], function(results) {
            if (results.length > 0) {
                page.title = results.length == 1 ?
                    "1 Result" : results.length + " Results";
                for (var i = 0; i < results.length; i++)
                    listModel.append(results[i]);
            } else {
                page.title = "";
                busyLabel.text = "Not found, or error"
            }
            page.loading = false;
        });
    }
}
