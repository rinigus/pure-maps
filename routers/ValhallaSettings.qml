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
import Sailfish.Silica 1.0

Column {
    id: settingsBlock

    property string router

    SectionHeader {
        text: app.tr("General options")
    }

    ComboBox {
        id: typeComboBox
        label: app.tr("Type")
        menu: ContextMenu {
            MenuItem { text: app.tr("Car") }
            MenuItem { text: app.tr("Bicycle") }
            MenuItem { text: app.tr("Foot") }
            MenuItem { text: app.tr("Public transport") }
            MenuItem { text: app.tr("Bus") }
            MenuItem { text: app.tr("High-occupancy vehicle (HOV)") }
            MenuItem { text: app.tr("Motorcycle") }
            MenuItem { text: app.tr("Motor Scooter") }
        }
        property string current_key
        property var keys: ["auto", "bicycle", "pedestrian", "transit", "bus", "hov", "motorcycle", "motor_scooter"]
        //property var keys: ["auto", "bicycle", "pedestrian", "bus", "hov", "motorcycle", "motor_scooter"]
        Component.onCompleted: {
            var key = app.conf.get("routers." + settingsBlock.router + ".type");
            var index = typeComboBox.keys.indexOf(key);
            typeComboBox.currentIndex = index > -1 ? index : 0;
            current_key = typeComboBox.keys[typeComboBox.currentIndex];
        }
        onCurrentIndexChanged: {
            var key = typeComboBox.keys[typeComboBox.currentIndex]
            current_key = key;
            app.conf.set("routers." + settingsBlock.router + ".type", key);
        }
    }

    ComboBox {
        id: langComboBox
        label: app.tr("Language")
        menu: ContextMenu {
            // XXX: We need something more complicated here in order to
            // have the languages in alphabetical order after translation.
            MenuItem { text: app.tr("Catalan") }
            MenuItem { text: app.tr("Czech") }
            MenuItem { text: app.tr("English") }
            MenuItem { text: app.tr("English Pirate") }
            MenuItem { text: app.tr("French") }
            MenuItem { text: app.tr("German") }
            MenuItem { text: app.tr("Hindi") }
            MenuItem { text: app.tr("Italian") }
            MenuItem { text: app.tr("Portuguese") }
            MenuItem { text: app.tr("Russian") }
            MenuItem { text: app.tr("Slovenian") }
            MenuItem { text: app.tr("Spanish") }
            MenuItem { text: app.tr("Swedish") }
        }
        property var keys: ["ca", "cs", "en", "en-US-x-pirate", "fr", "de", "hi", "it", "pt", "ru", "sl", "es", "sv"]
        Component.onCompleted: {
            var key = app.conf.get("routers." + settingsBlock.router + ".language");
            var index = langComboBox.keys.indexOf(key);
            langComboBox.currentIndex = index > -1 ? index : 2;
        }
        onCurrentIndexChanged: {
            var key = langComboBox.keys[langComboBox.currentIndex]
            app.conf.set("routers." + settingsBlock.router + ".language", key);
        }
    }

    SectionHeader {
        text: app.tr("Advanced options")
    }

    TextSwitch {
        id: autoShorterSwitch
        anchors.left: parent.left
        anchors.right: parent.right
        text: app.tr("Prefer shorter route")
        visible: typeComboBox.current_key == "auto"
        Component.onCompleted: checked = app.conf.get("routers." + settingsBlock.router + ".shorter")
        onCheckedChanged: {
            if (!autoShorterSwitch.visible) return;
            app.conf.set("routers." + settingsBlock.router + ".shorter", checked ? 1 : 0);
        }
    }

    ComboBox {
        id: bicycleTypeComboBox
        label: app.tr("Bicycle type")
        menu: ContextMenu {
            MenuItem { text: app.tr("Road") }
            MenuItem { text: app.tr("Hybrid or City (default)") }
            MenuItem { text: app.tr("Cross") }
            MenuItem { text: app.tr("Mountain") }
        }
        visible: typeComboBox.current_key == "bicycle"
        property var keys: ["Road", "Hybrid", "Cross", "Mountain"]
        Component.onCompleted: {
            var key = app.conf.get("routers." + settingsBlock.router + ".bicycle_type");
            var index = bicycleTypeComboBox.keys.indexOf(key);
            bicycleTypeComboBox.currentIndex = index > -1 ? index : 1;
        }
        onCurrentIndexChanged: {
            var key = bicycleTypeComboBox.keys[bicycleTypeComboBox.currentIndex]
            app.conf.set("routers." + settingsBlock.router + ".bicycle_type", key);
        }
    }

    ComboBox {
        id: useBusComboBox
        description: app.tr("Your desire to use buses.")
        label: app.tr("Bus")
        menu: ContextMenu {
            MenuItem { text: app.tr("Avoid") }
            MenuItem { text: app.tr("Prefer to avoid") }
            MenuItem { text: app.tr("No preference (default)") }
            MenuItem { text: app.tr("Incline") }
            MenuItem { text: app.tr("Prefer") }
        }
        visible: typeComboBox.current_key == "transit"
        property var keys: [0.0, 0.25, 0.5, 0.75, 1.0]
        Component.onCompleted: {
            var key = app.conf.get("routers." + settingsBlock.router + ".use_bus");
            useBusComboBox.currentIndex = settingsBlock.getIndex(useBusComboBox.keys,key);
        }
        onCurrentIndexChanged: {
            var key = useBusComboBox.keys[useBusComboBox.currentIndex]
            app.conf.set("routers." + settingsBlock.router + ".use_bus", key);
        }
    }

    ComboBox {
        id: maxHikingDifficultyComboBox
        description: app.tr("The maximum difficulty of hiking trails that is allowed.")
        label: app.tr("Hiking difficulty")
        menu: ContextMenu {
            MenuItem { text: app.tr("Walking") }
            MenuItem { text: app.tr("Hiking (default)") }
            MenuItem { text: app.tr("Mountain hiking") }
            MenuItem { text: app.tr("Demanding mountain hiking") }
            MenuItem { text: app.tr("Alpine hiking") }
            MenuItem { text: app.tr("Demanding alpine hiking") }
        }
        visible: typeComboBox.current_key == "pedestrian"
        property var keys: [0, 1, 2, 3, 4, 5]
        Component.onCompleted: {
            var key = app.conf.get("routers." + settingsBlock.router + ".max_hiking_difficulty");
            var index = maxHikingDifficultyComboBox.keys.indexOf(key);
            maxHikingDifficultyComboBox.currentIndex = index > -1 ? index : 1;
        }
        onCurrentIndexChanged: {
            var key = maxHikingDifficultyComboBox.keys[maxHikingDifficultyComboBox.currentIndex]
            app.conf.set("routers." + settingsBlock.router + ".max_hiking_difficulty", key);
        }
    }

    ComboBox {
        id: useFerryComboBox
        label: app.tr("Ferries")
        menu: ContextMenu {
            MenuItem { text: app.tr("Avoid") }
            MenuItem { text: app.tr("Prefer to avoid") }
            MenuItem { text: app.tr("No preference (default)") }
            MenuItem { text: app.tr("Incline") }
            MenuItem { text: app.tr("Prefer") }
        }
        visible: typeComboBox.current_key != "transit"
        property var keys: [0.0, 0.25, 0.5, 0.75, 1.0]
        Component.onCompleted: {
            var key = app.conf.get("routers." + settingsBlock.router + ".use_ferry");
            useFerryComboBox.currentIndex = settingsBlock.getIndex(useFerryComboBox.keys,key);
        }
        onCurrentIndexChanged: {
            var key = useFerryComboBox.keys[useFerryComboBox.currentIndex]
            app.conf.set("routers." + settingsBlock.router + ".use_ferry", key);
        }
    }

    ComboBox {
        id: useHighwaysComboBox
        label: app.tr("Highways")
        menu: ContextMenu {
            MenuItem { text: app.tr("Avoid") }
            MenuItem { text: app.tr("Prefer to avoid") }
            MenuItem { text: app.tr("No preference") }
            MenuItem { text: app.tr("Incline") }
            MenuItem { text: app.tr("Prefer (default)") }
        }
        visible: typeComboBox.current_key == "auto" || typeComboBox.current_key == "bus" || typeComboBox.current_key == "hov" || typeComboBox.current_key == "motorcycle" || typeComboBox.current_key == "motor_scooter"
        property var keys: [0.0, 0.25, 0.5, 0.75, 1.0]
        Component.onCompleted: {
            var key = app.conf.get("routers." + settingsBlock.router + ".use_highways");
            useHighwaysComboBox.currentIndex = settingsBlock.getIndex(useHighwaysComboBox.keys,key);
        }
        onCurrentIndexChanged: {
            var key = useHighwaysComboBox.keys[useHighwaysComboBox.currentIndex]
            app.conf.set("routers." + settingsBlock.router + ".use_highways", key);
        }
    }

    ComboBox {
        id: useHillsComboBox
        description: app.tr("Your desire to tackle hills. When avoiding hills and steep grades, longer (time and distance) routes can be selected. By allowing hills, it indicates you do not fear hills and steeper grades.")
        label: app.tr("Hills")
        menu: ContextMenu {
            MenuItem { text: app.tr("Avoid") }
            MenuItem { text: app.tr("No preference (default)") }
            MenuItem { text: app.tr("Allow") }
        }
        visible: typeComboBox.current_key == "bicycle" || typeComboBox.current_key == "motor_scooter"
        property var keys: [0.0, 0.5, 1.0]
        Component.onCompleted: {
            var key = app.conf.get("routers." + settingsBlock.router + ".use_hills");
            useHillsComboBox.currentIndex = settingsBlock.getIndex(useHillsComboBox.keys,key);
        }
        onCurrentIndexChanged: {
            var key = useHillsComboBox.keys[useHillsComboBox.currentIndex]
            app.conf.set("routers." + settingsBlock.router + ".use_hills", key);
        }
    }

    ComboBox {
        id: usePrimaryComboBox
        label: app.tr("Primary roads")
        menu: ContextMenu {
            MenuItem { text: app.tr("Avoid") }
            MenuItem { text: app.tr("Prefer to avoid") }
            MenuItem { text: app.tr("No preference (default)") }
            MenuItem { text: app.tr("Incline") }
            MenuItem { text: app.tr("Prefer") }
        }
        visible: typeComboBox.current_key == "motor_scooter"
        property var keys: [0.0, 0.25, 0.5, 0.75, 1.0]
        Component.onCompleted: {
            var key = app.conf.get("routers." + settingsBlock.router + ".use_primary");
            usePrimaryComboBox.currentIndex = settingsBlock.getIndex(usePrimaryComboBox.keys,key);
        }
        onCurrentIndexChanged: {
            var key = usePrimaryComboBox.keys[usePrimaryComboBox.currentIndex]
            app.conf.set("routers." + settingsBlock.router + ".use_primary", key);
        }
    }

    ComboBox {
        id: useRailComboBox
        description: app.tr("Your desire to use rail/subway/metro.")
        label: app.tr("Rail")
        menu: ContextMenu {
            MenuItem { text: app.tr("Avoid") }
            MenuItem { text: app.tr("Prefer to avoid") }
            MenuItem { text: app.tr("No preference (default)") }
            MenuItem { text: app.tr("Incline") }
            MenuItem { text: app.tr("Prefer") }
        }
        visible: typeComboBox.current_key == "transit"
        property var keys: [0.0, 0.25, 0.5, 0.75, 1.0]
        Component.onCompleted: {
            var key = app.conf.get("routers." + settingsBlock.router + ".use_rail");
            useRailComboBox.currentIndex = settingsBlock.getIndex(useRailComboBox.keys,key);
        }
        onCurrentIndexChanged: {
            var key = useRailComboBox.keys[useRailComboBox.currentIndex]
            app.conf.set("routers." + settingsBlock.router + ".use_rail", key);
        }
    }

    ComboBox {
        id: useRoadsComboBox
        description: app.tr("Your propensity to use roads alongside other vehicles.")
        label: app.tr("Roads")
        menu: ContextMenu {
            MenuItem { text: app.tr("Avoid") }
            MenuItem { text: app.tr("No preference (default)") }
            MenuItem { text: app.tr("Allow") }
        }
        visible: typeComboBox.current_key == "bicycle"
        property var keys: [0.0, 0.5, 1.0]
        Component.onCompleted: {
            var key = app.conf.get("routers." + settingsBlock.router + ".use_roads");
            useRoadsComboBox.currentIndex = settingsBlock.getIndex(useRoadsComboBox.keys,key);
        }
        onCurrentIndexChanged: {
            var key = useRoadsComboBox.keys[useRoadsComboBox.currentIndex]
            app.conf.set("routers." + settingsBlock.router + ".use_roads", key);
        }
    }

    ComboBox {
        id: useTollsComboBox
        label: app.tr("Tolls")
        menu: ContextMenu {
            MenuItem { text: app.tr("Avoid") }
            MenuItem { text: app.tr("No preference (default)") }
            MenuItem { text: app.tr("Allow") }
        }
        visible: typeComboBox.current_key == "auto" || typeComboBox.current_key == "bus" || typeComboBox.current_key == "hov" || typeComboBox.current_key == "motorcycle" || typeComboBox.current_key == "motor_scooter"
        property var keys: [0.0, 0.5, 1.0]
        Component.onCompleted: {
            var key = app.conf.get("routers." + settingsBlock.router + ".use_tolls");
            useTollsComboBox.currentIndex = settingsBlock.getIndex(useTollsComboBox.keys,key);
        }
        onCurrentIndexChanged: {
            var key = useTollsComboBox.keys[useTollsComboBox.currentIndex]
            app.conf.set("routers." + settingsBlock.router + ".use_tolls", key);
        }
    }

    ComboBox {
        id: useTrailsComboBox
        description: app.tr("Your desire for adventure. When preferred, router will tend to avoid major roads and route on secondary roads, sometimes on using trails, tracks, unclassified roads or roads with bad surfaces.")
        label: app.tr("Trails")
        menu: ContextMenu {
            MenuItem { text: app.tr("Avoid (default)") }
            MenuItem { text: app.tr("Prefer to avoid") }
            MenuItem { text: app.tr("No preference") }
            MenuItem { text: app.tr("Incline") }
            MenuItem { text: app.tr("Prefer") }
        }
        visible: typeComboBox.current_key == "motorcycle"
        property var keys: [0.0, 0.25, 0.5, 0.75, 1.0]
        Component.onCompleted: {
            var key = app.conf.get("routers." + settingsBlock.router + ".use_trails");
            useTrailsComboBox.currentIndex = settingsBlock.getIndex(useTrailsComboBox.keys,key);
        }
        onCurrentIndexChanged: {
            var key = useTrailsComboBox.keys[useTrailsComboBox.currentIndex]
            app.conf.set("routers." + settingsBlock.router + ".use_trails", key);
        }
    }

    ComboBox {
        id: useTransfersComboBox
        label: app.tr("Transfers")
        menu: ContextMenu {
            MenuItem { text: app.tr("Avoid") }
            MenuItem { text: app.tr("No preference (default)") }
            MenuItem { text: app.tr("Allow") }
        }
        visible: typeComboBox.current_key == "transit"
        property var keys: [0.0, 0.5, 1.0]
        Component.onCompleted: {
            var key = app.conf.get("routers." + settingsBlock.router + ".use_transfers");
            useTransfersComboBox.currentIndex = settingsBlock.getIndex(useTransfersComboBox.keys,key);
        }
        onCurrentIndexChanged: {
            var key = useTransfersComboBox.keys[useTransfersComboBox.currentIndex]
            app.conf.set("routers." + settingsBlock.router + ".use_transfers", key);
        }
    }

    function getIndex(arr, val) {
        // for sorted short arrays
        if (arr==null || arr.length <= 1)
            return 0;
        for (var i = 1; i < arr.length; i++) {
            if (arr[i] > val) {
                var p = arr[i-1];
                var c = arr[i]
                return Math.abs( p-val ) < Math.abs( c-val ) ? i-1 : i;
            }
        }
        return arr.length-1;
    }

}
