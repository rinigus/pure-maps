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
import "../qml"

Column {
    id: column

    property bool full: true

    ComboBox {
        id: regionComboBox
        label: app.tr("Region")
        menu: ContextMenu {
            MenuItem { text: app.tr("HSL") }
            MenuItem { text: app.tr("Waltti") }
            MenuItem { text: app.tr("Finland") }
        }
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

    Item {
        height: styler.themeItemSizeSmall
        width: parent.width

        /*
         * Depart/Arrive
         */

        BackgroundItem {
            id: bindItem
            anchors.left: parent.left
            anchors.top: parent.top
            height: parent.height
            width: bindLabel.width + styler.themeHorizontalPageMargin + styler.themePaddingMedium

            Label {
                id: bindLabel
                anchors.left: parent.left
                anchors.leftMargin: styler.themeHorizontalPageMargin
                anchors.top: parent.top
                height: parent.height
                text: app.tr("Depart")
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: {
                if (bindLabel.text === app.tr("Depart")) {
                    bindLabel.text = app.tr("Arrive");
                    page.params.arrive_by = "true";
                    bindLabel.color = styler.themeHighlightColor;
                } else {
                    bindLabel.text = app.tr("Depart");
                    page.params.arrive_by = "false";
                    bindLabel.color = styler.themeHighlightColor;
                }
            }

        }

        /*
         * Date
         */

        BackgroundItem {
            id: dateItem
            anchors.left: bindItem.right
            anchors.top: parent.top
            height: parent.height
            width: dateLabel.width + 2 * styler.themePaddingMedium

            property var date: new Date()

            Label {
                id: dateLabel
                anchors.left: parent.left
                anchors.leftMargin: styler.themePaddingMedium
                anchors.top: parent.top
                height: parent.height
                text: app.tr("Today")
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: {
                var dialog = pages.push("Sailfish.Silica.DatePickerDialog", {
                    "date": dateItem.date
                });
                dialog.accepted.connect(function() {
                    dateItem.date = dialog.date;
                    dateLabel.text = dialog.dateText;
                    dateLabel.color = styler.themeHighlightColor;
                    // Format date as YYYY-MM-DD.
                    var year = dialog.year.toString();
                    var month = dialog.month.toString();
                    var day = dialog.day.toString();
                    if (month.length < 2) month = "0%1".arg(month);
                    if (day.length < 2) day = "0%1".arg(day);
                    page.params.date = "%1-%2-%3".arg(year).arg(month).arg(day);
                });
            }

        }

        /*
         * Time
         */

        BackgroundItem {
            id: timeItem
            anchors.left: dateItem.right
            anchors.top: parent.top
            height: parent.height
            width: timeLabel.width + 2 * styler.themePaddingMedium

            property var time: new Date()

            Label {
                id: timeLabel
                anchors.left: parent.left
                anchors.leftMargin: styler.themePaddingMedium
                anchors.top: parent.top
                height: parent.height
                text: app.tr("Now")
                verticalAlignment: Text.AlignVCenter
            }

            onClicked: {
                var dialog = app.pages.push("Sailfish.Silica.TimePickerDialog", {
                    "hourMode": DateTime.TwentyFourHours,
                    "hour": timeItem.time.getHours(),
                    "minute": timeItem.time.getMinutes(),
                });
                dialog.accepted.connect(function() {
                    timeItem.time = dialog.time;
                    timeLabel.text = dialog.timeText;
                    timeLabel.color = styler.themeHighlightColor;
                    // Format time as HH:MM:SS.
                    var hour = dialog.hour.toString();
                    var minute = dialog.minute.toString();
                    if (hour.length < 2) hour = "0%1".arg(hour);
                    if (minute.length < 2) minute = "0%1".arg(minute);
                    page.params.time = "%1:%2:00".arg(hour).arg(minute);
                });
            }

        }

    }

    ComboBox {
        id: prefComboBox
        label: app.tr("Criterion")
        menu: ContextMenu {
            MenuItem { text: app.tr("Default") }
            MenuItem { text: app.tr("Least transfers") }
            MenuItem { text: app.tr("Least walking") }
        }
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

        IconButton {
            id: busButton
            height: modeGrid.iconSize
            icon.opacity: checked ? 0.9 : 0.3
            icon.source: "digitransit/bus.svg"
            icon.sourceSize.width: modeGrid.iconSize
            width: icon.sourceSize.width
            property bool checked: false
            Component.onCompleted: busButton.checked =
                app.conf.contains(modeGrid.option, "BUS");
            onClicked: modeGrid.toggle(busButton, "BUS");
        }

        IconButton {
            id: tramButton
            height: modeGrid.iconSize
            icon.opacity: checked ? 0.9 : 0.3
            icon.source: "digitransit/tram.svg"
            icon.sourceSize.width: modeGrid.iconSize
            width: icon.sourceSize.width
            property bool checked: false
            Component.onCompleted: tramButton.checked =
                app.conf.contains(modeGrid.option, "TRAM");
            onClicked: modeGrid.toggle(tramButton, "TRAM");
        }

        IconButton {
            id: trainButton
            height: modeGrid.iconSize
            icon.opacity: checked ? 0.9 : 0.3
            icon.source: "digitransit/train.svg"
            icon.sourceSize.width: modeGrid.iconSize
            width: icon.sourceSize.width
            property bool checked: false
            Component.onCompleted: trainButton.checked =
                app.conf.contains(modeGrid.option, "RAIL");
            onClicked: modeGrid.toggle(trainButton, "RAIL");
        }

        IconButton {
            id: metroButton
            height: modeGrid.iconSize
            icon.opacity: checked ? 0.9 : 0.3
            icon.source: "digitransit/metro.svg"
            icon.sourceSize.width: modeGrid.iconSize
            width: icon.sourceSize.width
            property bool checked: false
            Component.onCompleted: metroButton.checked =
                app.conf.contains(modeGrid.option, "SUBWAY");
            onClicked: modeGrid.toggle(metroButton, "SUBWAY");
        }

        IconButton {
            id: ferryButton
            height: modeGrid.iconSize
            icon.opacity: checked ? 0.9 : 0.3
            icon.source: "digitransit/ferry.svg"
            icon.sourceSize.width: modeGrid.iconSize
            width: icon.sourceSize.width
            property bool checked: false
            Component.onCompleted: ferryButton.checked =
                app.conf.contains(modeGrid.option, "FERRY");
            onClicked: modeGrid.toggle(ferryButton, "FERRY");
        }

        IconButton {
            id: citybikeButton
            height: modeGrid.iconSize
            icon.opacity: checked ? 0.9 : 0.3
            icon.source: "digitransit/citybike.svg"
            icon.sourceSize.width: modeGrid.iconSize
            // Only visible in HSL region routing.
            visible: regionComboBox.currentIndex === 0
            width: icon.sourceSize.width
            property bool checked: false
            Component.onCompleted: citybikeButton.checked =
                app.conf.contains(modeGrid.option, "BICYCLE_RENT");
            onClicked: modeGrid.toggle(citybikeButton, "BICYCLE_RENT");
        }

        IconButton {
            id: airplaneButton
            height: modeGrid.iconSize
            icon.opacity: checked ? 0.9 : 0.3
            icon.source: "digitransit/airplane.svg"
            icon.sourceSize.width: modeGrid.iconSize
            // Only visible in whole Finland routing.
            visible: regionComboBox.currentIndex === 2
            width: icon.sourceSize.width
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
