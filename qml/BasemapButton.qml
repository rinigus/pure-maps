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
    height: openMenu ? parent.height : button.height
    width: openMenu ? parent.width : button.width
    y: openMenu ? 0 : ypos
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
            if (running) master.visible = true;
            else if (hidden) master.visible = false;
            else master.visible = true;
        }
    }

    property bool hidden: !openMenu && _hide
    property bool openMenu: false
    property int  ypos: meters.height + styler.themePaddingLarge

    property bool _hide: (app.infoPanelOpen || (map.cleanMode && !app.conf.mapModeCleanShowBasemap))

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
        y: ypos + styler.themePaddingLarge

        property int cellHeight: styler.themeIconSizeMedium + styler.themePaddingSmall + styler.themeFontSizeSmall
        property int cellHeightFull: cellHeight + styler.themePaddingLarge
        property int cellWidth: styler.themeIconSizeMedium*1.5
        property int cellWidthFull: cellWidth + styler.themePaddingMedium

        Flickable {
            id: flick

            anchors.centerIn: parent
            clip: true
            contentHeight: col.height
            contentWidth: width

            height: Math.min(col.height, Math.round(map.height/2))
            width: Math.min(Math.round(map.width/2),
                            menu.cellWidthFull*8,
                            menu.cellWidthFull*Math.max(Math.ceil(typeGrid.model.count/2),
                                                        lightList.model.count))

            Component {
                id: selectionDelegate
                Rectangle {
                    id: item
                    color: mouse.pressed ? styler.itemPressed : "transparent"
                    height: menu.cellHeightFull
                    radius: styler.themePaddingSmall
                    width: menu.cellWidthFull

                    property var view: GridView.view ? GridView.view : ListView.view

                    IconPL {
                        id: icon
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: parent.top
                        anchors.topMargin: styler.themePaddingMedium/2
                        iconHeight: styler.themeIconSizeMedium
                        iconSource: app.getIcon("icons/center")
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

                    LabelPL {
                        id: label
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: icon.bottom
                        anchors.topMargin: styler.themePaddingSmall
                        color: styler.itemFg
                        font.pixelSize: styler.themeFontSizeSmall
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
                    height: Math.min(cellHeight * 2, model.count / Math.floor(width / cellWidth) * cellHeight)
                    model: ListModel {}
                    width: parent.width

                    property var tr: {
                        "default": app.tr("Default"),
                        "guidance": app.tr("Guidance"),
                        "hybrid": app.tr("Hybrid"),
                        "outdoors": app.tr("Outdoors"),
                        "preview": app.tr("Preview"),
                        "satellite": app.tr("Satellite")
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
                    width: parent.width

                    property var tr: {
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
                    width: parent.width

                    property var tr: {
                        "car": app.tr("Car")
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

    }

    onClicked: {
        if (_hide)
            master.visible = false;
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
