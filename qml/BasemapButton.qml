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
import QtGraphicalEffects 1.0
import "platform"

import "js/util.js" as Util

MouseArea {
    id: master

    anchors.right: parent.right
    enabled: openMenu
    height: openMenu ? parent.height : button.height
    width: openMenu ? parent.width : button.width
    y: {
        if (openMenu) return 0;
        // navigation or follow me
        if (app.mode === modes.navigate || app.mode === modes.followMe) {
            if (!app.portrait)
                return northArrow.y + northArrow.height;
            return northArrow.y - height;
        }
        // (app.mode === modes.explore || app.mode === modes.exploreRoute)
        return navigationSign.y + navigationSign.height + meters.anchors.topMargin +
                meters.height + styler.themePaddingLarge;

    }
    z: openMenu ? 9999 : 500

    states: [
        State {
            when: hidden
            AnchorChanges {
                target: master
                anchors.right: undefined
                anchors.left: parent.right
            }
        }
    ]
    transitions: Transition {
        AnchorAnimation { duration: app.conf.animationDuration; }
        onRunningChanged: {
            if (running && !_noanim) master.visible = true;
            else if (hidden) master.visible = false;
            else master.visible = true;
            if (!running) _noanim = false;
        }
    }

    property bool hidden: !openMenu && _hide
    property bool openMenu: false

    property bool _hide: (app.modalDialog && !app.modalDialogBasemap) || app.infoPanelOpen || (map.cleanMode && !app.conf.mapModeCleanShowBasemap)
    property bool _noanim: false

    MapButton {
        id: button
        iconHeight: styler.themeIconSizeSmall
        iconSource: app.getIcon("icons/map-layers")
        visible: !openMenu
        onClicked: {
            master.fillMenu();
            openMenu = true;
        }
    }

    Rectangle {
        id: menu
        anchors.right: parent.right
        anchors.rightMargin: styler.themePaddingLarge
        color: styler.itemBg
        height: flick.height + 2*styler.themePaddingLarge
        layer.enabled: true
        layer.effect: DropShadow {
            color: styler.shadowColor
            opacity: styler.shadowOpacity
            radius: styler.shadowRadius
            samples: 1 + radius*2
        }
        radius: styler.themePaddingMedium
        visible: openMenu
        width: flick.width + 2*styler.themePaddingLarge
        y: styler.themePaddingLarge

        property int cellHeight: styler.themeIconSizeMedium + styler.themePaddingMedium + styler.themeFontSizeExtraSmall
        property int cellHeightFull: cellHeight + styler.themePaddingLarge
        property int cellWidth: styler.themeIconSizeMedium*1.5
        property int cellWidthFull: cellWidth + styler.themePaddingMedium

        Flickable {
            id: flick

            anchors.centerIn: parent
            clip: true
            contentHeight: col.height
            contentWidth: width

            height: Math.min(col.height, Math.round((map.height-panel.height)*0.6))
            width: Math.min(Math.round(map.width*0.6),
                            menu.cellWidthFull*8,
                            menu.cellWidthFull*Math.max(Math.ceil(typeGrid.model.count/typeGrid.nrows),
                                                        lightList.model.count,
                                                        transList.model.count))

            Component {
                id: selectionDelegate
                Rectangle {
                    id: item
                    color: mouse.pressed ? styler.itemPressed : "transparent"
                    height: menu.cellHeightFull
                    radius: styler.themePaddingSmall
                    width: menu.cellWidthFull

                    property var view: GridView.view ? GridView.view : ListView.view

                    Rectangle {
                        id: iconHolder
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: styler.themePaddingMedium/2 - border.width
                        border.color: model.current ? styler.itemHighlight : "transparent"
                        border.width: Math.max(1,styler.themeFontSizeExtraSmall/5)
                        color: "transparent"
                        height: icon.height + 2*border.width
                        radius: styler.themePaddingSmall
                        width: icon.height + 2*border.width

                        IconPL {
                            id: icon
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.top: parent.top
                            anchors.topMargin: iconHolder.border.width
                            iconColorize: false
                            iconHeight: styler.themeIconSizeMedium
                            iconSource: app.getIcon("icons/basemap/%1-%2".arg(item.view.iconPrefix).arg(model.name))
                            opacity: model.enabled ? 1 : 0.5

                            Image {
                                anchors.right: icon.right
                                anchors.top: icon.top
                                height: sourceSize.height
                                smooth: true
                                source: app.getIcon("icons/indicator", true)
                                sourceSize.height: styler.indicatorSize
                                sourceSize.width: styler.indicatorSize
                                visible: model.active
                                width: sourceSize.width
                            }
                        }
                    }

                    LabelPL {
                        id: label
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: iconHolder.bottom
                        anchors.topMargin: styler.themePaddingMedium/2
                        color: styler.itemFg
                        font.pixelSize: styler.themeFontSizeExtraSmall
                        horizontalAlignment: implicitWidth > width*0.99 ? Text.AlignLeft : Text.AlignHCenter
                        opacity: model.enabled ? 1 : 0.5
                        text: item.view.tr[model.name]
                        truncMode: truncModes.fade
                        width: menu.cellWidth
                    }

                    MouseArea {
                        id: mouse
                        anchors.fill: parent
                        enabled: model.enabled
                        onClicked: item.view.apply(model.name, model.active, model.enabled)
                    }
                }
            }

            Column {
                id: col
                spacing: styler.themePaddingLarge
                width: parent.width

                LabelPL {
                    color: styler.itemFg
                    font.bold: true
                    font.pixelSize: styler.themeFontSizeSmall
                    text: app.tr("Type")
                    visible: typeGrid.model.count > 0
                }

                GridView {
                    id: typeGrid
                    boundsBehavior: Flickable.StopAtBounds
                    cellHeight: menu.cellHeightFull
                    cellWidth: menu.cellWidthFull
                    clip: true
                    delegate: selectionDelegate
                    flow: GridView.TopToBottom
                    height: cellHeight * nrows
                    model: ListModel {}
                    visible: typeGrid.model.count > 0
                    width: parent.width

                    property string iconPrefix: "type"
                    property int    nrows: model.count < 4? 1 : 2
                    property var    tr: {
                        "default": app.tr("Default"),
                        "guidance": app.tr("Guidance"),
                        "hybrid": app.tr("Hybrid"),
                        "preview": app.tr("Preview"),
                        "satellite": app.tr("Satellite"),
                        "terrain": app.tr("Terrain"),
                        "traffic": app.tr("Traffic")
                    }

                    function apply(name, active, enabled) {
                        if (!enabled) return;
                        app.conf.set("basemap_type", active ? "" : name);
                        py.call_sync("poor.app.basemap.update", []);
                        master.fillMenu();
                    }
                }

                LabelPL {
                    color: styler.itemFg
                    font.bold: true
                    font.pixelSize: styler.themeFontSizeSmall
                    text: app.tr("Light")
                    visible: lightList.model.count > 0
                }

                ListView {
                    id: lightList
                    boundsBehavior: Flickable.StopAtBounds
                    clip: true
                    delegate: selectionDelegate
                    model: ListModel {}
                    orientation: ListView.Horizontal
                    height: menu.cellHeightFull
                    visible: lightList.model.count > 0
                    width: parent.width

                    property string iconPrefix: "light"
                    property var    tr: {
                        "day": app.tr("Day"),
                        "night": app.tr("Night")
                    }

                    function apply(name, active, enabled) {
                        if (!enabled) return;
                        app.conf.set("basemap_light", active ? "" : name);
                        py.call_sync("poor.app.basemap.update", []);
                        master.fillMenu();
                    }
                }

                LabelPL {
                    color: styler.itemFg
                    font.bold: true
                    font.pixelSize: styler.themeFontSizeSmall
                    text: app.tr("Transport")
                    visible: transList.model.count > 0
                }

                ListView {
                    id: transList
                    boundsBehavior: Flickable.StopAtBounds
                    clip: true
                    delegate: selectionDelegate
                    model: ListModel {}
                    orientation: ListView.Horizontal
                    height: menu.cellHeightFull
                    visible: transList.model.count > 0
                    width: parent.width

                    property string iconPrefix: "transport"
                    property var    tr: {
                        "bicycle": app.tr("Bicycle"),
                        "car": app.tr("Car"),
                        "foot": app.tr("Walking"),
                        "transit": app.tr("Public transport")
                    }

                    function apply(name, active, enabled) {
                        if (!enabled) return;
                        app.conf.set("basemap_vehicle", active ? "" : name);
                        py.call_sync("poor.app.basemap.update", []);
                        master.fillMenu();
                    }
                }
            }
        }

        Rectangle {
            // scrollbar for flickable
            id: scrollBar
            anchors.right: parent.right
            color: styler.itemPressed
            height:  Math.max(flick.height / flick.contentHeight * flick.height - 2 * radius, flick.height/10)
            opacity: 1
            radius: width / 2
            visible: flick.height < flick.contentHeight
            width: Math.max(1,styler.themeFontSizeExtraSmall/5)
            y: flick.y + flick.contentY / flick.contentHeight * flick.height + radius;

            Behavior on opacity { NumberAnimation { id: anim; property: "opacity"; duration: 0; } }

            Connections {
                target: menu
                onVisibleChanged: {
                    if (menu.visible)
                        scrollBar.opacity = Qt.binding(function () {
                            anim.duration = flick.moving ? 0 : 3*app.conf.animationDuration;
                            return flick.moving ? 1 : 0;
                        })
                    else {
                        scrollBar.opacity = 1;
                        anim.duration = 0;
                    }
                }
            }
        }
    }

    Rectangle {
        // panel shown at the bottom for zoom adjustments
        id: panel
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        color: styler.blockBg
        height: colPanel.height + 2*styler.themePaddingLarge
        visible: openMenu

        Column {
            id: colPanel
            anchors.centerIn: parent
            spacing: styler.themePaddingLarge
            width: parent.width

            SliderPL {
                id: scaleSlider
                label: app.tr("Map scale")
                maximumValue: 2.0
                minimumValue: 0.5
                stepSize: 0.1
                value: app.conf.get("map_scale")
                valueText: value
                visible: !scaleSliderNav.visible
                width: parent.width
                onValueChanged: {
                    app.conf.set("map_scale", value);
                    if (app.mode !== modes.followMe && app.mode !== modes.navigate)
                        map.setScale(value);
                }
            }

            SliderPL {
                id: scaleSliderNav
                label: app.tr("Map scale during navigation")
                maximumValue: 4.0
                minimumValue: 0.5
                stepSize: 0.1
                value: map.route != null && map.route.mode != null ? app.conf.get("map_scale_navigation_" + map.route.mode) : 1
                valueText: value
                visible: (app.mode === modes.followMe || app.mode === modes.navigate) &&
                         map.route != null && map.route.mode != null
                width: parent.width
                onValueChanged: {
                    if (map.route == null || map.route.mode == null) return;
                    app.conf.set("map_scale_navigation_" + map.route.mode, value);
                    if (app.mode === modes.followMe || app.mode === modes.navigate)
                        map.setScale(value);
                }
            }
        }
    }

    Connections {
        target: py
        onBasemapChanged: if (openMenu) fillMenu();
    }

    onClicked: {
        if (_hide) {
            master._noanim = true;
            master.visible = false;
        }
        openMenu = false;
    }

    function fillMenu() {
        py.call("poor.app.basemap.options", [], function(options) {
            typeGrid.model.clear();
            Util.appendAll(typeGrid.model, options.type);
            lightList.model.clear();
            Util.appendAll(lightList.model, options.light);
            transList.model.clear();
            Util.appendAll(transList.model, options.vehicle);
        });
    }
}
