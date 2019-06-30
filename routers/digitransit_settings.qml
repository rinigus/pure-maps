/* -*- coding: utf-8-unix -*-
 *
 * Copyright (C) 2014 Osmo Salomaa, 2019 Rinigus, 2019 Purism SPC
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
import "../qml"
import "../qml/platform"

Column {
    id: column
    spacing: styler.themePaddingLarge

    property bool full: true

    ComboBoxPL {
        id: regionComboBox
        label: app.tr("Region")
        model: [app.tr("HSL"), app.tr("Waltti"), app.tr("Finland")]
        visible: full
        property var keys: ["hsl", "waltti", "finland"]
        Component.onCompleted: {
            var key = app.conf.get("routers.digitransit.region");
            regionComboBox.currentIndex = regionComboBox.keys.indexOf(key);
        }
        onCurrentIndexChanged: {
            var key = regionComboBox.keys[regionComboBox.currentIndex]
            app.conf.set("routers.digitransit.region", key);
        }
    }

    /*
     * Depart/Arrive, Date, Time
     */

    Grid {
        id: bholder

        anchors.left: parent.left
        anchors.leftMargin: styler.themeHorizontalPageMargin
        anchors.right: parent.right
        anchors.rightMargin: styler.themeHorizontalPageMargin
        columns: {
            if (bindItem.width + dateItem.width + timeItem.width + 2*styler.themePaddingMedium < bholder.width)
                return 3;
            return 1;
        }
        rows: columns > 1 ? 1 : 3
        spacing: styler.themePaddingMedium
        visible: full

        /*
         * Depart/Arrive
         */

        ButtonPL {
            id: bindItem
            height: styler.themeItemSizeSmall
            text: app.tr("Depart")
            onClicked: {
                if (text === app.tr("Depart")) {
                    text = app.tr("Arrive");
                    page.params.arrive_by = "true";
                } else {
                    text = app.tr("Depart");
                    page.params.arrive_by = "false";
                }
            }
        }

        /*
         * Date
         */

        ButtonPL {
            id: dateItem
            height: styler.themeItemSizeSmall
            text: app.tr("Today")

            property var  date: new Date()

            onClicked: {
                var dialog = pages.push(Qt.resolvedUrl("../qml/platform/DatePickerDialogPL.qml"), {
                                            "date": dateItem.date,
                                            "title": app.tr("Select date")
                                        });
                dialog.accepted.connect(function() {
                    dateItem.date = dialog.date;
                    dateItem.text = dialog.date.toLocaleDateString();
                    // Format date as YYYY-MM-DD.
                    var year = ("0000" + dialog.date.getFullYear()).substr(-4);
                    var month = ("00" + (dialog.date.getMonth()+1)).substr(-2);
                    var day = ("00" + dialog.date.getDate()).substr(-2);
                    page.params.date = "%1-%2-%3".arg(year).arg(month).arg(day);
                });
            }
        }

        /*
         * Time
         */

        ButtonPL {
            id: timeItem
            height: styler.themeItemSizeSmall
            text: app.tr("Now")

            property var time: new Date()

            onClicked: {
                var dialog = pages.push(Qt.resolvedUrl("../qml/platform/TimePickerDialogPL.qml"), {
                                            "hour": timeItem.time.getHours(),
                                            "minute": timeItem.time.getMinutes(),
                                            "title": app.tr("Select time")
                                        });
                dialog.accepted.connect(function() {
                    timeItem.time.setHours(dialog.hour);
                    timeItem.time.setMinutes(dialog.minute);
                    timeItem.time.setSeconds(0);
                    timeItem.text = timeItem.time.toLocaleTimeString();
                    // Format date as YYYY-MM-DD.
                    var hour = ("00" + dialog.hour).substr(-2);
                    var minute = ("00" + dialog.minute).substr(-2);
                    page.params.time = "%1:%2:00".arg(hour).arg(minute);
                });
            }
        }
    }

    ComboBoxPL {
        id: prefComboBox
        label: app.tr("Criterion")
        model: [ app.tr("Default"), app.tr("Least transfers"), app.tr("Least walking") ]
        visible: full
        property var keys: ["default", "least-transfers", "least-walking"]
        Component.onCompleted: {
            var key = app.conf.get("routers.digitransit.optimize");
            prefComboBox.currentIndex = prefComboBox.keys.indexOf(key);
        }
        onCurrentIndexChanged: {
            var key = prefComboBox.keys[prefComboBox.currentIndex]
            app.conf.set("routers.digitransit.optimize", key);
        }
    }

    Spacer {
        height: 1.25 * styler.themePaddingLarge
        visible: full
    }

    /*
     * Vehicle type toggle buttons
     */

    Grid {
        id: modeGrid
        anchors.left: parent.left
        anchors.leftMargin: styler.themeHorizontalPageMargin
        anchors.right: parent.right
        anchors.rightMargin: styler.themeHorizontalPageMargin
        columns: {
            // Use a dynamic column count based on available screen width.
            var width = parent.width - 2 * styler.themeHorizontalPageMargin;
            var cellWidth = busButton.width + spacing;
            return Math.floor(width/cellWidth);
        }
        height: implicitHeight + styler.themePaddingLarge
        rows: Math.ceil(6/columns)
        spacing: styler.themePaddingMedium

        property int    iconSize: styler.themeIconSizeLarge
        property string option: "routers.digitransit.modes"

        IconButtonPL {
            id: busButton
            height: modeGrid.iconSize
            iconOpacity: checked ? 0.9 : 0.3
            iconSource: Qt.resolvedUrl("digitransit/bus.svg")
            iconWidth: modeGrid.iconSize
            property bool checked: false
            Component.onCompleted: busButton.checked =
                app.conf.contains(modeGrid.option, "BUS");
            onClicked: modeGrid.toggle(busButton, "BUS");
        }

        IconButtonPL {
            id: tramButton
            height: modeGrid.iconSize
            iconOpacity: checked ? 0.9 : 0.3
            iconSource: Qt.resolvedUrl("digitransit/tram.svg")
            iconWidth: modeGrid.iconSize
            property bool checked: false
            Component.onCompleted: tramButton.checked =
                app.conf.contains(modeGrid.option, "TRAM");
            onClicked: modeGrid.toggle(tramButton, "TRAM");
        }

        IconButtonPL {
            id: trainButton
            height: modeGrid.iconSize
            iconOpacity: checked ? 0.9 : 0.3
            iconSource: Qt.resolvedUrl("digitransit/train.svg")
            iconWidth: modeGrid.iconSize
            property bool checked: false
            Component.onCompleted: trainButton.checked =
                app.conf.contains(modeGrid.option, "RAIL");
            onClicked: modeGrid.toggle(trainButton, "RAIL");
        }

        IconButtonPL {
            id: metroButton
            height: modeGrid.iconSize
            iconOpacity: checked ? 0.9 : 0.3
            iconSource: Qt.resolvedUrl("digitransit/metro.svg")
            iconWidth: modeGrid.iconSize
            property bool checked: false
            Component.onCompleted: metroButton.checked =
                app.conf.contains(modeGrid.option, "SUBWAY");
            onClicked: modeGrid.toggle(metroButton, "SUBWAY");
        }

        IconButtonPL {
            id: ferryButton
            height: modeGrid.iconSize
            iconOpacity: checked ? 0.9 : 0.3
            iconSource: Qt.resolvedUrl("digitransit/ferry.svg")
            iconWidth: modeGrid.iconSize
            property bool checked: false
            Component.onCompleted: ferryButton.checked =
                app.conf.contains(modeGrid.option, "FERRY");
            onClicked: modeGrid.toggle(ferryButton, "FERRY");
        }

        IconButtonPL {
            id: citybikeButton
            height: modeGrid.iconSize
            iconOpacity: checked ? 0.9 : 0.3
            iconSource: Qt.resolvedUrl("digitransit/citybike.svg")
            iconWidth: modeGrid.iconSize
            // Only visible in HSL region routing.
            visible: regionComboBox.currentIndex === 0
            property bool checked: false
            Component.onCompleted: citybikeButton.checked =
                app.conf.contains(modeGrid.option, "BICYCLE_RENT");
            onClicked: modeGrid.toggle(citybikeButton, "BICYCLE_RENT");
        }

        IconButtonPL {
            id: airplaneButton
            height: modeGrid.iconSize
            iconOpacity: checked ? 0.9 : 0.3
            iconSource: Qt.resolvedUrl("digitransit/airplane.svg")
            iconWidth: modeGrid.iconSize
            // Only visible in whole Finland routing.
            visible: regionComboBox.currentIndex === 2
            property bool checked: false
            Component.onCompleted: airplaneButton.checked =
                app.conf.contains(modeGrid.option, "AIRPLANE");
            onClicked: modeGrid.toggle(airplaneButton, "AIRPLANE");
        }

        function toggle(button, value) {
            button.checked = !button.checked;
            button.checked ?
                app.conf.add(modeGrid.option, value) :
                app.conf.remove(modeGrid.option, value);
        }

    }

}
