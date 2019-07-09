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

PagePL {
    id: page
    title: app.tr("Navigation")

    acceptIconName: styler.iconNavigate
    acceptText: app.tr("Route")
    canNavigateForward:
        (!page.fromNeeded || (page.from && (page.fromText !== app.tr("Current position") || gps.ready))) &&
        (!page.toNeeded   || (page.to   && (page.toText   !== app.tr("Current position") || gps.ready)))

    pageMenu: PageMenuPL {
        PageMenuItemPL {
            text: app.tr("Using %1").arg(name)
            property string name: page.routerName
            onClicked: {
                var dialog = app.push(Qt.resolvedUrl("RouterPage.qml"));
                dialog.accepted.connect(function() {
                    page.updateRouter();
                    columnRouter.settings && columnRouter.settings.destroy();
                    columnRouter.settings = null;
                    columnRouter.addSettings();
                });
            }
        }

        PageMenuItemPL {
            text: followMe ? app.tr("Navigate") : app.tr("Follow me")
            onClicked: {
                followMe = !followMe;
                page.params = {};
                columnRouter.settings && columnRouter.settings.destroy();
                columnRouter.settings = null;
                columnRouter.addSettings();
            }
        }

        PageMenuItemPL {
            text: app.tr("Reverse endpoints")
            onClicked: {
                var from = page.from;
                var fromQuery = page.fromQuery;
                var fromText = page.fromText;
                page.from = page.to;
                page.fromQuery = page.toQuery;
                page.fromText = page.toText;
                page.to = from;
                page.toQuery = fromQuery;
                page.toText = fromText;
            }
        }
    }

    property bool   autoRoute: false
    property bool   autoRouteSupported: false
    property var    columnRouter
    property bool   followMe: false
    property alias  from: fromButton.coordinates
    property bool   fromNeeded: true
    property alias  fromQuery: fromButton.query
    property alias  fromText: fromButton.text
    property var    params: {}
    property string routerName
    property alias  to: toButton.coordinates
    property bool   toNeeded: true
    property alias  toQuery: toButton.query
    property alias  toText: toButton.text

    property int    _autoRouteFlag: 0
    property var    _destinationsNotForSave: []

    signal notify(string notification)

    Column {
        id: column
        spacing: styler.themePaddingLarge
        width: parent.width

        Column {
            id: columnRouter
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: styler.themePaddingMedium
            visible: !followMe

            property var  settings: null

            ListItemLabel {
                id: note
                color: styler.themeHighlightColor
                horizontalAlignment: Text.AlignHCenter
                visible: text

                Timer {
                    id: nt
                    interval: 3000; repeat: false; running: false;
                    onTriggered: note.text = ""
                }

                Connections {
                    target: page
                    onNotify: {
                        note.text = notification;
                        nt.start();
                    }
                }
            }

            RoutePoint {
                id: fromButton
                label: app.tr("From")
                title: app.tr("Origin")
                visible: page.fromNeeded
            }

            RoutePoint {
                id: toButton
                label: app.tr("To")
                title: app.tr("Destination")
                visible: page.toNeeded
            }

            Component.onCompleted: {
                columnRouter.addSettings();
                page.columnRouter = columnRouter;
            }

            function addSettings() {
                if (columnRouter.settings || followMe) return;
                // Add router-specific settings from router's own QML file.
                page.params = {};
                columnRouter.settings && columnRouter.settings.destroy();
                var uri = Qt.resolvedUrl(py.evaluate("poor.app.router.settings_qml_uri"));
                if (!uri) return;
                var component = Qt.createComponent(uri);
                if (component.status === Component.Error) {
                    console.log('Error while creating component');
                    console.log(component.errorString());
                    return null;
                }
                columnRouter.settings = component.createObject(columnRouter);
                if (!columnRouter.settings) return;
                columnRouter.settings.anchors.left = columnRouter.left;
                columnRouter.settings.anchors.right = columnRouter.right;
                columnRouter.settings.width = columnRouter.width;
                columnRouter.settings.full = Qt.binding(function() {
                    return !followMe && (page.from!=null || !page.fromNeeded) &&
                            (page.to!=null || !page.toNeeded);
                });
            }
        }

        Column {
            /////////////////////////
            // Recent routes
            id: columnRoutes
            anchors.left: parent.left
            anchors.right: parent.right
            visible: !followMe && !page.to && page.toNeeded && routes.model.count > 0

            SectionHeaderPL {
                text: app.tr("Routes")
            }

            Spacer {
                height: styler.themePaddingMedium
            }

            Repeater {
                id: routes

                delegate: ListItemPL {
                    contentHeight: styler.themeItemSizeSmall
                    menu: ContextMenuPL {
                        id: contextMenu
                        ContextMenuItemPL {
                            iconName: styler.iconDelete
                            text: app.tr("Remove")
                            onClicked: {
                                py.call_sync("poor.app.history.remove_route", [model.fromText, model.toText]);
                                columnRoutes.fillRoutes();
                            }
                        }
                    }

                    ListItemLabel {
                        id: label
                        anchors.verticalCenter: parent.verticalCenter
                        color: styler.themePrimaryColor
                        text: "%1 ‒ %2".arg(model.fromText).arg(model.toText)
                    }

                    onClicked: {
                        page.fromText = model.fromText;
                        if (page.fromText === app.tr("Current position"))
                            page.from = map.getPosition();
                        else page.from = [model.fromX, model.fromY];

                        page.toText = model.toText;
                        if (page.toText === app.tr("Current position"))
                            page.to = map.getPosition();
                        else page.to = [model.toX, model.toY];
                    }
                }

                model: ListModel {}
            }

            Component.onCompleted: columnRoutes.fillRoutes()

            function fillRoutes() {
                // recent destinations
                routes.model.clear();
                var rs = py.evaluate("poor.app.history.routes").slice(0, 2);
                rs.forEach(function (p) {
                    routes.model.append({
                                            "fromText": p.from.text,
                                            "fromX": p.from.x,
                                            "fromY": p.from.y,
                                            "toText": p.to.text,
                                            "toX": p.to.x,
                                            "toY": p.to.y,
                                            "visible": true
                                        });
                });
            }
        }

        Column {
            /////////////////////////
            // Suggested destinations
            id: columnSuggested
            anchors.left: parent.left
            anchors.right: parent.right
            visible: !followMe && !page.to && page.toNeeded

            SectionHeaderPL {
                text: app.tr("Destinations")
            }

            Spacer {
                height: styler.themePaddingMedium
            }

            Repeater {
                id: destinations

                delegate: ListItemPL {
                    contentHeight: model.visible ? styler.themeItemSizeSmall : 0
                    menu: ContextMenuPL {
                        id: contextMenu
                        enabled: model.type === "recent destination"
                        ContextMenuItemPL {
                            enabled: model.type === "recent destination"
                            iconName: enabled ? styler.iconDelete : ""
                            text: enabled ? app.tr("Remove") : ""
                            onClicked: {
                                if (model.type !== "recent destination") return;
                                py.call_sync("poor.app.history.remove_destination", [model.text]);
                                model.visible = false;
                            }
                        }
                    }
                    visible: model.visible

                    ListItemLabel {
                        id: label
                        anchors.verticalCenter: parent.verticalCenter
                        color: styler.themePrimaryColor
                        text: model.text
                    }

                    onClicked: {
                        page.to = [model.x, model.y];
                        page.toText = model.toText;
                    }
                }

                model: ListModel {}
            }

            Component.onCompleted: {
                // pois
                _destinationsNotForSave = [];
                var pois = app.pois.pois.filter(function (p) {
                    return (p.bookmarked && p.shortlisted);
                });
                pois.sort(function (a, b){
                    if (a.title < b.title) return -1;
                    if (a.title > b.title) return 1;
                    return 0;
                })
                pois.forEach(function (p) {
                    var t = {
                        "text": (p.title ? p.title : app.tr("Unnamed point")) +
                                (p.shortlisted ? " ☰" : ""),
                        "toText": p.title ? p.title : app.tr("Unnamed point"),
                        "type": "poi",
                        "visible": true,
                        "x": p.coordinate.longitude,
                        "y": p.coordinate.latitude
                    };
                    destinations.model.append(t);
                    _destinationsNotForSave.push(t);
                });

                // recent destinations
                var dest = py.evaluate("poor.app.history.destinations").slice(0, 10);
                dest.forEach(function (p) {
                    destinations.model.append({
                                                  "text": p.text,
                                                  "toText": p.text,
                                                  "type": "recent destination",
                                                  "visible": true,
                                                  "x": p.x,
                                                  "y": p.y
                                              });
                });
            }
        }

        Column {
            /////////////////
            // Follow Me mode
            id: columnFollow
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: styler.themePaddingMedium
            visible: followMe

            ListItemLabel {
                color: styler.themeHighlightColor
                text: app.tr("Follow the movement and show just in time information")
                truncMode: truncModes.none
                wrapMode: Text.WordWrap
            }

            ToolItemPL {
                id: beginFollowMeItem
                icon.iconHeight: styler.themeIconSizeMedium
                icon.iconName: app.mode === modes.followMe ? styler.iconStop : styler.iconStart
                text: app.mode === modes.followMe ? app.tr("Stop") : app.tr("Begin")
                width: columnFollow.width
                onClicked: {
                    if (app.mode === modes.followMe) {
                        app.setModeExplore();
                        app.showMap();
                    } else {
                        app.setModeFollowMe();
                        app.hideMenu(); // there is no info panel, follow me mode starts and is using hidden menu
                    }
                }
            }

            FormLayoutPL {
                anchors.left: parent.left
                anchors.leftMargin: styler.themeHorizontalPageMargin
                anchors.right: parent.right
                anchors.rightMargin: styler.themeHorizontalPageMargin
                spacing: styler.themePaddingMedium

                ComboBoxPL {
                    id: mapmatchingComboBox
                    description: app.tr("Select mode of transportation. Only applies when Pure Maps is in follow me mode.")
                    label: app.tr("Mode of transportation")
                    model: [ app.tr("Car"), app.tr("Bicycle"), app.tr("Foot") ]
                    property string  value: "car"
                    property var     values: ["car", "bicycle", "foot"]
                    Component.onCompleted: {
                        var v = app.conf.mapMatchingWhenFollowing;
                        mapmatchingComboBox.currentIndex = Math.max(0, mapmatchingComboBox.values.indexOf(v));
                        value = values[mapmatchingComboBox.currentIndex];
                    }
                    onCurrentIndexChanged: {
                        mapmatchingComboBox.value = values[mapmatchingComboBox.currentIndex]
                        app.conf.set("map_matching_when_following", mapmatchingComboBox.value);
                        scaleSlider.value = app.conf.get("map_scale_navigation_" + mapmatchingComboBox.value)
                    }
                }

                SliderPL {
                    id: scaleSlider
                    label: app.tr("Map scale")
                    maximumValue: 4.0
                    minimumValue: 0.5
                    stepSize: 0.1
                    value: app.conf.get("map_scale_navigation_" + mapmatchingComboBox.value)
                    valueText: value
                    width: parent.width
                    onValueChanged: {
                        if (!mapmatchingComboBox.value) return;
                        app.conf.set("map_scale_navigation_" + mapmatchingComboBox.value, scaleSlider.value);
                        if (app.mode === modes.followMe) map.setScale(scaleSlider.value);
                    }
                }
            }

            // Follow Me mode: done
            ///////////////////////

        }

        Timer {
            // timer is used to ensure that all property handlers by
            // page stacks of different platforms are fully processed
            // (such as canNavigateForward, for example) before trying
            // to calculate the route
            id: autoRouteTimer
            interval: 1 // arbitrary small value (in ms)
            running: false
            repeat: false
            onTriggered: app.pages.navigateForward()
        }
    }

    Component.onCompleted: {
        followMe = (app.mode === modes.followMe)
        if (!page.from) {
            page.from = map.getPosition();
            page.fromText = app.tr("Current position");
        }
        updateRouter();
        columnRouter.addSettings();
    }

    on_AutoRouteFlagChanged: routeAutomatically()
    onCanNavigateForwardChanged: routeAutomatically()

    onFollowMeChanged: {
        columnRouter.addSettings();
        routeAutomatically();
    }

    onPageStatusActive: {
        if (page.fromText === app.tr("Current position"))
            page.from = map.getPosition();
        if (page.toText === app.tr("Current position"))
            page.to = map.getPosition();
        var uri = Qt.resolvedUrl(py.evaluate("poor.app.router.results_qml_uri"));
        app.pushAttached(uri);
        // check if this page is made active for adjusting route settings
        if (autoRoute) autoRoute = false;
        if (_autoRouteFlag === 0) _autoRouteFlag = 1;
    }

    function routeAutomatically() {
        if (followMe || !canNavigateForward || !autoRouteSupported) return;
        if (_autoRouteFlag === 1) {
            autoRoute = true;
            _autoRouteFlag = 2;
            autoRouteTimer.start();
        }
    }

    function saveDestination() {
        for (var i=0; i < _destinationsNotForSave.length; i++)
            if (toText === _destinationsNotForSave[i].toText &&
                    Math.abs(to[0]-_destinationsNotForSave[i].x) < 1e-8 &&
                    Math.abs(to[1]-_destinationsNotForSave[i].y) < 1e-8)
                return false;
        return true;
    }

    function updateRouter() {
        page.routerName = py.evaluate("poor.app.router.name");
        page.autoRouteSupported = py.evaluate("poor.app.router.auto_route");
        page.fromNeeded = py.evaluate("poor.app.router.from_needed");
        page.toNeeded = py.evaluate("poor.app.router.to_needed");
    }

}
