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

Column {
    id: column
    ComboBox {
        id: regionComboBox
        label: "Region"
        menu: ContextMenu {
            MenuItem { text: "HSL" }
            MenuItem { text: "Waltti" }
            MenuItem { text: "Finland" }
        }
        property var keys: ["hsl", "waltti", "finland"]
        Component.onCompleted: {
            var key = app.conf.get("routers.digitransit.region");
            regionComboBox.currentIndex = regionComboBox.keys.indexOf(key);
        }
        onCurrentIndexChanged: {
            var index = regionComboBox.currentIndex;
            app.conf.set("routers.digitransit.region", regionComboBox.keys[index]);
        }
    }
    ComboBox {
        id: arriveByComboBox
        label: "Bind"
        menu: ContextMenu {
            MenuItem { text: "Departure" }
            MenuItem { text: "Arrival" }
        }
        property var keys: ["false", "true"]
        Component.onCompleted: {
            page.params.arrive_by = "false";
            var index = arriveByComboBox.keys.indexOf(page.params.arrive_by);
            arriveByComboBox.currentIndex = index;
        }
        onCurrentIndexChanged: {
            var index = arriveByComboBox.currentIndex;
            page.params.arrive_by = arriveByComboBox.keys[index];
        }
    }
    ValueButton {
        id: dateButton
        label: "Date"
        value: "Today"
        property var date: new Date()
        onClicked: {
            var dialog = pageStack.push(
                "Sailfish.Silica.DatePickerDialog", {
                    date: dateButton.date
                });
            dialog.accepted.connect(function() {
                dateButton.date = dialog.date;
                dateButton.value = dialog.dateText;
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
    ValueButton {
        id: timeButton
        label: "Time"
        value: "Now"
        property var time: new Date()
        onClicked: {
            var dialog = pageStack.push(
                "Sailfish.Silica.TimePickerDialog", {
                    "hourMode": DateTime.TwentyFourHours,
                    "hour": time.getHours(),
                    "minute": time.getMinutes()
                });
            dialog.accepted.connect(function() {
                timeButton.time = dialog.time;
                timeButton.value = dialog.timeText;
                // Format time as HH:MM:SS.
                var hour = dialog.hour.toString();
                var minute = dialog.minute.toString();
                if (hour.length < 2) hour = "0%1".arg(hour);
                if (minute.length < 2) minute = "0%1".arg(minute);
                page.params.time = "%1:%2:00".arg(hour).arg(minute);
            });
        }
    }
    ComboBox {
        id: prefComboBox
        label: "Criterion"
        menu: ContextMenu {
            MenuItem { text: "Default" }
            MenuItem { text: "Least transfers" }
            MenuItem { text: "Least walking" }
        }
        property var keys: ["default", "least-transfers", "least-walking"]
        Component.onCompleted: {
            var key = app.conf.get("routers.digitransit.optimize");
            prefComboBox.currentIndex = prefComboBox.keys.indexOf(key);
        }
        onCurrentIndexChanged: {
            var index = prefComboBox.currentIndex;
            app.conf.set("routers.digitransit.optimize", prefComboBox.keys[index]);
        }
    }
    Rectangle {
        // For spacing.
        color: "#00000000"
        height: Theme.paddingLarge
        width: parent.width
    }
    Grid {
        id: modeGrid
        anchors.left: parent.left
        anchors.leftMargin: Theme.horizontalPageMargin
        anchors.right: parent.right
        anchors.rightMargin: Theme.horizontalPageMargin
        columns: {
            // Use a dynamic column count based on available screen width.
            var width = parent.width - 2*Theme.horizontalPageMargin;
            var cellWidth = busButton.width + Theme.paddingLarge;
            return Math.floor(width/cellWidth);
        }
        height: implicitHeight + Theme.paddingLarge
        rows: Math.ceil(6/columns)
        spacing: Theme.paddingLarge
        property string option: "routers.digitransit.modes"
        IconButton {
            id: busButton
            height: icon.sourceSize.height
            icon.opacity: checked ? 0.9 : 0.3
            icon.source: app.getIcon("digitransit/bus")
            width: icon.sourceSize.width
            property bool checked: false
            Component.onCompleted: busButton.checked =
                app.conf.setContains(modeGrid.option, "BUS");
            onClicked: modeGrid.toggle(busButton, "BUS");
        }
        IconButton {
            id: tramButton
            height: icon.sourceSize.height
            icon.opacity: checked ? 0.9 : 0.3
            icon.source: app.getIcon("digitransit/tram")
            width: icon.sourceSize.width
            property bool checked: false
            Component.onCompleted: tramButton.checked =
                app.conf.setContains(modeGrid.option, "TRAM");
            onClicked: modeGrid.toggle(tramButton, "TRAM");
        }
        IconButton {
            id: trainButton
            height: icon.sourceSize.height
            icon.opacity: checked ? 0.9 : 0.3
            icon.source: app.getIcon("digitransit/train")
            width: icon.sourceSize.width
            property bool checked: false
            Component.onCompleted: trainButton.checked =
                app.conf.setContains(modeGrid.option, "RAIL");
            onClicked: modeGrid.toggle(trainButton, "RAIL");
        }
        IconButton {
            id: metroButton
            height: icon.sourceSize.height
            icon.opacity: checked ? 0.9 : 0.3
            icon.source: app.getIcon("digitransit/metro")
            width: icon.sourceSize.width
            property bool checked: false
            Component.onCompleted: metroButton.checked =
                app.conf.setContains(modeGrid.option, "SUBWAY");
            onClicked: modeGrid.toggle(metroButton, "SUBWAY");
        }
        IconButton {
            id: ferryButton
            height: icon.sourceSize.height
            icon.opacity: checked ? 0.9 : 0.3
            icon.source: app.getIcon("digitransit/ferry")
            width: icon.sourceSize.width
            property bool checked: false
            Component.onCompleted: ferryButton.checked =
                app.conf.setContains(modeGrid.option, "FERRY");
            onClicked: modeGrid.toggle(ferryButton, "FERRY");
        }
        IconButton {
            id: airplaneButton
            height: icon.sourceSize.height
            icon.opacity: checked ? 0.9 : 0.3
            icon.source: app.getIcon("digitransit/airplane")
            // Only visible in whole Finland routing.
            visible: regionComboBox.currentIndex == 2
            width: icon.sourceSize.width
            property bool checked: false
            Component.onCompleted: airplaneButton.checked =
                app.conf.setContains(modeGrid.option, "AIRPLANE");
            onClicked: modeGrid.toggle(airplaneButton, "AIRPLANE");
        }
        function toggle(button, value) {
            button.checked = !button.checked;
            button.checked ?
                app.conf.setAdd(modeGrid.option, value) :
                app.conf.setRemove(modeGrid.option, value);
        }
    }
}
