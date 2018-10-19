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
import "../qml/platform"

Column {
    id: settingsBlock
    spacing: app.styler.themePaddingLarge
    width: parent.width

    property string router

    SectionHeaderPL {
        text: app.tr("General options")
    }

    ComboBoxPL {
        id: typeComboBox
        label: app.tr("Type")
        model: [ app.tr("Car"), app.tr("Bicycle"), app.tr("Foot"), app.tr("Public transport"),
                 app.tr("Bus"), app.tr("High-occupancy vehicle (HOV)"), app.tr("Motorcycle"), app.tr("Motor Scooter") ]
        property string current_key
        property var keys: ["auto", "bicycle", "pedestrian", "transit", "bus", "hov", "motorcycle", "motor_scooter"]
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

    ComboBoxPL {
        id: langComboBox
        label: app.tr("Language")
        // XXX: We need something more complicated here in order to
        // have the languages in alphabetical order after translation.
        model: [ app.tr("Catalan"), app.tr("Czech"), app.tr("English"), app.tr("English Pirate"),
            app.tr("French"), app.tr("German"), app.tr("Hindi"), app.tr("Italian"), app.tr("Portuguese"),
            app.tr("Russian"), app.tr("Slovenian"), app.tr("Spanish"), app.tr("Swedish") ]
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

    SectionHeaderPL {
        text: app.tr("Advanced options")
    }

    TextSwitchPL {
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

    ComboBoxPL {
        id: bicycleTypeComboBox
        label: app.tr("Bicycle type")
        model: [ app.tr("Road"), app.tr("Hybrid or City (default)"), app.tr("Cross"), app.tr("Mountain") ]
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

    ComboBoxPL {
        id: useBusComboBox
        description: app.tr("Your desire to use buses.")
        label: app.tr("Bus")
        model: [ app.tr("Avoid"), app.tr("Prefer to avoid"), app.tr("No preference (default)"), app.tr("Incline"), app.tr("Prefer") ]
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

    ComboBoxPL {
        id: maxHikingDifficultyComboBox
        description: app.tr("The maximum difficulty of hiking trails that is allowed.")
        label: app.tr("Hiking difficulty")
        model: [ app.tr("Walking"), app.tr("Hiking (default)"), app.tr("Mountain hiking"),
            app.tr("Demanding mountain hiking"), app.tr("Alpine hiking"), app.tr("Demanding alpine hiking") ]
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

    ComboBoxPL {
        id: useFerryComboBox
        label: app.tr("Ferries")
        model: [ app.tr("Avoid"), app.tr("Prefer to avoid"), app.tr("No preference (default)"),
            app.tr("Incline"), app.tr("Prefer") ]
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

    ComboBoxPL {
        id: useHighwaysComboBox
        label: app.tr("Highways")
        model: [app.tr("Avoid"), app.tr("Prefer to avoid"), app.tr("No preference"),
            app.tr("Incline"), app.tr("Prefer (default)") ]
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

    ComboBoxPL {
        id: useHillsComboBox
        description: app.tr("Your desire to tackle hills. When avoiding hills and steep grades, longer (time and distance) routes can be selected. By allowing hills, it indicates you do not fear hills and steeper grades.")
        label: app.tr("Hills")
        model: [ app.tr("Avoid"), app.tr("No preference (default)"), app.tr("Allow") ]
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

    ComboBoxPL {
        id: usePrimaryComboBox
        label: app.tr("Primary roads")
        model: [ app.tr("Avoid"), app.tr("Prefer to avoid"), app.tr("No preference (default)"),
            app.tr("Incline"), app.tr("Prefer") ]
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

    ComboBoxPL {
        id: useRailComboBox
        description: app.tr("Your desire to use rail/subway/metro.")
        label: app.tr("Rail")
        model: [ app.tr("Avoid"), app.tr("Prefer to avoid"), app.tr("No preference (default)"),
            app.tr("Incline"), app.tr("Prefer") ]
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

    ComboBoxPL {
        id: useRoadsComboBox
        description: app.tr("Your propensity to use roads alongside other vehicles.")
        label: app.tr("Roads")
        model: [ app.tr("Avoid"), app.tr("No preference (default)"), app.tr("Prefer") ]
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

    ComboBoxPL {
        id: useTollsComboBox
        label: app.tr("Tolls")
        model: [ app.tr("Avoid"), app.tr("No preference (default)"), app.tr("Prefer") ]
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

    ComboBoxPL {
        id: useTrailsComboBox
        description: app.tr("Your desire for adventure. When preferred, router will tend to avoid major roads and route on secondary roads, sometimes on using trails, tracks, unclassified roads or roads with bad surfaces.")
        label: app.tr("Trails")
        model: [ app.tr("Avoid (default)"), app.tr("Prefer to avoid"), app.tr("No preference"),
            app.tr("Incline"), app.tr("Prefer") ]
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

    ComboBoxPL {
        id: useTransfersComboBox
        label: app.tr("Transfers")
        model: [ app.tr("Avoid"), app.tr("No preference (default)"), app.tr("Prefer") ]
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
