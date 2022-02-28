/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2019-2021 Rinigus, 2019 Purism SPC
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
        if (app.mode === modes.navigate || app.mode === modes.followMe || app.mode === modes.navigatePost) {
            if (!app.portrait)
                return northArrow.y + northArrow.height;
            return (parent.height - northArrow.height)/2 - height;
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
        radius: styler.radius
        visible: openMenu
        width: flick.width + 2*styler.themePaddingLarge
        y: styler.themePaddingLarge

        property int cellHeight: styler.themeIconSizeMedium + styler.themePaddingMedium + styler.themeFontSizeExtraSmall
        property int cellHeightFull: cellHeight + styler.themePaddingLarge
        property int cellWidth: styler.themeIconSizeMedium*1.5
        property int cellWidthFull: cellWidth + styler.themePaddingMedium
        property int maxHeight: Math.max(cellHeightFull, parent.height - panel.height -
                                         4*styler.themePaddingLarge)
        property int maxWidth: Math.max(cellWidthFull, parent.width - 4*styler.themePaddingLarge)

        Flickable {
            id: flick

            anchors.centerIn: parent
            boundsBehavior: Flickable.StopAtBounds
            clip: true
            contentHeight: col.height
            contentWidth: col.width

            height: Math.min(col.height, menu.maxHeight)
            width: Math.min(col.width, menu.maxWidth)

            Component {
                id: selectionDelegate
                Rectangle {
                    id: item
                    color: mouse.pressed ? styler.itemPressed : "transparent"
                    height: menu.cellHeightFull
                    radius: styler.themePaddingSmall
                    width: menu.cellWidthFull

                    property var view: parent

                    Rectangle {
                        id: iconHolder
                        anchors.horizontalCenter: parent.horizontalCenter
                        border.color: model.current ? styler.itemHighlight : "transparent"
                        border.width: Math.max(1,styler.themeFontSizeExtraSmall/5)
                        color: "transparent"
                        height: icon.height + 2*border.width
                        radius: styler.themePaddingSmall
                        width: icon.height + 2*border.width
                        y: (item.height - height - label.height - label.anchors.topMargin) / 2

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

            Grid {
                id: col
                columns: portrait ? 1 : 3
                columnSpacing: styler.themePaddingLarge
                flow: Grid.TopToBottom
                rowSpacing: styler.themePaddingLarge

                property bool portrait: menu.maxHeight >= menu.maxWidth
                property int  nrExtras: {
                    if (portrait) {
                        var h = rowSpacing*5 + 3*menu.cellHeightFull + 3*typeLabel.height;
                        h = menu.maxHeight - h;
                        if (h > 0)
                            return Math.floor(h / menu.cellHeightFull);
                    } else {
                        var w = columnSpacing*3 +
                                Math.max(menu.cellWidthFull, typeLabel.width, lightLabel.width, transLabel.width);
                        w = menu.maxWidth - w;
                        if (w > 0)
                            return Math.floor(w / menu.cellWidthFull);
                    }
                    return 0;
                }
                property int secondMaxCount: {
                    var l = [ typeGrid.model.count, lightGrid.model.count, transGrid.model.count ];
                    l.sort();
                    return Math.max(2, l[1]);
                }

                LabelPL {
                    id: typeLabel
                    color: styler.itemFg
                    font.bold: true
                    font.pixelSize: styler.themeFontSizeSmall
                    text: app.tr("Type")
                    visible: typeGrid.model.count > 0
                }

                Grid {
                    id: typeGrid
                    flow: col.portrait ? Grid.TopToBottom : Grid.LeftToRight
                    rows: col.gridRows(model.count)
                    visible: model.count > 0

                    Repeater {
                        delegate: selectionDelegate
                        model: parent.model
                    }

                    property string iconPrefix: "type"
                    property var    model: ListModel {}
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
                    id: lightLabel
                    color: styler.itemFg
                    font.bold: true
                    font.pixelSize: styler.themeFontSizeSmall
                    text: app.tr("Light")
                    visible: lightGrid.model.count > 0
                }

                Grid {
                    id: lightGrid
                    flow: col.portrait ? Grid.TopToBottom : Grid.LeftToRight
                    rows: col.gridRows(model.count)
                    visible: model.count > 0

                    Repeater {
                        delegate: selectionDelegate
                        model: parent.model
                    }

                    property string iconPrefix: "light"
                    property var    model: ListModel {}
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
                    id: transLabel
                    color: styler.itemFg
                    font.bold: true
                    font.pixelSize: styler.themeFontSizeSmall
                    text: app.tr("Transport")
                    visible: transGrid.model.count > 0
                }

                Grid {
                    id: transGrid
                    flow: col.portrait ? Grid.TopToBottom : Grid.LeftToRight
                    rows: col.gridRows(model.count)
                    visible: model.count > 0

                    Repeater {
                        delegate: selectionDelegate
                        model: parent.model
                    }

                    property string iconPrefix: "transport"
                    property var    model: ListModel {}
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

                function gridRows(count){
                    var nc;
                    var nr;
                    if (col.portrait) {
                        nc = Math.max(1, Math.floor(menu.maxWidth / menu.cellWidthFull));
                        nr = Math.max(1, Math.ceil(count / nc));
                        if (nc > col.secondMaxCount && col.nrExtras + 1 > nr) {
                            nr = Math.min(col.nrExtras + 1, Math.ceil(count / col.secondMaxCount));
                        }
                        return nr;
                    } else {
                        var h = menu.maxHeight -
                                Math.max(typeLabel.height, lightLabel.height, transLabel.height) -
                                rowSpacing;
                        nr = Math.max(1, Math.floor(h / menu.cellHeightFull));
                        nc = Math.max(1, Math.ceil(count / nr));
                        if (nr > col.secondMaxCount && col.nrExtras + 1 > nc) {
                            nc = Math.min(col.nrExtras + 1, Math.ceil(count / col.secondMaxCount));
                            nr = Math.max(1, Math.ceil(count / nc));
                        }
                        return nr;
                    }
                }
            }
        }

        Rectangle {
            // vertical scrollbar for flickable
            id: scrollBarV
            anchors.right: parent.right
            color: styler.itemPressed
            height:  Math.max(flick.height / flick.contentHeight * flick.height - 2 * radius, flick.height/10)
            opacity: 1
            radius: width / 2
            visible: flick.height < flick.contentHeight
            width: Math.max(1,styler.themeFontSizeExtraSmall/5)
            y: flick.y + flick.contentY / flick.contentHeight * flick.height + radius;

            Behavior on opacity { NumberAnimation { id: animV; property: "opacity"; duration: 0; } }

            Connections {
                target: menu
                onVisibleChanged: {
                    if (menu.visible)
                        scrollBarV.opacity = Qt.binding(function () {
                            animV.duration = flick.moving ? 0 : 3*app.conf.animationDuration;
                            return flick.moving ? 1 : 0;
                        })
                    else {
                        scrollBarV.opacity = 1;
                        animV.duration = 0;
                    }
                }
            }
        }

        Rectangle {
            // horizontal scrollbar for flickable
            id: scrollBarH
            anchors.bottom: parent.bottom
            color: styler.itemPressed
            width:  Math.max(flick.width / flick.contentWidth * flick.width - 2 * radius, flick.width/10)
            opacity: 1
            radius: height / 2
            visible: flick.width < flick.contentWidth
            height: Math.max(1,styler.themeFontSizeExtraSmall/5)
            x: flick.x + flick.contentX / flick.contentWidth * flick.width + radius;

            Behavior on opacity { NumberAnimation { id: animH; property: "opacity"; duration: 0; } }

            Connections {
                target: menu
                onVisibleChanged: {
                    if (menu.visible)
                        scrollBarH.opacity = Qt.binding(function () {
                            animH.duration = flick.moving ? 0 : 3*app.conf.animationDuration;
                            return flick.moving ? 1 : 0;
                        })
                    else {
                        scrollBarH.opacity = 1;
                        animH.duration = 0;
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
                }
            }

            SliderPL {
                id: scaleSliderNav
                label: app.tr("Map scale during navigation")
                maximumValue: 4.0
                minimumValue: 0.5
                stepSize: 0.1
                value: app.transportMode ? app.conf.get("map_scale_navigation_" + app.transportMode) : 1
                valueText: value
                visible: (app.mode === modes.followMe || app.mode === modes.navigate || app.mode === modes.navigatePost) && app.transportMode
                width: parent.width
                onValueChanged: {
                    if (!app.transportMode) return;
                    app.conf.set("map_scale_navigation_" + app.transportMode, value);
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
            lightGrid.model.clear();
            Util.appendAll(lightGrid.model, options.light);
            transGrid.model.clear();
            Util.appendAll(transGrid.model, options.vehicle);
        });
    }
}
